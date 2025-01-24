
TOP:=Vmux2
V_SRC:=mux2.v
C_SRC:=tb_mux2.cpp

SRC:=$(V_SRC) $(C_SRC)
OBJ_DIR:=obj_dir
LINTED:=.linted
VCD_FILE:=waveform.vcd

VLATOR:=verilator
AT:=@

VOPT:=--trace

all: lint simulate

GTKW:=$(TOP).gtkw
view: ./$(VCD_FILE)
	gtkwave $< $$(test -f $(GTKW) && echo $(GTKW))

verilate: ./$(OBJ_DIR)/Vmux2.mk
./$(OBJ_DIR)/Vmux2.mk: $(SRC)
	$(VLATOR) $(VOPT) --cc --exe $^ && touch $@

./$(OBJ_DIR)/$(TOP): ./$(OBJ_DIR)/Vmux2.mk
	$(MAKE) -C ./$(OBJ_DIR) -f Vmux2.mk

simulate: ./$(OBJ_DIR)/$(TOP)
	$(AT)$<

./$(LINTED): $(V_SRC)
	$(VLATOR) --lint-only $^ && touch $@

lint: ./$(LINTED)

clean:
	rm -rf ./$(OBJ_DIR) ./$(LINTED) ./$(VCD_FILE)
