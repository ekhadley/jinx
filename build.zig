const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });

    const jinx_lib_mod = b.createModule(.{
        .root_source_file = b.path("src/jinx.zig"),
        .target = target,
        .optimize = optimize,
    });
    const jinx_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "jinx",
        .root_module = jinx_lib_mod,
    });
    b.installArtifact(jinx_lib);

    const animation_demo_exe = b.addExecutable(.{
        .name = "animation_demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/demos/animation.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    animation_demo_exe.root_module.addImport("jinx", jinx_lib_mod);
    b.installArtifact(animation_demo_exe);

    const input_demo_exe = b.addExecutable(.{
        .name = "input_demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/demos/input.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    input_demo_exe.root_module.addImport("jinx", jinx_lib_mod);
    b.installArtifact(input_demo_exe);
}
