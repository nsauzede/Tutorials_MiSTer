#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
/******************************************************************************/
#include <stdio.h>
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
        EXPECT_EQ(dut->out, 0);
        step(4);
        dut->reset = 1;
        EXPECT_EQ(dut->out, 2);
        step(3);
        dut->reset = 0;
        EXPECT_EQ(dut->out, 0);
        step(4);
        EXPECT_EQ(dut->out, 2);
        step();
        if (tfp){tfp->close();delete tfp;}
        delete dut;
    }
    void step(int n = 1, int inc = 10) {
        for (int i = 0; i < n; i++) {
            dut->eval();
            if(tfp)tfp->dump(Verilated::time());
            printf("Time %ld: %d %d %d\n", Verilated::time(), dut->clk, dut->reset, dut->out);
            Verilated::timeInc(inc);
            dut->clk = !dut->clk;
        }
    }
};
