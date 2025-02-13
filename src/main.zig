const std = @import("std");
const print = std.debug.print;
const File = std.fs.File;
const MAX_BUFFER_SIZE = 1024;

const escape_code = "\x1b";
const go_home_code = escape_code ++ "[H";
const clear_screen_code = escape_code ++ "[2J";

const black_code = escape_code ++ "[0;30m";
const red_code = escape_code ++ "[0;31m";
const green_code = escape_code ++ "[0;32m";
const yellow_code = escape_code ++ "[0;33m";
const blue_code = escape_code ++ "[0;34m";
const purple_code = escape_code ++ "[0;35m";
const cyan_code = escape_code ++ "[0;36m";
const white_code = escape_code ++ "[0;37m";
const end_color_code = escape_code ++ "[0m";

const move_up_code = escape_code ++ "[A";
const move_down_code = escape_code ++ "[B";
const move_right_code = escape_code ++ "[C";
const move_left_code = escape_code ++ "[D";

const Terminal = struct {
    tty: File,
    rows: usize,
    cols: usize,
    pix_width: usize,
    pix_height: usize,
    pub fn init() !Terminal {
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
        var dims: std.posix.system.winsize = undefined;
        const x = std.os.linux.ioctl(tty.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&dims));
        print("ioctl returned: {d}", .{x});
        return .{ .tty = tty, .rows = dims.ws_row, .cols = dims.ws_col, .pix_width = dims.ws_xpixel, .pix_height = dims.ws_ypixel };
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
        self.write(escape_code);
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
    pub fn hLine(self: *Self, x1: usize, y: usize, x2: usize) void {
        self.moveTo(x1, y);
        if (x2 > x1) {
            for (x1..x2) |_| {
                self.push('═');
            }
        } else {
            for (x2..x1) |_| {
                self.push('═');
            }
        }
    }
    pub fn vLine(self: *Self, x: usize, y1: usize, y2: usize) void {
        self.moveTo(x, y1);
        if (y2 > y1) {
            for (y1..y2) |_| {
                self.push('║');
            }
        } else {
            for (y2..y1) |_| {
                self.push('║');
            }
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
    print("terminal size detected: [{d}, {d}]", .{ tty.rows, tty.cols });

    buf.write(clear_screen_code);
    buf.write(blue_code);
    buf.hLine(0, 0, tty.cols);

    try tty.writeBuffer(buf);
    while (true) {}
}
