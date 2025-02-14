const std = @import("std");
const print = std.debug.print;
const File = std.fs.File;
const symbols = @import("symbols.zig");

const MAX_BUFFER_SIZE = 8192;

const Terminal = struct {
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
        var X: usize = x + 1;
        var Y: usize = y + 1;
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
    pub fn rect(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize) void {
        const startx = @min(x1, x2);
        const endx = @max(x1, x2);
        const starty = @min(y1, y2);
        const endy = @max(y1, y2);
        self.moveTo(startx, starty);
        self.write(symbols.tl_double_line); // top left corner
        for (startx..endx - 1) |_| {
            self.write(symbols.hor_double_line); // top edge
        }
        self.write(symbols.tr_double_line); // top right corner
        self.moveTo(startx, endy);
        self.write(symbols.bl_double_line); // bottom left corner
        for (startx..endx - 1) |_| {
            self.write(symbols.hor_double_line); // bottom edge
        }
        self.write(symbols.br_double_line); // bottom right corner
        for (0..endy - starty - 1) |i| {
            self.moveTo(endx, endy - i - 1);
            self.write(symbols.ver_double_line); // right edge
        }
        for (0..endy - starty - 1) |i| {
            self.moveTo(startx, endy - i - 1); // left edge
            self.write(symbols.ver_double_line);
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
    buf.rect(0, 0, tty.width - 1, tty.height - 1);
    buf.write(symbols.red);
    buf.moveTo(tty.width / 2, tty.height / 2);
    buf.write("imgay");
    buf.rect(tty.width / 4, tty.height / 4, tty.width * 3 / 4, tty.height * 3 / 4);

    try tty.writeBuffer(buf);
    while (true) {}
}
