const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });

    const lib = b.addStaticLibrary(.{
        .name = "jinx",
        .root_source_file = b.path("src/jinx.zig"),
        .target = target,
        .optimize = optimize,
    });
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
<<<<<<< Updated upstream

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
=======
    const run_step = b.step("demo", "Run the demo");
    run_step.dependOn(&demo_cmd.step);

    const exe2 = b.addExecutable(.{
        .name = "input_demo",
        .root_source_file = b.path("src/input_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe2);
    const input_demo_cmd = b.addRunArtifact(exe2);
    input_demo_cmd.step.dependOn(b.getInstallStep());
    const input_demo_run_step = b.step("input_demo", "Run the terminal input demo");
    input_demo_run_step.dependOn(&input_demo_cmd.step);
>>>>>>> Stashed changes
}
