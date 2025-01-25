
TOP:=mux2
VTOP:=V$(TOP)
V_SRC:=$(TOP).v
C_SRC:=tb_mux2.cpp

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
GUI_LDFLAGS:=`sdl2-config --libs` -lGLEW -lGL -limgui -lstb
GUI:=./$(GUI_DIR)/$(VTOP)

VLATOR:=verilator
AT:=@

VOPT:=--trace

all: lint simulate

gui: $(GUI)
	./$<
$(VOUT): $(V_SRC) Makefile
	$(VLATOR) -cc $(VOPT) -LDFLAGS "$(GUI_LDFLAGS) " --Mdir $(GUI_DIR) -exe $(V_DEFINE) $(V_INC) $(GUI_TOP) -CFLAGS $(GUI_CFLAGS) $(V_SRC) $(GUI_C_SRC) && touch $(VOUT)

#$(GUI): CXXFLAGS+=-DTOP=TEH_TOP
$(GUI): $(VOUT) $(GUI_C_SRC)
	(cd $(GUI_DIR); make -f $(VTOP).mk CXXFLAGS+=-DTHETOP='\"$(TOP)\"')

view: ./$(VCD_FILE)
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW))

verilate: lint ./$(TMP_DIR)/$(VTOP).mk

./$(TMP_DIR)/$(VTOP).mk: $(SRC)
	$(VLATOR) -cc $(VOPT) --Mdir $(TMP_DIR) -exe $^ && touch $@

./$(TMP_DIR)/$(VTOP): ./$(TMP_DIR)/$(VTOP).mk
	$(MAKE) -C ./$(TMP_DIR) -f $(VTOP).mk

simulate: ./$(TMP_DIR)/$(VTOP)
	$(AT)$<

./$(LINTED): $(V_SRC)
	$(VLATOR) --lint-only $^ && touch $@

lint: ./$(LINTED)

clean:
	$(AT)rm -rf ./$(TMP_DIR) ./$(LINTED) ./$(VCD_FILE) ./$(GUI_DIR)
