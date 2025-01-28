DUT?=dut

VDUT:=V$(DUT)
V_SRC+=$(DUT).v
C_SRC:=tb_$(DUT).cpp

SRC:=$(V_SRC) $(C_SRC)
TMP_DIR:=tmp
LINTED:=.linted
VCD_FILE:=$(DUT).vcd
GTKW:=$(DUT).gtkw
TOP_MODULE:=--top-module $(DUT)

GUI_DIR:=tmp_gui
GUI_C_SRC:=$(VDUT)_gui.cpp
GUI_VCD_FILE:=$(VDUT)_gui.vcd
VOUT:=./$(GUI_DIR)/$(VDUT).cpp
GUI_CFLAGS:=-I/usr/include/imgui `sdl2-config --cflags`
GUI_LDFLAGS:=`sdl2-config --libs` -lGLEW -lGL -limgui
ifneq ($(shell grep buntu /etc/os-release),)
UBUNTU:=1
endif

AT_:=@
AT_1:=
AT:=$(AT_$(V))

VLATOR:=verilator
VOPT+=--trace
ifdef UBUNTU
# Ubuntu 24.04.1 ships a lib stb?! and verilator doesn't support --quiet-stats
GUI_LDFLAGS+=-lstb
else
VLATOR+=--quiet-stats
endif

all: simulate

gui: lint gui_
gui_: ./$(GUI_DIR)/$(VDUT)
	$(AT)./$<
$(VOUT): $(V_SRC) Makefile
	$(AT)$(VLATOR) -cc $(VOPT) -LDFLAGS "$(GUI_LDFLAGS) " --Mdir $(GUI_DIR) -exe $(V_DEFINE) $(V_INC) $(TOP_MODULE) -CFLAGS $(GUI_CFLAGS) $(V_SRC) $(GUI_C_SRC) && touch $(VOUT)

./$(GUI_DIR)/$(VDUT): $(VOUT) $(GUI_C_SRC)
	(cd $(GUI_DIR); make -f $(VDUT).mk CXXFLAGS=-DVCD_FILE='\"$(GUI_VCD_FILE)\"')

view: ./$(VCD_FILE)
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW))
./$(VCD_FILE): simulate

verilate: lint ./$(TMP_DIR)/$(VDUT).mk

./$(TMP_DIR)/$(VDUT).mk: $(SRC)
	$(AT)$(VLATOR) -cc $(VOPT) $(TOP_MODULE) --Mdir $(TMP_DIR) -exe $^ && touch $@

./$(TMP_DIR)/$(VDUT): ./$(TMP_DIR)/$(VDUT).mk
	$(MAKE) -C ./$(TMP_DIR) -f $(VDUT).mk CXXFLAGS=-DVCD_FILE='\"$(VCD_FILE)\"'

simulate: lint simulate_
simulate_: ./$(TMP_DIR)/$(VDUT)
	$(AT)./$<

./$(LINTED): $(V_SRC)
	$(AT)$(VLATOR) --lint-only $(VOPT) $^ && touch $@

lint: ./$(LINTED)

clean:
	$(AT)rm -rf ./$(TMP_DIR) ./$(LINTED) ./$(VCD_FILE) ./$(GUI_VCD_FILE) ./$(GUI_DIR)
	$(AT)ut clean
