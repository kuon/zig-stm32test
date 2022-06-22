const microzig = @import("microzig");
const regs = microzig.chip.registers;

const rtt = @import("rtt.zig");

pub fn main() anyerror!void {
    // Enable HSI
    regs.RCC.CR.modify(.{ .HSI16ON = 1 });
    // Wait for HSI ready
    while (regs.RCC.CR.read().HSI16RDYF != 1) {}

    // Use HSI16 as system clock and wakeup clock
    regs.RCC.CFGR.modify(.{ .SW = 0b01, .STOPWUCK = 1 });

    // Enable power interface clock
    regs.RCC.APB1ENR.modify(.{ .PWREN = 1 });

    // Disable RTC register protection
    // This MUST be done once the PWREN has been set in RCC_APB1ENR
    regs.PWR.CR.modify(.{ .DBP = 1 });

    // Enable LSE (external crystal at 32kHz)
    regs.RCC.CSR.modify(.{ .LSEON = 1 });
    // Wait for LSE to be stable
    while (regs.RCC.CSR.read().LSERDY != 1) {}

    // Use LSE as RTC source and enable RTC
    regs.RCC.CSR.modify(.{
        .RTCSEL = 0b01, // LSE
        .RTCEN = 1,
    });

    rtt.init();

    while (true) {
        rtt.write("Hello world!\n");
        delay(1000);
    }
}

pub fn delay(ms: u32) void {
    // CPU run at 16mHz on HSI16
    // each tick is 5 instructions (1000 * 16 / 5) = 3200
    var ticks = ms * (1000 * 16 / 5);
    var i: u32 = 0;
    // One loop is 5 instructions
    while (i < ticks) {
        microzig.cpu.nop();
        i += 1;
    }
}
