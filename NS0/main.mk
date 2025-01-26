ifndef TOP
$(error Must define TOP)
endif

VTOP:=V$(TOP)
V_SRC:=$(TOP).v
C_SRC:=tb_$(TOP).cpp

SRC:=$(V_SRC) $(C_SRC)
TMP_DIR:=tmp
LINTED:=.linted
VCD_FILE:=waveform.vcd
GTKW:=$(TOP).gtkw

GUI_TOP:=--top-module $(TOP)
GUI_DIR:=tmp_gui
GUI_C_SRC:=$(VTOP)_gui.cpp
VOUT:=./$(GUI_DIR)/$(VTOP).cpp
GUI_CFLAGS:=-I/usr/include/imgui `sdl2-config --cflags` -DTOP=$(TOP)
GUI_LDFLAGS:=`sdl2-config --libs` -lGLEW -lGL -limgui
ifneq ($(shell grep buntu /etc/os-release),)
UBUNTU:=1
endif

AT_:=@
AT_1:=
AT:=$(AT_$(V))

VLATOR:=verilator
VOPT:=--trace
ifdef UBUNTU
# Ubuntu 24.04.1 ships a lib stb?! and verilator doesn't support --quiet-stats
GUI_LDFLAGS+=-lstb
else
VLATOR+=--quiet-stats
endif

all: simulate

gui: lint gui_
gui_: ./$(GUI_DIR)/$(VTOP)
	$(AT)./$<
$(VOUT): $(V_SRC) Makefile
	$(AT)$(VLATOR) -cc $(VOPT) -LDFLAGS "$(GUI_LDFLAGS) " --Mdir $(GUI_DIR) -exe $(V_DEFINE) $(V_INC) $(GUI_TOP) -CFLAGS $(GUI_CFLAGS) $(V_SRC) $(GUI_C_SRC) && touch $(VOUT)

./$(GUI_DIR)/$(VTOP): $(VOUT) $(GUI_C_SRC)
	(cd $(GUI_DIR); make -f $(VTOP).mk)

view: ./$(VCD_FILE)
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW)) &
./$(VCD_FILE): simulate

verilate: lint ./$(TMP_DIR)/$(VTOP).mk

./$(TMP_DIR)/$(VTOP).mk: $(SRC)
	$(AT)$(VLATOR) -cc $(VOPT) --Mdir $(TMP_DIR) -exe $^ && touch $@

./$(TMP_DIR)/$(VTOP): ./$(TMP_DIR)/$(VTOP).mk
	$(MAKE) -C ./$(TMP_DIR) -f $(VTOP).mk CXXFLAGS=-DVCD_FILE='\"$(VCD_FILE)\"'

simulate: lint simulate_
simulate_: ./$(TMP_DIR)/$(VTOP)
	$(AT)./$<

./$(LINTED): $(V_SRC)
	$(AT)$(VLATOR) --lint-only $^ && touch $@

lint: ./$(LINTED)

clean:
	$(AT)rm -rf ./$(TMP_DIR) ./$(LINTED) ./$(VCD_FILE) ./$(GUI_DIR)
	$(AT)ut clean
