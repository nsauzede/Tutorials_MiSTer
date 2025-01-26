# UT project: "NS0", from UT version 0.0.13
# WARNING: do not put any explicit Make targets in this file!

UT_FAST:=0
UT_SLOW:=0
UT_NOPY:=1
UT_NOGT:=1
UT_VERBOSE:=0

# Usual macros (CFLAGS, CXXFLAGS, LDFLAGS, LDLIBS, LD_LIBRARY_PATH, ..) can be defined, eg:
#CXXFLAGS:=-I this/path -D THAT_SYMBOL ...
# Or even UT internal ones, like VGO (valgrind options), eg:
#VGO:=--suppressions=my_vg.supp --gen-suppressions=all

TOP:=counter
OBJ_DIR:=tmp
V_TOP:=V$(TOP)
V_TOP_:=$(OBJ_DIR)/$(V_TOP)
V_MK_:=$(V_TOP).mk
V_MK:=$(OBJ_DIR)/$(V_MK_)
V_SRC:=$(TOP).v

ifndef VERILATOR_ROOT
VERILATOR_ROOT:=/usr/share/verilator
endif

CXXFLAGS+=-I $(OBJ_DIR)
ifdef VERILATOR_ROOT
CXXFLAGS+=-I $(VERILATOR_ROOT)/include -Wno-sign-compare
endif

UT_CUSTOM_ALL+=$(V_MK)
UT_CUSTOM_DEPS+=$(V_MK)

LDLIBS+=$(OBJ_DIR)/$(V_TOP)*.o
LDLIBS+=$(OBJ_DIR)/verilated*.o

$(OBJ_DIR)/%.mk: $(V_SRC)
	$(MAKE) lint verilate && touch $@
	$(MAKE) -C $(OBJ_DIR) -f $(V_MK_) LIBS+="-lgtest -lgtest_main"
