const std = @import("std");
const jinx = @import("jinx");
const symbols = jinx.symbols;

// pub fn main() !void {
//     const tty = try jinx.Terminal.init();
//     defer tty.close();
//     //var buf = jinx.CmdBuffer.init(8192);
//
//     //const t = try std.fs.openFileAbsolute("/dev/tty", .{
//     //.mode = .read_write,
//     //.allow_ctty = true,
//     //});
//     //defer t.close();
//     //var opts: std.posix.termios = undefined;
//     //_ = std.os.linux.tcsetattr(t.handle, std.posix.TCSA.NOW, &opts);
//
//     //var stdout_buffer: [1024]u8 = undefined;
//     //var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
//     //var reader = stdout_writer.reader();
//
//     var stdin_buffer: [1024]u8 = undefined;
//     var stdin_reader = tty.tty.reader(&stdin_buffer);
//     //var stdin = &stdin_reader.interface;
//
//     //var input_buffer: [1024]u8 = undefined;
//     //var stdin_writer = std.io.Writer.fixed(&input_buffer);
//
//     var total_bytes_read: usize = 0;
//     while (true) {
//         std.debug.print("reading input...\n", .{});
//         //const bytes_read = try stdin.streamDelimiter(&stdin_writer, '\n');
//         const bytes_read = try stdin_reader.read(&stdin_buffer);
//         total_bytes_read += bytes_read;
//         if (bytes_read > 0) {
//             total_bytes_read += bytes_read;
//             std.debug.print("read input {d} bytes. current buffer: {s}\n", .{ bytes_read, stdin_buffer[0..total_bytes_read] });
//             //try stdin_writer.flush();
//         }
//     }
// }
pub fn main() void {
    return;
}
