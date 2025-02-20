const std = @import("std");
const print = std.debug.print;
const File = std.fs.File;
const symbols = @import("symbols.zig");

const MAX_BUFFER_SIZE = 8192;

const Terminal = struct {
    tty: File,
    height: usize,
    width: usize,
    pix_width: usize,
    pix_height: usize,
    pub fn init() !Terminal {
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .write_only, .allow_ctty = true });
        var dims: std.posix.system.winsize = undefined;
        _ = std.os.linux.ioctl(tty.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&dims));
        return .{
            .tty = tty,
            .pix_width = dims.ws_xpixel,
            .pix_height = dims.ws_ypixel,
            .width = dims.ws_col,
            .height = dims.ws_row,
        };
    }
    pub fn writeBuffer(self: Terminal, buffer: CmdBuffer) File.WriteError!void {
        try self.tty.writeAll(buffer.contents[0..buffer.place]);
    }
    pub fn close(self: Terminal) void {
        self.tty.close();
    }
};

const CmdBuffer = struct {
    const Self = @This();
    place: usize,
    contents: [MAX_BUFFER_SIZE]u8,
    pub fn init() CmdBuffer {
        return .{ .place = 0, .contents = undefined };
    }
    pub fn dump(self: *Self) void {
        self.place = 0;
        self.clear();
    }
    pub fn push(self: *Self, char: u8) void {
        self.contents[self.place] = char;
        self.place += 1;
    }
    pub fn write(self: *Self, str: []const u8) void {
        for (self.contents[self.place..(self.place + str.len)], str) |*c, s| {
            c.* = s;
        }
        self.place += str.len;
    }
    pub fn clear(self: *Self) void {
        self.write(symbols.clear_screen);
    }
    pub fn startRed(self: *Self) void {
        self.write(symbols.red);
    }
    pub fn startBlack(self: *Self) void {
        self.write(symbols.black);
    }
    pub fn startGreen(self: *Self) void {
        self.write(symbols.green);
    }
    pub fn startYellow(self: *Self) void {
        self.write(symbols.yellow);
    }
    pub fn startBlue(self: *Self) void {
        self.write(symbols.blue);
    }
    pub fn startPurple(self: *Self) void {
        self.write(symbols.purple);
    }
    pub fn startCyan(self: *Self) void {
        self.write(symbols.cyan);
    }
    pub fn startWhite(self: *Self) void {
        self.write(symbols.white);
    }
    pub fn endColor(self: *Self) void {
        self.write(symbols.end_color);
    }
    pub fn goHome(self: *Self) void {
        self.write(symbols.go_home);
    }
    pub fn writeColor(self: *Self, R: u8, G: u8, B: u8) void {
        // \esc + [ + 38;RRR;GGG;BBB;249m
        var r = R;
        var g = G;
        var b = B;
        self.write(symbols.escape_csi);
        self.write("38;2;");
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(r % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(g % 10 + '0');
            self.contents[self.place + 10 - i] = @intCast(b % 10 + '0');
            r /= 10;
            g /= 10;
            b /= 10;
        }
        self.contents[self.place + 3] = ';';
        self.contents[self.place + 7] = ';';
        self.place += 11;
        self.write(";249m");
        //print("buf contents: {s}", .{self.contents[self.place - 22 .. self.place]});
    }
    pub fn writeColorBG(self: *Self, R: u8, G: u8, B: u8) void {
        // \esc + [ + 38;RRR;GGG;BBB;249m
        var r = R;
        var g = G;
        var b = B;
        self.write(symbols.escape_csi);
        self.write("48;2;");
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(r % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(g % 10 + '0');
            self.contents[self.place + 10 - i] = @intCast(b % 10 + '0');
            r /= 10;
            g /= 10;
            b /= 10;
        }
        self.contents[self.place + 3] = ';';
        self.contents[self.place + 7] = ';';
        self.place += 11;
        self.write(";249m");
        //print("buf contents: {s}", .{self.contents[self.place - 22 .. self.place]});
    }
    pub fn moveTo(self: *Self, X: usize, Y: usize) void {
        // \esc + [ + XXX;YYYH
        var x: usize = X + 1;
        var y: usize = Y + 1;
        self.write(symbols.escape_csi);
        for (0..3) |i| {
            self.contents[self.place + 2 - i] = @intCast(y % 10 + '0');
            self.contents[self.place + 6 - i] = @intCast(x % 10 + '0');
            x /= 10;
            y /= 10;
        }
        self.contents[self.place + 3] = ';';
        self.contents[self.place + 7] = 'H';
        self.place += 8;
    }
    pub fn hLine(self: *Self, x1: usize, y: usize, x2: usize, lineType: *const [3:0]u8) void {
        const start = @min(x1, x2);
        const end = @max(x1, x2);

        self.moveTo(start, y);
        for (start..end) |_| {
            self.write(lineType);
        }
    }
    pub fn vLine(self: *Self, x: usize, y1: usize, y2: usize, lineType: *const [3:0]u8) void {
        const start = @min(y1, y2);
        const end = @max(y1, y2);
        self.moveTo(x, start);
        for (start..end) |y| {
            self.moveTo(x, y);
            self.write(lineType);
        }
    }
    pub fn rect(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize) void {
        const startx = @min(x1, x2);
        const endx = @max(x1, x2);
        const starty = @min(y1, y2);
        const endy = @max(y1, y2);
        self.moveTo(startx, starty);
        self.write(symbols.tl_double_line); // top left corner
        for (startx..endx - 1) |_| {
            self.write(symbols.hor_double_line); // top edge
        }
        self.write(symbols.tr_double_line); // top right corner
        self.moveTo(startx, endy);
        self.write(symbols.bl_double_line); // bottom left corner
        for (startx..endx - 1) |_| {
            self.write(symbols.hor_double_line); // bottom edge
        }
        self.write(symbols.br_double_line); // bottom right corner
        for (0..endy - starty - 1) |i| {
            self.moveTo(endx, endy - i - 1);
            self.write(symbols.ver_double_line); // right edge
        }
        for (0..endy - starty - 1) |i| {
            self.moveTo(startx, endy - i - 1); // left edge
            self.write(symbols.ver_double_line);
        }
    }
};

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //const alloc = gpa.allocator();
    //fuck the heap all my homies hate the heap

    const tty = try Terminal.init();
    defer tty.close();
    var buf = CmdBuffer.init();

    const r1 = 10;

    const cx: f32 = @floatFromInt(tty.width / 2);
    const cy: f32 = @floatFromInt(tty.height / 2);

    var theta: f32 = 0;
    var rx: f32 = 0;
    var ry: f32 = -10;

    while (true) {
        buf.moveTo(@intFromFloat(cx + rx), @intFromFloat(cy + ry));
        buf.writeColor(50, 250, 150);
        buf.push('x');

        buf.writeColor(250, 250, 250);
        buf.writeColorBG(250, 80, 40);
        buf.moveTo(@intFromFloat(cx), @intFromFloat(cy));
        buf.push('O');
        buf.endColor();

        buf.goHome();
        try tty.writeBuffer(buf);

        theta += 0.1;
        rx = r1 * std.math.cos(theta);
        ry = r1 * std.math.sin(theta);

        std.time.sleep(100000000);
        buf.dump();
    }
}
