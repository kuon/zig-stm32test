const rtt = @cImport({
    @cInclude("SEGGER_RTT.h");
});

pub fn init() void {
    rtt.SEGGER_RTT_Init();
}

pub fn write(str: []const u8) void {
    _ = rtt.SEGGER_RTT_Write(0, @ptrCast(*const anyopaque, str.ptr), str.len);
}
