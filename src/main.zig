const std = @import("std");
const jinx = @import("jinx.zig");
const symbols = jinx.symbols;

pub fn main() !void {
    const tty = try jinx.Terminal.init();
    defer tty.close();
    var buf = jinx.CmdBuffer.init(8192);

    const r1 = 20;

    const cx: f32 = @floatFromInt(tty.width / 2);
    const cy: f32 = @floatFromInt(tty.height / 2);

    const g = 0.001;
    var vtheta: f32 = 0.058;
    var theta: f32 = 3 * std.math.pi / 4.0;
    var rx: f32 = 0;
    var ry: f32 = -10;

    while (true) {
        buf.startColor(250, 50, 250);
        buf.rect(tty.width / 4, tty.height / 4, 3 * tty.width / 4, 3 * tty.height / 4, symbols.thick_line);

        buf.moveTo(@intFromFloat(cx + rx), @intFromFloat(cy + ry));
        buf.startColor(50, 250, 150);
        buf.write('x');

        buf.moveTo(@intFromFloat(cx), @intFromFloat(cy));
        buf.startColor(20, 150, 250);
        try buf.printf("{d:.3}", .{ry});
        buf.endColor();
        buf.goHome();

        try tty.writeBuffer(buf);

        vtheta += g * std.math.sin(theta + std.math.pi / 2.0);
        theta += vtheta;
        //theta += 0.1;
        rx = r1 * std.math.cos(theta);
        ry = r1 * std.math.sin(theta);

        std.time.sleep(10000000);
        buf.dump();
    }
}
