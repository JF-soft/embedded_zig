# Disable built-in rules and variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# BUILD_FLAGS = --release-small -target thumbv7m-freestanding-none
BUILD_FLAGS = -mcpu cortex_m3 --release-small -target thumb-freestanding-eabi
LINKER_SCRIPT = STM32F103X8_FLASH.ld
LD_FLAGS = --gc-sections -nostdlib
OBJS = startup.o main.o
PROG = firmware

%.o: %.zig
	zig build-obj ${BUILD_FLAGS} $<

${PROG}: ${OBJS}
#	zig build-exe ${BUILD_FLAGS} $(OBJS:%=--object %) --name $@.elf --linker-script ${LINKER_SCRIPT} --version-script $@.map
	arm-none-eabi-ld ${OBJS} -o $@.elf -T ${LINKER_SCRIPT} -Map $@.map ${LD_FLAGS}

clean:
	rm -rf ${PROG}.* ${OBJS} $(OBJS:%.o=%.h) zig-cache

.PHONY: clean
