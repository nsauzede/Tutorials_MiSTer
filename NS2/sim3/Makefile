
DUT:=darkuart

all: $(DUT)_tb.vcd

GTKW:=$(DUT)_tb.gtkw
view: $(DUT)_tb.vcd
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW))

$(DUT)_tb.vvp: ../rtl/$(DUT).v darkuart_dut.v $(DUT)_tb.v
	iverilog -o $@ $^ -DSIMULATION=1 -D__UARTSPEED__=100000000

$(DUT)_tb.vcd: $(DUT)_tb.vvp
	vvp $< && touch $@

clean:
	rm -f $(DUT)_tb.vcd $(DUT)_tb.vvp
