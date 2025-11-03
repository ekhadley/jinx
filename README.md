# Jinx: new new curses.
A barebones terminal graphics library written in Zig.  
Uses a fixed size buffer to accumulate draw commands and then write them to the terminal all at once.  
This is done to avoid needing an allocator anywhere

# TODO:
- upgrading to 0.15 writers/readers
- refactoring the drawing system
    - removing cursor position/other side effects as a thing a library user would have to worry about