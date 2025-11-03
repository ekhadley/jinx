const std = @import("std");
const File = std.fs.File;

pub const Terminal = struct {
    tty: File,
    pix_width: usize,
    pix_height: usize,
    width: usize,
    height: usize,

    pub fn openPrimaryTTY() !Terminal {
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{
            .mode = .read_write,
            .allow_ctty = true,
        });
        var dims: std.posix.winsize = undefined;
        _ = std.os.linux.ioctl(tty.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&dims));
        return .{
            .tty = tty,
            .pix_width = dims.xpixel,
            .pix_height = dims.ypixel,
            .width = dims.col,
            .height = dims.row,
        };
    }
    pub fn close(self: *Terminal) void {
        _ = self.tty.close();
    }
};

pub fn Window(comptime write_buffer_size: usize, comptime read_buffer_size: usize) type {
    return struct {
        const Self = @This();

        tty: Terminal,
        tty_writer: std.fs.File.Writer, // writer for writing to the terminal. draw commands, etc
        tty_reader: std.fs.File.Reader, // reader for reading from the terminal. kb input, etc
        read_buffer: [read_buffer_size]u8, // buffer for the terminal reader
        write_buffer: [write_buffer_size]u8, // buffer for the terminal writer
        read_place: usize, // position in the input buffer
        write_place: usize,

        pub fn init() !Self {
            var write_buffer: [write_buffer_size]u8 = undefined;
            var read_buffer: [read_buffer_size]u8 = undefined;
            var tty = try Terminal.openPrimaryTTY();
            return .{
                .tty = tty,
                .tty_writer = tty.tty.writer(&write_buffer),
                .tty_reader = tty.tty.reader(&read_buffer),
                .write_buffer = write_buffer,
                .read_buffer = read_buffer,
                .write_place = 0,
                .read_place = 0,
            };
        }

        pub fn draw(self: *Self) !void {
            _ = try self.tty_writer.interface.writeAll(self.write_buffer[0..self.write_place]);
            try self.tty_writer.interface.flush();
            self.write_place = 0;
            self.write(CLS);
        }

        pub fn flush(self: *Self) void {
            self.write_place = 0;
        }
        pub fn push(self: *Self, comptime char: u8) void {
            self.write_buffer[self.write_place] = char;
            self.write_place += 1;
        }
        pub fn write(self: *Self, str: []const u8) void {
            @memcpy(self.write_buffer[self.write_place..(self.write_place + str.len)], str);
            self.write_place += str.len;
        }
        pub fn writeTextFmt(self: *Self, comptime format: []const u8, args: anytype) !void {
            const formatted = try std.fmt.bufPrint(self.write_buffer[self.write_place..], format, args);
            self.write_place += formatted.len;
        }
        pub fn height(self: *Self) usize {
            return self.tty.height;
        }
        pub fn width(self: *Self) usize {
            return self.tty.width;
        }

        pub fn goHome(self: *Self) void {
            self.write(HOME);
        }
        pub fn writeRGB(self: *Self, R: u8, G: u8, B: u8) void {
            var r = R;
            var g = G;
            var b = B;
            for (0..3) |i| {
                self.write_buffer[self.write_place + 2 - i] = @intCast(r % 10 + '0');
                self.write_buffer[self.write_place + 6 - i] = @intCast(g % 10 + '0');
                self.write_buffer[self.write_place + 10 - i] = @intCast(b % 10 + '0');
                r /= 10;
                g /= 10;
                b /= 10;
            }
            self.write_buffer[self.write_place + 3] = ';';
            self.write_buffer[self.write_place + 7] = ';';
            self.write_place += 11;
        }
        pub fn startColor(self: *Self, R: u8, G: u8, B: u8) void {
            self.write(ESC);
            self.write("38;2;");
            self.writeRGB(R, G, B);
            self.write(";249m");
        }
        pub fn startColorBG(self: *Self, R: u8, G: u8, B: u8) void {
            self.write(ESC);
            self.write("48;2;");
            self.writeRGB(R, G, B);
            self.write(";249m");
        }
        pub fn moveTo(self: *Self, X: usize, Y: usize) void {
            // \esc + [ + XXX;YYYH
            var x: usize = X + 1;
            var y: usize = Y + 1;
            self.write(ESC);
            for (0..3) |i| {
                self.write_buffer[self.write_place + 2 - i] = @intCast(y % 10 + '0');
                self.write_buffer[self.write_place + 6 - i] = @intCast(x % 10 + '0');
                x /= 10;
                y /= 10;
            }
            self.write_buffer[self.write_place + 3] = ';';
            self.write_buffer[self.write_place + 7] = 'H';
            self.write_place += 8;
        }
        pub fn horLine(self: *Self, x1: usize, y: usize, x2: usize, line_type: LineType) void {
            const start = @min(x1, x2);
            const end = @max(x1, x2);

            self.moveTo(start, y);
            for (start..end) |_| {
                self.write(line_type.hor);
            }
        }
        pub fn verLine(self: *Self, x: usize, y1: usize, y2: usize, line_type: LineType) void {
            const start = @min(y1, y2);
            const end = @max(y1, y2);
            self.moveTo(x, start);
            for (start..end) |y| {
                self.moveTo(x, y);
                self.write(line_type);
            }
        }
        pub fn rect(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize, line_type: LineType) void {
            const startx = @min(x1, x2);
            const endx = @max(x1, x2);
            const starty = @min(y1, y2);
            const endy = @max(y1, y2);

            self.moveTo(startx, starty);
            self.write(line_type.tl);
            for (startx..endx - 1) |_| {
                self.write(line_type.hor);
            }
            self.write(line_type.tr);
            self.moveTo(startx, endy);
            self.write(line_type.bl);
            for (startx..endx - 1) |_| {
                self.write(line_type.hor);
            }
            self.write(line_type.br);
            for (0..endy - starty - 1) |i| {
                self.moveTo(endx, endy - i - 1);
                self.write(line_type.ver);
            }
            for (0..endy - starty - 1) |i| {
                self.moveTo(startx, endy - i - 1);
                self.write(line_type.ver);
            }
        }
        pub fn fillRect(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize, char: u8) void {
            const startx = @min(x1, x2);
            const starty = @min(y1, y2);
            for (0..@abs(x2 - x1)) |_| {
                for (0..@abs(y2 - y1)) |_| {
                    self.push(char);
                }
            }
            self.moveTo(startx, starty);
        }

        pub fn close(self: *Self) void {
            _ = self.tty.close();
        }
    };
}

pub const ESC = "\x1b["; // control sequence introducer
pub const CLS = ESC ++ "2J";

// colors
pub const Colors = .{
    .black = ESC ++ "0;30m",
    .red = ESC ++ "0;31m",
    .green = ESC ++ "0;32m",
    .yellow = ESC ++ "0;33m",
    .blue = ESC ++ "0;34m",
    .purple = ESC ++ "0;35m",
    .cyan = ESC ++ "0;36m",
    .white = ESC ++ "0;37m",
    .end_color = ESC ++ "0m",
};

// cursor movements
pub const UP = ESC ++ "A";
pub const DOWN = ESC ++ "B";
pub const RIGHT = ESC ++ "C";
pub const LEFT = ESC ++ "D";
pub const HOME = ESC ++ "H";

// screen control

// box drawing unicode characters:
pub const LineType = struct {
    hor: []const u8,
    ver: []const u8,
    tl: []const u8,
    tr: []const u8,
    bl: []const u8,
    br: []const u8,
};
pub const Line = LineType{
    .hor = "─",
    .ver = "│",
    .tr = "┌",
    .tl = "┐",
    .bl = "└",
    .br = "┘",
};
pub const DoubleLine = LineType{
    .hor = "═",
    .ver = "║",
    .tr = "╗",
    .tl = "╔",
    .bl = "╚",
    .br = "╝",
};
pub const ThickLine = LineType{
    .hor = "━",
    .ver = "┃",
    .tr = "┓",
    .tl = "┏",
    .bl = "┗",
    .br = "┛",
};
pub const DottedLine = LineType{
    .hor = "┄",
    .ver = "┊",
    .tl = "┌",
    .tr = "┐",
    .bl = "└",
    .br = "┘",
};
pub const DottedThickLine = LineType{
    .hor = "┅",
    .ver = "┇",
    .tr = "┓",
    .tl = "┏",
    .bl = "┗",
    .br = "┛",
};
pub const DashedLine = LineType{
    .hor = "╌",
    .ver = "╎",
    .tr = "┌",
    .tl = "┐",
    .bl = "└",
    .br = "┘",
};
pub const DashedThickLine = LineType{
    .hor = "╍",
    .ver = "╏",
    .tr = "┓",
    .tl = "┏",
    .bl = "┗",
    .br = "┛",
};

pub const BLOCK = "█";
