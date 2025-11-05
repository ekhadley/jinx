const std = @import("std");
const jinx = @import("jinx");
const symbols = jinx.symbols;

pub fn main() !void {
    var win = try jinx.Window(8192, 256).init();
    defer win.close();
    const reader = &win.tty_reader.interface;

    const original = try std.posix.tcgetattr(win.tty.f.handle);
    var raw = original;
    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.lflag.ISIG = false;
    raw.iflag.IXON = false;
    raw.iflag.ICRNL = false;
    raw.iflag.BRKINT = false;
    raw.iflag.INPCK = false;
    raw.iflag.ISTRIP = false;
    raw.oflag.OPOST = false;
    raw.cflag.CSIZE = std.posix.CSIZE.CS8;
    try std.posix.tcsetattr(win.tty.f.handle, std.posix.TCSA.NOW, raw);

    // const line = try reader.takeDelimiterExclusive('\n');
    // std.debug.print("read input {d} bytes. line: '{s}'\n", .{ line.len, line });

    std.debug.print("waiting for input...\n", .{});
    while (reader.takeByte()) |byte| {
        std.debug.print("read input byte: {d}\n", .{byte});
    } else |err| switch (err) {
        error.EndOfStream => {
            std.debug.print("End of input reached.\n", .{});
        },
        error.ReadFailed => {
            std.debug.print("Error: Read failed!\n", .{});
        },
    }
}
