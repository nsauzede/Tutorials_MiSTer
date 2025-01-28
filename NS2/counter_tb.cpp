#include "Vcounter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
/******************************************************************************/
#include <stdio.h>
class TB {
    Vcounter* top;
    VerilatedVcdC* tfp;
public:
    TB(int argc = 0, char **argv = 0):top(0),tfp(0) {
        Verilated::commandArgs(argc, argv);
        top = new Vcounter;
#ifdef VCD_FILE
        tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->open(VCD_FILE);
#endif
        EXPECT_EQ(top->out, 0);
        step(4);
        top->reset = 1;
        EXPECT_EQ(top->out, 2);
        step(3);
        top->reset = 0;
        EXPECT_EQ(top->out, 0);
        step(4);
        EXPECT_EQ(top->out, 2);
        step();
        if (tfp){tfp->close();delete tfp;}
        delete top;
    }
    void step(int n = 1, int inc = 10) {
        for (int i = 0; i < n; i++) {
            top->eval();
            if(tfp)tfp->dump(Verilated::time());
            printf("Time %ld: %d %d %d\n", Verilated::time(), top->clk, top->reset, top->out);
            Verilated::timeInc(inc);
            top->clk = !top->clk;
        }
    }
};
