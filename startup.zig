const builtin = @import("builtin");
const mem = @import("std").mem;

// user program function declared in main.zig
extern fn main() void;

// main stack pointer, cast it to fn () void to populate
// vector table and be  able to use a standard linker script
// Thanks to shima-529 stm32OnDlang (STM32 D lang project)
// https://github.com/shima-529/stm32OnDlang
extern fn _estack() void;

// start of initialized data in flash, from linker script
extern var _sidata: u32;
// start of initialized data in ram, from linker script
extern var _sdata: u32;
// end of initialized data in ram, from linker script
extern var _edata: u32;

// start of uninitialized data in ram, from linker script
extern var _sbss: u32;
// end of uninitialized data in ram, from linker script
extern var _ebss: u32;

// Follow Eclipse Embedded CDT convention for starting program.
export fn _start() noreturn {
    // size of data and bss sections
    const data_len = @ptrToInt(&_edata) - @ptrToInt(&_sdata);
    const bss_len = @ptrToInt(&_ebss) - @ptrToInt(&_sbss);

    // memory sections
    const idata = @ptrCast([*]u8, &_sidata);
    const data = @ptrCast([*]u8, &_sdata);
    const bss = @ptrCast([*]u8, &_sbss);

    // copy initialized data from FLASH to RAM
    // for (idata[0..data_len]) |b, i| data[i] = b;
    mem.copy(u8, data[0..data_len], idata[0..data_len]);

    // clear the bss
    // for (bss[0..bss_len]) |*b| b.* = 0;
    mem.set(u8, bss[0..bss_len], 0);

    // call user main program
    main();

    // generate an error if program gets here
    unreachable;
}

export fn Reset_Handler() void {
    _start();
}

export fn BusyDummy_Handler() void {
    @setCold(true);
    while (true) {}
}

export fn Dummy_Handler() void {
    @setCold(true);
}

// Exceptions
comptime {
    @export(BusyDummy_Handler, .{ .name = "NMI_Handler", .linkage = .Weak });
}
fn NMI_Handler() callconv(.C) void {}

comptime {
    @export(BusyDummy_Handler, .{ .name = "HardFault_Handler", .linkage = .Weak });
}
fn HardFault_Handler() callconv(.C) void {}

comptime {
    @export(BusyDummy_Handler, .{ .name = "MemManage_Handler", .linkage = .Weak });
}
fn MemManage_Handler() callconv(.C) void {}

comptime {
    @export(BusyDummy_Handler, .{ .name = "BusFault_Handler", .linkage = .Weak });
}
fn BusFault_Handler() callconv(.C) void {}

comptime {
    @export(BusyDummy_Handler, .{ .name = "UsageFault_Handler", .linkage = .Weak });
}
fn UsageFault_Handler() callconv(.C) void {}

comptime {
    @export(Dummy_Handler, .{ .name = "SVC_Handler", .linkage = .Weak });
}
fn SVC_Handler() callconv(.C) void {}

comptime {
    @export(Dummy_Handler, .{ .name = "DebugMon_Handler", .linkage = .Weak });
}
fn DebugMon_Handler() callconv(.C) void {}

comptime {
    @export(Dummy_Handler, .{ .name = "PendSV_Handler", .linkage = .Weak });
}
fn PendSV_Handler() callconv(.C) void {}

// extern fn SysTick_Handler() void;
comptime {
    @export(Dummy_Handler, .{ .name = "SysTick_Handler", .linkage = .Weak });
}
fn SysTick_Handler() callconv(.C) void {}

// Exception and Interrupt vectors
export const vector_table linksection(".isr_vector") = [_]?extern fn () void{
    _estack,
    Reset_Handler,
    NMI_Handler,
    HardFault_Handler,
    MemManage_Handler,
    BusFault_Handler,
    UsageFault_Handler,
    null,
    null,
    null,
    null,
    SVC_Handler,
    DebugMon_Handler,
    null,
    PendSV_Handler,
    SysTick_Handler,
};
