`timescale 1ns / 1ps
`include "../rtl/config.vh"
module dut_tb;
    parameter integer BOARD_CK = 64;
//    parameter integer BOARD_CK = 50000000;

    localparam clk_period = 10;

    reg CLK = 0;
    reg RES = 0;
    wire from_dut, to_dut;
    wire [7:0]  UARTQ;     // UART OUT
    wire [7:0] leds;
    wire [31:0] datao;
    reg [31:0] datai;
    reg rd, wr;
    wire irq;
    reg [3:0] be;

    dut #(.BOARD_CK(BOARD_CK))
    dut1 (
        .RXD(to_dut),
        .TXD(from_dut),
`ifdef SIMULATION
        .UARTQ  (UARTQ),
`endif
        .leds(leds),
        .XRES(RES),
        .XCLK(CLK)
    );
    darkuart uart_inst (
        .CLK(CLK),
        .RES(RES),
        .RD(rd),
        .WR(wr),
        .BE(be),
        .DATAI(datai),
        .DATAO(datao),
        .IRQ(irq),
        .RXD(from_dut),
        .TXD(to_dut),
        .ESIMREQ(),
        .ESIMACK(1'b0),
        .DEBUG()
    );

    always begin
        #5 CLK = ~CLK;
    end

    initial begin
        $dumpfile("dut_tb.vcd");
        $dumpvars(0, dut_tb);
        CLK = 0;
        RES = 1;
        datai = 32'b0;
        be = 4'b1111;
        wr = 0;
        rd = 0;

        $display("reset (startup) %d %d %d %d", `BOARD_ID, `BOARD_CK, `__UARTSPEED__, `__BAUD__);
        #1e3     RES = 1'b0;
rd = 1;
/*
        //wait(leds == 8'h13);
        //#100    // wait enough for the next value
        $display("Received data displayed on LEDs: %h at %0t", leds, $time);
        datai = 32'h1;
        #20 datai = 32'h0;

        wait(irq == 1);
        #20 rd = 1;
//        #20 rd = 0;
        wait(irq == 0);
        if (datao[15:8] == 8'h31) begin
            $display("Received data: %h", datao[15:8]);
        end else begin
            $display("Received BAD data: %h", datao[15:8]);
//            $finish;
        end

        #40
//        $display("The end for now...");
//        #1000 $finish;
*/
        // Wait more and finish
        #510695
        $finish;
    end
endmodule
