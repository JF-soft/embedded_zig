const std = @import("std");
const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("firmware.elf", "startup.zig");
    exe.setTarget( .{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 },
    });
    // builtin.Arch{ .thumb = .v7m }, builtin.Os.freestanding, builtin.Abi.none);

    const main_o = b.addObject("main", "main.zig");
    exe.setTarget( .{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 },
    });
    exe.addObject(main_o);

    exe.setBuildMode(mode);
    exe.setLinkerScriptPath("arm_cm3.ld");
    exe.setOutputDir(".");

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
