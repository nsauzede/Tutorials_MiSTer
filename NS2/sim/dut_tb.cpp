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
        int BAUD_PERIOD = 868; // 1/115200 seconds = ~8.68 microseconds - in 10 units

        dut->CLK = 0;
        dut->RES = 0;
        dut->RD = 0;
        dut->WR = 0;
        dut->BE = 0xF;
        dut->DATAI = 0;
        dut->RXD = 1;   // Idle UART state
        dut->ESIMACK = 0;
        step(2);
        dut->RES = 1;
        step(2);
        dut->RES = 0;

        step(1);
        dut->DATAI = 0x4100;
        dut->WR = 1;
        step(2);
        dut->WR = 0;

        step(BAUD_PERIOD * 10); // 1 start + 8 data + 1 stop bits
        EXPECT_EQ(dut->DATAO & 0xFF00, 0x4100);

        step(BAUD_PERIOD*2);

        step(200);
        if (tfp){tfp->close();delete tfp;}
        delete dut;
    }
    void step(int n = 1, int inc = 10) {
        //printf("%s: n=%d", __func__, n);fflush(stdout);
        for (int i = 0; i < n; i++) {
            dut->RXD = dut->TXD;
            dut->eval();
            if(tfp)tfp->dump(Verilated::time());
            Verilated::timeInc(inc/2);
            dut->CLK = !dut->CLK;
            dut->RXD = dut->TXD;
            dut->eval();
            if(tfp)tfp->dump(Verilated::time());
            //printf("Time %ld: %d %d %d\n", Verilated::time(), dut->CLK, dut->RES, dut->DEBUG);
            Verilated::timeInc(inc/2);
            dut->CLK = !dut->CLK;
        }
    }
};
