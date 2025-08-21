const std = @import("std");
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });

    const lib = b.addStaticLibrary(.{
        .name = "jinx",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/jinx.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "jinx",
        .root_source_file = b.path("src/demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);
    const demo_cmd = b.addRunArtifact(exe);
    demo_cmd.step.dependOn(b.getInstallStep());

    const snake_exe = b.addExecutable(.{
        .name = "jinx",
        .root_source_file = b.path("src/snake.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(snake_exe);
    const snake_cmd = b.addRunArtifact(exe);
    snake_cmd.step.dependOn(b.getInstallStep());

    const run_demo_step = b.step("demo", "Run the demo");
    run_demo_step.dependOn(&demo_cmd.step);

    const run_snake_step = b.step("snake", "Run the snake game demo");
    run_snake_step.dependOn(&demo_cmd.step);
}
