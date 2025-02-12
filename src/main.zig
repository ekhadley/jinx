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
    pub fn moveTo(self: *Self, x: u32, y: u32) void {
        var X: u32 = x;
        var Y: u32 = y;
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
};

pub fn openTerminalFile() File.OpenError!File {
    return std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
}

pub fn writeBuffer(tty: File, buffer: ScreenBuffer) File.WriteError!void {
    try tty.writeAll(buffer.contents[0..buffer.place]);
}

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //const alloc = gpa.allocator();

    const tty = try openTerminalFile();
    defer tty.close();
    var buf = ScreenBuffer.init();

    buf.write(clear_screen_code);
    buf.moveTo(10, 20);
    buf.write(red_code);
    buf.write("slorpglorpin");
    buf.moveTo(30, 5);
    buf.write(green_code);
    buf.write("aboba");
    buf.write(end_color_code);
    buf.moveTo(20, 3);
    buf.write("agobobagoga");
    buf.write(go_home_code);

    //print("buffer contents: \n{s}\n", .{buf.contents[0..buf.place]});
    const cx = 40;
    const cy = 40;
    const r: f32 = 10;

    var theta: f32 = 0;
    var rx: f32 = 0;
    var ry: f32 = 0;
    while (true) {
        ry = r * std.math.sin(theta);
        rx = r * std.math.cos(theta);
        theta += 0.01;

        buf.dump();

        buf.write(green_code);
        buf.moveTo(@intFromFloat(cx + rx), @intFromFloat(cy + ry));
        buf.write("aboba");
        buf.write(go_home_code);

        try writeBuffer(tty, buf);
        std.time.sleep(10_000_000);
    }
}
