const std = @import("std");
const File = std.fs.File;
pub const symbols = @import("symbols.zig");

pub const Terminal = struct {
    tty: File,
    height: usize,
    width: usize,
    pix_width: usize,
    pix_height: usize,
    pub fn init() !Terminal {
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
        var dims: std.posix.system.winsize = undefined;
        _ = std.os.linux.ioctl(tty.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&dims));
        return .{
            .tty = tty,
            .pix_width = dims.ws_xpixel,
            .pix_height = dims.ws_ypixel,
            .width = dims.ws_col,
            .height = dims.ws_row,
        };
    }
    pub fn writeBuffer(self: Terminal, buffer: CmdBuffer) File.WriteError!void {
        try self.tty.writeAll(buffer.contents[0..buffer.place]);
    }
    pub fn close(self: Terminal) void {
        self.tty.close();
    }
};

pub const CmdBuffer = struct {
    const Self = @This();
    place: usize,
    contents: []u8,
    pub fn init(comptime buffer_size: usize) CmdBuffer {
        var contents: [buffer_size]u8 = undefined;
        return .{ .contents = &contents, .place = 0 };
    }

    pub fn dump(self: *Self) void {
        self.place = 0;
        self.clearScreen();
    }
    pub fn push(self: *Self, comptime char: u8) void {
        self.contents[self.place] = char;
        self.place += 1;
    }
    pub fn printf(self: *Self, comptime fmt: []const u8, args: anytype) !void {
        var fbs = std.io.fixedBufferStream(self.contents);
        fbs.pos = self.place;
        try std.fmt.format(fbs.writer().any(), fmt, args);
        self.place = fbs.pos;
    }
    pub fn write(self: *Self, str: []const u8) void {
        for (self.contents[self.place..(self.place + str.len)], str) |*c, s| {
            c.* = s;
        }
        self.place += str.len;
    }

    pub fn clearScreen(self: *Self) void {
        self.write(symbols.clear_screen);
    }
    pub fn startRed(self: *Self) void {
        self.write(symbols.red);
    }
    pub fn startBlack(self: *Self) void {
        self.write(symbols.black);
    }
    pub fn startGreen(self: *Self) void {
        self.write(symbols.green);
    }
    pub fn startYellow(self: *Self) void {
        self.write(symbols.yellow);
    }
    pub fn startBlue(self: *Self) void {
        self.write(symbols.blue);
    }
    pub fn startPurple(self: *Self) void {
        self.write(symbols.purple);
    }
    pub fn startCyan(self: *Self) void {
        self.write(symbols.cyan);
    }
    pub fn startWhite(self: *Self) void {
        self.write(symbols.white);
    }
    pub fn endColor(self: *Self) void {
        self.write(symbols.end_color);
    }
    pub fn goHome(self: *Self) void {
        self.write(symbols.go_home);
    }
    pub fn writeRGB(self: *Self, R: u8, G: u8, B: u8) void {
        var r = R;
        var g = G;
        var b = B;
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(r % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(g % 10 + '0');
            self.contents[self.place + 10 - i] = @intCast(b % 10 + '0');
            r /= 10;
            g /= 10;
            b /= 10;
        }
        self.contents[self.place + 3] = ';';
        self.contents[self.place + 7] = ';';
        self.place += 11;
    }
    pub fn startColor(self: *Self, R: u8, G: u8, B: u8) void {
        self.write(symbols.escape_csi);
        self.write("38;2;");
        self.writeRGB(R, G, B);
        self.write(";249m");
    }
    pub fn startColorBG(self: *Self, R: u8, G: u8, B: u8) void {
        self.write(symbols.escape_csi);
        self.write("48;2;");
        self.writeRGB(R, G, B);
        self.write(";249m");
    }
    pub fn moveTo(self: *Self, X: usize, Y: usize) void {
        // \esc + [ + XXX;YYYH
        var x: usize = X + 1;
        var y: usize = Y + 1;
        self.write(symbols.escape_csi);
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(y % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(x % 10 + '0');
            x /= 10;
            y /= 10;
        }
        self.contents[self.place + 3] = ';';
        self.contents[self.place + 7] = 'H';
        self.place += 8;
    }
    pub fn hLine(self: *Self, x1: usize, y: usize, x2: usize, lineType: *const [3:0]u8) void {
        const start = @min(x1, x2);
        const end = @max(x1, x2);

        self.moveTo(start, y);
        for (start..end) |_| {
            self.write(lineType);
        }
    }
    pub fn vLine(self: *Self, x: usize, y1: usize, y2: usize, lineType: *const [3:0]u8) void {
        const start = @min(y1, y2);
        const end = @max(y1, y2);
        self.moveTo(x, start);
        for (start..end) |y| {
            self.moveTo(x, y);
            self.write(lineType);
        }
    }
    pub fn rect(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize, line_type: symbols.LineType) void {
        const startx = @min(x1, x2);
        const endx = @max(x1, x2);
        const starty = @min(y1, y2);
        const endy = @max(y1, y2);

        self.moveTo(startx, starty);
        self.write(line_type.corner_tl);
        for (startx..endx - 1) |_| {
            self.write(line_type.hor);
        }
        self.write(line_type.corner_tr);
        self.moveTo(startx, endy);
        self.write(line_type.corner_bl);
        for (startx..endx - 1) |_| {
            self.write(line_type.hor);
        }
        self.write(line_type.corner_br);
        for (0..endy - starty - 1) |i| {
            self.moveTo(endx, endy - i - 1);
            self.write(line_type.ver);
        }
        for (0..endy - starty - 1) |i| {
            self.moveTo(startx, endy - i - 1);
            self.write(line_type.ver);
        }
    }
};
