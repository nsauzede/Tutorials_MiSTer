#include "Vmux2.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
/******************************************************************************/
#include <stdio.h>
#ifndef VCD_FILE
#define VCD_FILE "waveform.vcd"
#endif
class TB {
    Vmux2* top;
    VerilatedVcdC* tfp;
public:
    TB(int argc = 0, char **argv = 0):top(0),tfp(0) {
        Verilated::commandArgs(argc, argv);
        top = new Vmux2;
#ifdef VCD_FILE
        tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->open(VCD_FILE);
#endif
        top->sel = 0;
        top->a = 0;
        top->b = 1;
        step();
        EXPECT_EQ(top->y, 0);

        top->a = 1;
        top->b = 0;
        step();
        EXPECT_EQ(top->y, 1);

        top->sel = 1;
        top->b = 0;
        step();
        EXPECT_EQ(top->y, 0);

        top->b = 1;
        step();
        EXPECT_EQ(top->y, 1);

        if (tfp){tfp->close();delete tfp;}
        delete top;
    }
    void step(int inc = 10) {
        top->eval();
        tfp->dump(Verilated::time());
        printf("%d %d %d %d\t at #%ld\n", top->a, top->b, top->sel, top->y, Verilated::time());
        Verilated::timeInc(inc);
    }
};
