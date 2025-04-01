# Jinx: new new curses.
A barebones terminal graphics library written in Zig.  
Uses a compile time allocated buffer to store commands and then write them to the terminal all at once.  
For this reason it uses no allocator.  

# TODO:
 - resizing support
 - dynamic buffer size?
 - all the symbols