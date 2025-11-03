const std = @import("std");
const jinx = @import("jinx");
const symbols = jinx.symbols;

pub fn main() !void {
    var win = try jinx.Window(8192, 256).init();
    defer win.close();

    // var opts: std.posix.termios = undefined;
    // _ = std.os.linux.tcsetattr(win.tty.tty.handle, std.posix.TCSA.NOW, &opts);

    var total_bytes_read: usize = 0;
    while (true) {
        std.debug.print("reading input...\n", .{});
        const bytes_read = try win.tty_reader.interface.readSliceShort(&win.read_buffer);
        // const bytes_read = try t.reader().interface.readSliceShort(&win.read_buffer);
        total_bytes_read += bytes_read;
        if (bytes_read > 0) {
            total_bytes_read += bytes_read;
            std.debug.print("read input {d} bytes. current buffer: {s}\n", .{ bytes_read, win.read_buffer[0..total_bytes_read] });
            //try stdin_writer.flush();
        }
    }
}
