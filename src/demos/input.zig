const std = @import("std");
const jinx = @import("jinx");
const symbols = jinx.symbols;

pub fn main() !void {
    var win = try jinx.Window(8192, 256).init();
    defer win.close();

    // var opts: std.posix.termios = undefined;
    // _ = std.os.linux.tcsetattr(win.tty.tty.handle, std.posix.TCSA.NOW, &opts);

    // Get a pointer to the reader interface for use with the new API
    const reader = &win.tty_reader.interface;

    var input_chunk: [256]u8 = undefined;
    var total_bytes_read: usize = 0;

    while (true) {
        std.debug.print("reading input...\n", .{});

        // readSliceShort blocks until buffer is full or EOF
        // Returns the number of bytes actually read
        const bytes_read = reader.readSliceShort(&input_chunk) catch |err| {
            if (err == error.EndOfStream) break;
            return err;
        };

        if (bytes_read > 0) {
            // Copy to the window's read buffer
            @memcpy(win.read_buffer[total_bytes_read..(total_bytes_read + bytes_read)], input_chunk[0..bytes_read]);
            total_bytes_read += bytes_read;
            std.debug.print("read input {d} bytes. current buffer: {s}\n", .{ bytes_read, win.read_buffer[0..total_bytes_read] });
        }

        if (bytes_read == 0) break; // EOF reached
    }
}
