
DUT:=darkspi
IVOPT:=-DSIMULATION=1

all: $(DUT)_tb.vcd

GTKW:=$(DUT)_tb.gtkw
view: $(DUT)_tb.vcd
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW)) &

$(DUT)_tb.vvp: $(DUT).v $(DUT)_tb.v spi_master.v lis3dh_stub.v
	iverilog $(IVOPT) -o $@ $^

$(DUT)_tb.vcd: $(DUT)_tb.vvp
	vvp $< && touch $@

clean:
	rm -f $(DUT)_tb.vcd $(DUT)_tb.vvp
