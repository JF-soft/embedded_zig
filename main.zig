usingnamespace @import("stm32f10.zig");

export fn main() void {
    // initialize System
    SystemInit();

    RCC.*.APB2ENR |= RCC_APB2Periph_GPIOB; // enable GPIOC clk

    GPIOB.*.CRH &= ~@as(u32, 0b1111 << 16); // PB12
    GPIOB.*.CRH |= @as(u32, 0b0010 << 16); // Out PP, 2MHz

    while (true) {
        GPIOB.*.ODR ^= GPIO_PIN_12; // toggle
        var i: u32 = 0;
        while (i < 1000000) {
            asm volatile ("nop");
            i += 1;
        }
    }
}
