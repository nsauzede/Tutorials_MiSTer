`timescale 1ns / 1ps
`include "../rtl/config.vh"

module dut #(
    parameter integer BOARD_CK = 50000000,
//    parameter INIT_FILE = "../sim7/darksocv.hex"
//    parameter INIT_FILE = "/home/nico/perso/git/Tutorials_MiSTer/NS2/sim7/darksocv.hex"
    parameter INIT_FILE = "/home/nico/perso/git/Tutorials_MiSTer/NS2/sim4/darksocv_padded.hex"
//    parameter INIT_FILE = "../sim4/darksocv_padded.hex"
) (
    input XCLK,
    input XRES,

    input RXD,
    output TXD,
`ifdef SIMULATION
    output [7:0] UARTQ,     // UART OUT
`endif
    output [7:0] leds,

    output [3:0] LED,       // on-board leds
    output [3:0] DEBUG      // osciloscope
);

    // clock and reset

    wire CLK,RES;

    darkpll darkpll0
    (
        .XCLK(XCLK),
        .XRES(XRES),
        .CLK(CLK),
        .RES(RES)
    );

    // darkbridge interface

    wire        XIRQ;
    wire        XDREQ;
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XWR,
                XRD;
    wire [3:0]  XBE;
    wire [3:0]  XDREQMUX;

    assign XDREQMUX[0] = XDREQ && XADDR[31:30]==0;
    assign XDREQMUX[1] = XDREQ && XADDR[31:30]==1;
    assign XDREQMUX[2] = XDREQ && XADDR[31:30]==2;
    assign XDREQMUX[3] = XDREQ && XADDR[31:30]==3;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];

    // darkriscv

    wire [3:0]  KDEBUG;

    wire        ESIMREQ,ESIMACK;

    wire        HLT;

    wire        IDREQ;
    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire        IDACK;

    darkbridge
    bridge0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XXDREQ  (XDREQ),
        .XXADDR  (XADDR),
        .XXATAI  (XATAIMUX[XADDR[31:30]]),
        .XXATAO  (XATAO),
        .XXRD    (XRD),
        .XXWR    (XWR),
        .XXBE    (XBE),
        .XXDACK  (XDACKMUX[XADDR[31:30]]),

`ifdef __HARVARD__
        .YDREQ  (IDREQ),
        .YADDR  (IADDR),
        .YDATA  (IDATA),
        .YDACK  (IDACK),
`endif

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (KDEBUG)
    );

    // bram memory w/ CS==0

    darkram #(.INIT_FILE(INIT_FILE)) bram0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

        .IDREQ  (IDREQ),
        .IADDR  (IADDR),
        .IDATA  (IDATA),
        .IDACK  (IDACK),

        .XDREQ  (XDREQMUX[0]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[0]),
        .XDACK  (XDACKMUX[0])
    );

    // io block w/ CS==1

    wire [3:0] IODEBUG;

    darkio io0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XDREQ  (XDREQMUX[1]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[1]),
        .XDACK  (XDACKMUX[1]),

        .RXD    (RXD),
        .TXD    (TXD),
`ifdef SIMULATION
        .UARTQ  (UARTQ),
`endif

        .LED    (LED),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (IODEBUG)
    );

//    assign leds = UARTQ;
    reg [7:0] ledsx = 8'h55;
    assign leds = ledsx;
/*
    always@(posedge CLK) begin
        if (RES) ledsx <= 0;
        else ledsx <= IDATA[7:0];
    end
*/

    // sdram w/ CS==2
`ifdef __SDRAM__
error_sdram_is_not_implemented();
`else
    reg [3:0] DTACK2 = 0;
    reg       PRINT2 = 1;

    always@(posedge CLK)
    begin
        DTACK2 <= RES ? 0 : DTACK2 ? DTACK2-1 : XDREQMUX[2] ? 13 : 0;
        if(XDREQMUX[2] && PRINT2)
        begin
            $display("sdram: unmapped addr=%x",XADDR);
            PRINT2 <= 0;
        end
    end
`endif

    assign XATAIMUX[2] = 32'hdeadbeef;
    assign XDACKMUX[2] = DTACK2==1;

    // unmapped area w/ CS==3

    reg [3:0] DTACK3 = 0;
    reg PRINT3 = 1;

    always@(posedge CLK)
    begin
        DTACK3 <= RES ? 0 : DTACK3 ? DTACK3-1 : XDREQMUX[3] ? 1 : 0;
        if(XDREQMUX[3] && PRINT3)
        begin
            $display("sdram: unmapped addr=%x",XADDR);
            PRINT3 <= 0;
        end
    end

    assign XATAIMUX[3] = 32'hdeadbeef;
    assign XDACKMUX[3] = DTACK3==1;

    assign DEBUG = KDEBUG;

endmodule
