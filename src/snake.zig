const std = @import("std");
const jinx = @import("jinx.zig");
const symbols = jinx.symbols;

pub const Snake = struct {
    head_x: usize,
    head_y: usize,
    length: usize,
    length_max: usize,

    pub fn init(hx: usize, hy: usize, lenmax: usize) Snake {
        return .{ .head_x = hx, .head_y = hy, .length = 1, .length_max = lenmax };
    }
};

pub fn main() !void {
    const tty = try jinx.Terminal.init();
    defer tty.close();
    var buf = jinx.CmdBuffer.init(8192);

    var snek = Snake.init(tty.width / 2, tty.height / 2, tty.width * tty.height);

    while (true) {
        buf.startColor(8, 98, 131);
        buf.rect(tty.width / 4, tty.height / 4, 3 * tty.width / 4, 3 * tty.height / 4, symbols.double_line);

        buf.moveTo(snek.head_x, snek.head_y);
        buf.startColor(50, 250, 150);
        buf.write(symbols.full_block);

        try tty.writeBuffer(buf);

        snek.head_x += 1;
        snek.head_y += 0;

        std.time.sleep(100_000_000);
        buf.dump();
    }
}
