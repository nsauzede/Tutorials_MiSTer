
TBV:=$(shell find . -path '*/.*/*' -prune -o \( -type f -name '*_tb.v' -print \))
ifeq ($(TBV),)
$(error No Verilog Testbench found ? Must create at least eg: <some dut>_tb.v)
endif
TB:=$(patsubst %_tb.v,%_tb,$(TBV))
VCD:=$(patsubst %_tb.v,%_tb.vcd,$(TBV))
TARGET:=$(VCD)

all: $(TARGET)

GTKW=$$tb".gtkw"
view: $(VCD)
	@for tb in $(TB); do (gtkwave $$tb".vcd" $$(test -f $(GTKW) && echo $(GTKW)) &) ; done
#	@for tb in $(TB); do (gtkwave -pipe $$tb.pipe $$tb".vcd" $$(test -f $(GTKW) && echo $(GTKW)) &) ; done

# Default automatic dep is:
#       mydut_tb.vvp: mydut_tb.v
# If a testbench has more deps, place deps overrides here, eg:
#       mydut_tb.vvp: mydut_tb.v mydut.v extra_dep1.v ..
dut_tb.vvp: dut_tb.v dut.v ../rtl/darkram.v ../rtl/darkuart.v ../rtl/darkio.v ../rtl/darkpll.v

.PRECIOUS: %.vvp %.vcd

%_tb: %_tb.vcd
%.vcd: %.vvp
	vvp $<

VOPT:=-DSIMULATION=1 -D__UARTSPEED__=100000000
VOPT+=-DBOARD_ID=0 -DBOARD_CK=50000000
%.vvp: %.v
	iverilog -o $@ $^ $(VOPT)

clean:
	$(RM) *.vvp *.vcd
