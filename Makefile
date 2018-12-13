IVERILOG = iverilog

IVFLAGS = -DSIM

RISCV_CROSS_COMPILE ?= /opt/abcross/riscv64/bin/riscv64-aosc-linux-gnu-

RISCV_AS = $(RISCV_CROSS_COMPILE)as
RISCV_GCC = $(RISCV_CROSS_COMPILE)gcc
RISCV_LD = $(RISCV_CROSS_COMPILE)ld
RISCV_OBJCOPY = $(RISCV_CROSS_COMPILE)objcopy

TD ?= td

VERILOG_SOURCES = top.v \
		  wb_ram_1.0/rtl/verilog/wb_ram.v wb_ram_1.0/rtl/verilog/wb_ram_generic.v \
		  wb_intercon.v wb_intercon_1.1/rtl/verilog/wb_mux.v \
		  picorv32_wrapper.v \
		  uart16550_1.5.4/rtl/verilog/uart_top.v uart16550_1.5.4/rtl/verilog/uart_wb.v uart16550_1.5.4/rtl/verilog/uart_regs.v uart16550_1.5.4/rtl/verilog/uart_receiver.v uart16550_1.5.4/rtl/verilog/uart_transmitter.v uart16550_1.5.4/rtl/verilog/uart_rfifo.v uart16550_1.5.4/rtl/verilog/uart_tfifo.v uart16550_1.5.4/rtl/verilog/raminfr.v uart16550_1.5.4/rtl/verilog/uart_sync_flops.v

VVP = vvp

%.vcd: %.vvp
	$(VVP) $(VVPFLAGS) -n $<

sim: top_tb.vcd
bitstream: picorv32-wb-test.bit

top_tb.vcd: top_tb.vvp firmware.hex

top_tb.vvp: top_tb.v $(VERILOG_SOURCES)
	iverilog $(IVFLAGS) -s top_tb -o top_tb.vvp top_tb.v $(VERILOG_SOURCES)
wb_intercon.v: wb_intercon.conf
	utils/wb_intercon_gen $< $@

wb_intercon.vh: wb_intercon.v

start.o: start.S
	$(RISCV_AS) -march=rv32i $< -o $@

main.o: main.c
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 -c $< -o $@

firmware.elf: main.o start.o ldscript.lds
	$(RISCV_LD) start.o main.o -m elf32lriscv -T ldscript.lds -o $@

firmware.bin: firmware.elf
	$(RISCV_OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin gen_4bword_hex
	./gen_4bword_hex < firmware.bin > firmware.hex

firmware.mif: firmware.bin gen_mif
	./gen_mif 1024 < firmware.bin > firmware.mif

picorv32-wb-test.bit: picorv32-wb-test.al td.tcl $(VERILOG_SOURCES) firmware.mif
	$(TD) td.tcl
