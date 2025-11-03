const std = @import("std");
const jinx = @import("jinx");
const symbols = jinx.symbols;

pub fn main() !void {
    var win = try jinx.Window(8192, 256).init();
    defer win.close();

    // Get a pointer to the reader interface for use with the new Zig 0.15 API
    const reader = &win.tty_reader.interface;

    var total_bytes_read: usize = 0;

    std.debug.print("Type lines of text (Ctrl+D to exit):\n", .{});

    // Use takeDelimiterExclusive to read line-by-line (reads until '\n')
    while (reader.takeDelimiterExclusive('\n')) |line| {
        const bytes_read = line.len;

        if (bytes_read > 0) {
            // Copy the line to the window's read buffer
            @memcpy(win.read_buffer[total_bytes_read..(total_bytes_read + bytes_read)], line);
            total_bytes_read += bytes_read;
            std.debug.print("read input {d} bytes. line: {s}\n", .{ bytes_read, line });
            std.debug.print("total buffer: {s}\n", .{win.read_buffer[0..total_bytes_read]});
        }
    } else |err| switch (err) {
        error.EndOfStream => {
            std.debug.print("End of input reached.\n", .{});
        },
        error.StreamTooLong => {
            std.debug.print("Error: Input line too long for buffer!\n", .{});
            return err;
        },
        error.ReadFailed => {
            std.debug.print("Error: Read failed!\n", .{});
            return err;
        },
    }

    std.debug.print("Final total: {d} bytes read\n", .{total_bytes_read});
}
