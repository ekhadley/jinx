const std = @import("std");
const print = std.debug.print;
const File = std.fs.File;
const symbols = @import("symbols.zig");

const MAX_BUFFER_SIZE = 8192;

const Terminal = struct {
    tty: File,
    rows: usize,
    cols: usize,
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
            //.rows = dims.ws_row,
            //.cols = dims.ws_col,
            .rows = dims.ws_row,
            .cols = dims.ws_col,
        };
    }
    pub fn writeBuffer(self: Terminal, buffer: ScreenBuffer) File.WriteError!void {
        try self.tty.writeAll(buffer.contents[0..buffer.place]);
    }
    pub fn close(self: Terminal) void {
        self.tty.close();
    }
};

const ScreenBuffer = struct {
    const Self = @This();
    place: usize,
    contents: [MAX_BUFFER_SIZE]u8,
    pub fn init() ScreenBuffer {
        return .{ .place = 0, .contents = undefined };
    }
    pub fn dump(self: *Self) void {
        self.place = 0;
    }
    pub fn push(self: *Self, char: u8) void {
        self.contents[self.place] = char;
        self.place += 1;
    }
    pub fn write(self: *Self, str: []const u8) void {
        for (self.contents[self.place..(self.place + str.len)], str) |*c, s| {
            c.* = s;
        }
        self.place += str.len;
    }
    pub fn moveTo(self: *Self, x: usize, y: usize) void {
        var X: usize = x;
        var Y: usize = y;
        self.write(symbols.escape);
        self.push('[');
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(Y % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(X % 10 + '0');
            X /= 10;
            Y /= 10;
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
};

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //const alloc = gpa.allocator();

    const tty = try Terminal.init();
    defer tty.close();
    var buf = ScreenBuffer.init();
    //print("terminal size detected: [{d}, {d}]\n", .{ tty.rows, tty.cols });

    buf.write(symbols.clear_screen);
    buf.write(symbols.blue);
    buf.hLine(2, 0, tty.cols, symbols.hor_double_line);
    buf.hLine(2, tty.cols, tty.cols, symbols.hor_double_line);
    buf.vLine(0, 2, tty.rows, symbols.ver_double_line);
    buf.vLine(tty.cols, 2, tty.rows, symbols.ver_double_line);

    buf.moveTo(1, 1);
    buf.write(symbols.tl_double_line);
    buf.moveTo(tty.cols, 1);
    buf.write(symbols.tr_double_line);
    buf.moveTo(1, tty.rows + 1);
    buf.write(symbols.bl_double_line);
    buf.moveTo(tty.cols, tty.rows + 1);
    buf.write(symbols.br_double_line);
    buf.moveTo(tty.cols / 2, tty.rows / 2);
    buf.write("imgay");

    try tty.writeBuffer(buf);
    while (true) {}
}
