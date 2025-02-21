// general escape sequence
pub const escape = "\x1b";
pub const escape_csi = "\x1b["; // esc + [ is the 'control sequence introducer'

// colors
pub const black = escape ++ "[0;30m";
pub const red = escape ++ "[0;31m";
pub const green = escape ++ "[0;32m";
pub const yellow = escape ++ "[0;33m";
pub const blue = escape ++ "[0;34m";
pub const purple = escape ++ "[0;35m";
pub const cyan = escape ++ "[0;36m";
pub const white = escape ++ "[0;37m";
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
pub const hor_single_line = "─";
pub const ver_single_line = "│";
pub const tl_single_line = "┌";
pub const bl_single_line = "└";
pub const tr_single_line = "┐";
pub const br_single_line = "└";

pub const hor_double_line = "═";
pub const ver_double_line = "║";
pub const tl_double_line = "╔";
pub const bl_double_line = "╚";
pub const tr_double_line = "╗";
pub const br_double_line = "╝";

pub const LineTypes = enum {
    double,
    single,
    thick,
    dotted,
    dotted_thick,
    dashed,
    dashed_thick,
};
