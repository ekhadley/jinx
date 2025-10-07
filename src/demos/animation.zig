const std = @import("std");
const jinx = @import("jinx");

pub fn main() !void { // pendulum with a box and a live reading of the pendulum's vertical position
    var tty = try jinx.Window(8192, 256).init();
    defer tty.close(); // close it on exit

    const r1 = 17;

    const cx = @as(f32, @floatFromInt(tty.width())) / 2;
    const cy = @as(f32, @floatFromInt(tty.height())) / 2;

    const g = 0.001;
    var vtheta: f32 = 0.0587;
    var theta: f32 = 3 * std.math.pi / 4.0;
    var rx: f32 = 0;
    var ry: f32 = -10;

    while (true) {
        vtheta += g * std.math.sin(theta + std.math.pi / 2.0);
        theta += vtheta;
        rx = r1 * std.math.cos(theta);
        ry = r1 * std.math.sin(theta);

        tty.startColor(250, 50, 250);
        tty.rect(tty.width() / 4, tty.height() / 4, 3 * tty.width() / 4, 3 * tty.height() / 4, jinx.DoubleLine);

        const xpos = @as(usize, @intFromFloat(cx + rx));
        const ypos = @as(usize, @intFromFloat(cy + ry));
        tty.moveTo(xpos, ypos);
        tty.startColor(50, 250, 150);
        tty.push('x');

        const centerx = @as(usize, @intFromFloat(cx));
        const centery = @as(usize, @intFromFloat(cy));
        tty.moveTo(centerx, centery);
        tty.startColor(20, 150, 250);
        try tty.printf("{d:.3}", .{ry});

        tty.goHome();
        try tty.draw();
        _ = std.os.linux.nanosleep(&.{ .sec = 0, .nsec = 10_000_000 }, null);
    }
}
