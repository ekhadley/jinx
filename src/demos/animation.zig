const std = @import("std");
const jinx = @import("jinx");

pub fn main() !void { // pendulum with a box and a live reading of the pendulum's vertical position
    var win = try jinx.Window(8192, 256).init();
    defer win.close(); // close it on exit

    const r1 = 16;

    const cx = @as(f32, @floatFromInt(win.width())) / 2;
    const cy = @as(f32, @floatFromInt(win.height())) / 2;

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

        win.startColor(250, 50, 250);
        win.rect(win.width() / 4, win.height() / 4, 3 * win.width() / 4, 3 * win.height() / 4, jinx.DoubleLine);

        const xpos = @as(usize, @intFromFloat(cx + rx));
        const ypos = @as(usize, @intFromFloat(cy + ry));
        win.moveTo(xpos, ypos);
        win.startColor(50, 250, 150);
        win.push('x');

        const centerx = @as(usize, @intFromFloat(cx));
        const centery = @as(usize, @intFromFloat(cy));
        win.moveTo(centerx, centery);
        win.startColor(20, 150, 250);
        try win.writeTextFmt("{d:.3}", .{ry});

        win.goHome();
        try win.draw();
        _ = std.os.linux.nanosleep(&.{ .sec = 0, .nsec = 10_000_000 }, null);
    }
}
