const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });

    const demo_exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("src/demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(demo_exe);
    const demo_cmd = b.addRunArtifact(demo_exe);
    demo_cmd.step.dependOn(b.getInstallStep());
    const demo_run_step = b.step("demo", "Run the animation demo");
    demo_run_step.dependOn(&demo_cmd.step);

    const input_demo_exe = b.addExecutable(.{
        .name = "input_demo",
        .root_source_file = b.path("src/input_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(input_demo_exe);
    const input_demo_cmd = b.addRunArtifact(input_demo_exe);
    input_demo_cmd.step.dependOn(b.getInstallStep());
    const input_demo_run_step = b.step("input_demo", "Run the terminal input demo");
    input_demo_run_step.dependOn(&input_demo_cmd.step);
}
