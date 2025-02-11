const std = @import("std");
const print = std.debug.print;
const MAX_BUFFER_SIZE = 1024;

const escape_code = "\x1b";
const home_code = escape_code ++ "[H";

const ScreenBuffer = struct {
    const len = MAX_BUFFER_SIZE;
    var place: usize = 0;
    var contents = [MAX_BUFFER_SIZE]u8{};
    pub fn init() ScreenBuffer {
        return .{};
    }
    pub fn clear(self: ScreenBuffer) !void {
        for (self.contents[self.place .. self.place + escape_code.len], escape_code) |*d, s| {
            d.* = s;
        }
        self.place += escape_code;
    }
};

pub fn writeBuffer(tty: std.fs.File, buf: ScreenBuffer) !void {
    try tty.write(buf.contents[0..buf.place]);
}

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //const alloc = gpa.allocator();
    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
    defer tty.close();

    const buf = ScreenBuffer.init();
    print("buf.size = {d}, buf.place = {d}", .{ buf.len, buf.place });
    //buf.clear();
    //writeBuffer(tty, buf);

    while (true) {}
}
