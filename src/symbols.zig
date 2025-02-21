// general escape sequence
pub const escape = "\x1b";
pub const escape_csi = "\x1b["; // esc + [ is the 'control sequence introducer'

// colors
pub const black = escape_csi ++ "0;30m";
pub const red = escape_csi ++ "0;31m";
pub const green = escape_csi ++ "0;32m";
pub const yellow = escape_csi ++ "0;33m";
pub const blue = escape_csi ++ "0;34m";
pub const purple = escape_csi ++ "0;35m";
pub const cyan = escape_csi ++ "0;36m";
pub const white = escape_csi ++ "0;37m";
// end color
pub const end_color = escape ++ "[0m";

// cursor movements
pub const up = escape ++ "[A";
pub const down = escape ++ "[B";
pub const right = escape ++ "[C";
pub const left = escape ++ "[D";
pub const go_home = escape ++ "[H";

// screen control
pub const clear_screen = escape ++ "[2J";

// box drawing unicode characters:
pub const LineType = struct {
    hor: []const u8,
    ver: []const u8,
    corner_tl: []const u8,
    corner_tr: []const u8,
    corner_bl: []const u8,
    corner_br: []const u8,
};
pub const tl_line = "┌";
pub const bl_line = "└";
pub const tr_line = "┐";
pub const br_line = "┘";
pub const normal_line = LineType{
    .hor = "─",
    .ver = "│",
    .corner_tr = tr_line,
    .corner_tl = tl_line,
    .corner_bl = bl_line,
    .corner_br = br_line,
};
pub const double_line = LineType{
    .hor = "═",
    .ver = "║",
    .corner_tr = "╗",
    .corner_tl = "╔",
    .corner_bl = "╚",
    .corner_br = "╝",
};
pub const tl_thick_line = "┏";
pub const bl_thick_line = "┗";
pub const tr_thick_line = "┓";
pub const br_thick_line = "┛";
pub const thick_line = LineType{
    .hor = "━",
    .ver = "┃",
    .corner_tr = tr_thick_line,
    .corner_tl = tl_thick_line,
    .corner_bl = bl_thick_line,
    .corner_br = br_thick_line,
};
pub const dotted_line = LineType{
    .hor = "┄",
    .ver = "┊",
    .corner_tr = tr_line,
    .corner_tl = tl_line,
    .corner_bl = bl_line,
    .corner_br = br_line,
};
pub const dotted_thick_line = LineType{
    .hor = "┅",
    .ver = "┇",
    .corner_tr = tr_thick_line,
    .corner_tl = tl_thick_line,
    .corner_bl = bl_thick_line,
    .corner_br = br_thick_line,
};
pub const dashed_line = LineType{
    .hor = "╌",
    .ver = "╎",
    .corner_tr = tr_line,
    .corner_tl = tl_line,
    .corner_bl = bl_line,
    .corner_br = br_line,
};
pub const dashed_thick_line = LineType{
    .hor = "╍",
    .ver = "╏",
    .corner_tr = tr_thick_line,
    .corner_tl = tl_thick_line,
    .corner_bl = bl_thick_line,
    .corner_br = br_thick_line,
};
