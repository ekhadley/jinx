const std = @import("std");
const File = std.fs.File;
const print = std.debug.print;

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //const alloc = gpa.allocator();

    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
    //const tty = try std.fs.openFileAbsolute("/home/ek/wgmn/jinx/hi.txt", .{});
    defer tty.close();
    _ = try tty.write("123abc\n");
}
