PYTHON = python3
IVERILOG = iverilog
VVP = vvp
TOOLCHAIN_PREFIX = riscv64-unknown-elf-

FIRMWARE_OBJS = bootloader.o test_program.o
VERILOG_OBJS = alu.v RegisterFile.v riscv_template.v mcu_template.v mcu_guia6_tb.v

.PHONY: test clean
test: tb_mcu.vvp test_program.hex sram.hex
	$(VVP) tb_mcu.vvp

tb_mcu.vvp: $(VERILOG_OBJS)
	$(IVERILOG) -g2012 -s tb_mcu -o $@ $^

test_program.hex: test_program.bin makehex.py
	$(PYTHON) makehex.py $< 4096 > $@

sram.hex: sram.bin makehex_offset.py
	$(PYTHON) makehex_offset.py $< 4096 1024 > $@

test_program.bin: test_program.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary --only-section=.flash $< $@

sram.bin: test_program.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary --only-section=.sram $< $@

test_program.elf: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc -mabi=ilp32 -march=rv32i -nostdlib -ffreestanding -fno-pic -msmall-data-limit=0 \
		-Wl,--no-relax,--build-id=none,-Bstatic,-T,sections.lds,-Map,test_program.map \
		-o $@ $(FIRMWARE_OBJS) -lgcc

bootloader.o: bootloader.s
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -mabi=ilp32 -o $@ $<

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32i -Os -ffreestanding -nostdlib \
		-fno-pic -msmall-data-limit=0 -o $@ $<

clean:
	rm -f $(FIRMWARE_OBJS) test_program.elf test_program.bin sram.bin \
		test_program.hex sram.hex test_program.map tb_mcu.vvp tb_mcu_guia6_c.vcd
