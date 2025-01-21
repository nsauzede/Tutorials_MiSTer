DUT:=soc_icarus
SRC:=dpram.v ../rtl/vga.v ../rtl/soc.v soc_tb.v
IVOPT:=-D DUT_VCD=\"$(DUT).vcd\" -D SIMULATION

all: image.hex $(DUT).vcd

image.hex: ../rtl/image.hex
	./conv.py $< $@

view: $(DUT).vcd
	[ -f $(DUT).gtkw ] && (gtkwave $< $(DUT).gtkw &) || (gtkwave $< &)

$(DUT).vcd: $(DUT).output
	vvp $<

$(DUT).output: $(SRC)
	iverilog $(IVOPT) -o $@ $^

clean:
	rm -f $(DUT).output $(DUT).vcd image.hex
