const std = @import("std");
const microzig = @import("libs/microzig/src/main.zig");

const stm32l0x1 = microzig.Chip{
    .name = "STM32L011F3Px",
    .path = root() ++ "src/STM32L0x1/registers.zig",
    .cpu = microzig.cpus.cortex_m0plus,
    .memory_regions = &.{
        .{ .kind = .flash, .offset = 0x08000000, .length = 8 * 1024 },
        .{ .kind = .ram, .offset = 0x20000000, .length = 2 * 1024 },
    },
};

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = microzig.addEmbeddedExecutable(
        b,
        "sensor-firmware",
        "src/main.zig",
        .{ .chip = stm32l0x1 },
        .{},
    ) catch @panic("failed to create embedded executable");

    exe.addCSourceFile(root() ++ "src/SEGGER_RTT.c", &[_][]const u8{
        "-std=c99",
    });

    exe.addIncludeDir(root() ++ "src");
    // This is required for RTT
    exe.addObjectFile("/usr/arm-none-eabi/lib/thumb/v6-m/nofp/libc.a");
    exe.addSystemIncludeDir("/usr/arm-none-eabi/include/");

    // This is important, without it, the linker removes the vector table
    exe.want_lto = false;

    exe.setBuildMode(mode);
    exe.install();
}

fn root() []const u8 {
    return (std.fs.path.dirname(@src().file) orelse unreachable) ++ "/";
}
