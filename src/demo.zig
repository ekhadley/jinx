const std = @import("std");
const jinx = @import("jinx.zig");
const symbols = jinx.symbols;

pub fn main() !void { // pendulum with a box and a live reading of the pendulum's vertical position
    const tty = try jinx.Terminal.init(); // open the file for the current terminal
    defer tty.close(); // close it on exit
    var buf = jinx.CmdBuffer.init(8192); // initialize a buffer which will hold our terminal draw commands

    const r1 = 17;

    const cx: f32 = @floatFromInt(tty.width / 2);
    const cy: f32 = @floatFromInt(tty.height / 2);

    const g = 0.001;
    var vtheta: f32 = 0.0587;
    var theta: f32 = 3 * std.math.pi / 4.0;
    var rx: f32 = 0;
    var ry: f32 = -10;

    while (true) {
        buf.startColor(250, 50, 250); // begin drawing all characters in this color
        buf.rect(tty.width / 4, tty.height / 4, 3 * tty.width / 4, 3 * tty.height / 4, symbols.double_line); // draw a full rect with double lines

        buf.moveTo(@intFromFloat(cx + 2 * rx), @intFromFloat(cy + ry)); // move cursor to this position
        buf.startColor(50, 250, 150);
        buf.write("x"); // write a character at the cursor position

        buf.moveTo(@intFromFloat(cx), @intFromFloat(cy));
        buf.startColor(20, 150, 250);
        try buf.printf("{d:.3}", .{ry}); // formatted print
        buf.endColor(); // dont really need this
        buf.goHome(); // move cursor to home (top left, 0, 0)

        try tty.writeBuffer(buf); // write full buffer contents to terminal

        vtheta += g * std.math.sin(theta + std.math.pi / 2.0);
        theta += vtheta;
        rx = r1 * std.math.cos(theta);
        ry = r1 * std.math.sin(theta);

        std.time.sleep(10_000_000); // sleep for 100ms
        buf.dump(); // 'empty' the  buffer (just moves the pointer to the start of the array)
    }
}
