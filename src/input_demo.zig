const std = @import("std");
const jinx = @import("jinx.zig");
const symbols = jinx.symbols;

pub fn main() !void {
    const tty = try jinx.Terminal.init();
    defer tty.close();
    //var buf = jinx.CmdBuffer.init(8192);

    const t = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_only, .allow_ctty = true });
    var opts: std.posix.termios = undefined;
    _ = std.os.linux.tcsetattr(t.handle, std.posix.TCSA.NOW, &opts);

    var buffered_reader = std.io.bufferedReader(t.reader());
    var reader = buffered_reader.reader();

    while (true) {
        const char_byte = try reader.readByte();
        std.debug.print("Read character: {c}\n", .{char_byte});
    }
}
