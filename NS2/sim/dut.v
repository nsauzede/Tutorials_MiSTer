`timescale 1ns / 1ps

module dut(
    input           CLK,            // clock
    input           RES,            // reset

    input           RD,             // bus read
    input           WR,             // bus write
    input  [ 3:0]   BE,             // byte enable
    input  [31:0]   DATAI,          // data input
    output [31:0]   DATAO,          // data output
    output          IRQ,            // interrupt req

    input           RXD,            // UART recv line
    output          TXD,            // UART xmit line

`ifdef SIMULATION
    output reg      ESIMREQ = 0,
    input           ESIMACK,
`endif

    output [3:0]    DEBUG           // osc debug
);
/*
    reg CLK;
    reg RES;
    reg RD;
    reg WR;
    reg [3:0] BE;
    reg [31:0] DATAI;
    wire [31:0] DATAO;
    wire IRQ;
    reg RXD;
    wire TXD;
    reg ESIMACK;
    wire [3:0] DEBUG;
*/

    darkuart uut (
        .CLK(CLK),
        .RES(RES),
        .RD(RD),
        .WR(WR),
        .BE(BE),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .IRQ(IRQ),
        .RXD(RXD),
        .TXD(TXD),
`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif
        .DEBUG(DEBUG)
    );

endmodule
