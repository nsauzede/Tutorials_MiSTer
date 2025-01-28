#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
/******************************************************************************/
#include <stdio.h>
#ifndef VCD_FILE
#define VCD_FILE "dut.vcd"
#endif
class TB {
    Vdut* dut;
    VerilatedVcdC* tfp;
public:
    TB(int argc = 0, char **argv = 0):dut(0),tfp(0) {
        Verilated::commandArgs(argc, argv);
        dut = new Vdut;
#ifdef VCD_FILE
        tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        dut->trace(tfp, 99);
        tfp->open(VCD_FILE);
#endif
        dut->sel = 0;
        dut->a = 0;
        dut->b = 0;
        step();
        EXPECT_EQ(dut->y, 0);

        dut->sel = 0;
        dut->a = 0;
        dut->b = 1;
        step();
        EXPECT_EQ(dut->y, 0);

        dut->sel = 1;
        step();
        EXPECT_EQ(dut->y, 1);

        dut->a = 1;
        step();
        EXPECT_EQ(dut->y, 1);

        dut->b = 0;
        step();
        EXPECT_EQ(dut->y, 0);

        dut->sel = 0;
        step();
        EXPECT_EQ(dut->y, 1);

        dut->a = 0;
        step();
        EXPECT_EQ(dut->y, 0);

        step();
        if (tfp){tfp->close();delete tfp;}
        delete dut;
    }
    void step(int inc = 10) {
        dut->eval();
        tfp->dump(Verilated::time());
        printf("%d %d %d %d\t at #%ld\n", dut->a, dut->b, dut->sel, dut->y, Verilated::time());
        Verilated::timeInc(inc);
    }
};
