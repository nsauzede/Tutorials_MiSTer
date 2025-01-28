DUT:=soc_icarus
SRC:=dpram.v ../rtl/vga.v ../rtl/soc.v soc_tb.v
IVOPT:=-D DUT_VCD=\"$(DUT).vcd\" -D SIMULATION

all: image.hex $(DUT).vcd

image.hex: ../rtl/image.hex
	./conv.py $< $@

view: $(DUT).vcd
	[ -f $(DUT).gtkw ] && (gtkwave $< $(DUT).gtkw) || (gtkwave $<)

$(DUT).vcd: $(DUT).output
	vvp $<

$(DUT).output: $(SRC)
	iverilog $(IVOPT) -o $@ $^

VOPT:=-cc -exe --trace --Mdir ./tmp
VOPT+=--timescale-override 1ns/1ps --timescale 1ns/1ps
VOPT+=+define+debug=1 +define+SIMULATION=1
VOPT+=--threads 3 --top-module soc_tb
#VOPT+=-CFLAGS x
#VOPT+=-LDFLAGS x
#VOPT+=--Wno-MULTIDRIVEN
VOPT+=--Wno-PINMISSING
VOPT+=--timing
V:=verilator
verilate:
	$(V) $(VOPT) $(SRC)

clean:
	rm -f $(DUT).output $(DUT).vcd image.hex
	rm -rf ./tmp
