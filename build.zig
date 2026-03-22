const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const dll = b.addLibrary(.{
        .name = "version",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = true,
            .single_threaded = true,
        }),
    });
    dll.dll_export_fns = false;
    dll.entry = .{ .symbol_name = "DllMain" };
    dll.link_data_sections = true;
    dll.link_function_sections = true;
    dll.link_gc_sections = true;
    dll.win32_module_definition = b.path("exports.def");
    b.installArtifact(dll);
}
