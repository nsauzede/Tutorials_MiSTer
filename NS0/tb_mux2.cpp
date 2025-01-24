#include "Vmux2.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <stdio.h>

#ifndef VCD_FILE
#define VCD_FILE "waveform.vcd"
#endif

class TB {
    Vmux2* top;
    VerilatedVcdC* tfp;
public:
    TB(int argc, char **argv) {
        Verilated::commandArgs(argc, argv);
        top = new Vmux2;
        tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->open(VCD_FILE);

        step();

        top->a = 0;
        top->b = 1;
        top->sel = 0;

        step();

        top->sel = 1;

        step();

    step();

        tfp->close();
        delete top;
    }
    void step(int inc = 10) {
        top->eval();
        tfp->dump(Verilated::time());
        printf("Time %ld: %d %d %d %d\n", Verilated::time(), top->a, top->b, top->sel, top->y);
        Verilated::timeInc(inc); // Advance time by inc units
    }
};

int main(int argc, char *argv[]) {
    TB tb(argc, argv);
    return 0;
}
