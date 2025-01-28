`timescale 1ns / 1ps

module darkuart_tb;
    // Testbench signals
    reg CLK;
    reg RES;
    wire TXD1, TXD2;
    wire RXD1, RXD2;

    // Signals for darkuart 1
    reg RD1, WR1;
    reg [3:0] BE1;
    reg [31:0] DATAI1;
    wire [31:0] DATAO1;
    wire IRQ1;

    // Signals for darkuart 2
    reg RD2, WR2;
    reg [3:0] BE2;
    reg [31:0] DATAI2;
    wire [31:0] DATAO2;
    wire IRQ2;

    // Instantiate the first darkuart module
    darkuart uart1 (
        .CLK(CLK),
        .RES(RES),
        .RD(RD1),
        .WR(WR1),
        .BE(BE1),
        .DATAI(DATAI1),
        .DATAO(DATAO1),
        .IRQ(IRQ1),
        .RXD(RXD1),
        .TXD(TXD1)
    );

    // Instantiate the second darkuart module
    darkuart uart2 (
        .CLK(CLK),
        .RES(RES),
        .RD(RD2),
        .WR(WR2),
        .BE(BE2),
        .DATAI(DATAI2),
        .DATAO(DATAO2),
        .IRQ(IRQ2),
        .RXD(RXD2),
        .TXD(TXD2)
    );

    // Connect TXD of uart1 to RXD of uart2 and vice versa
    assign RXD1 = TXD2;
    assign RXD2 = TXD1;

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100 MHz clock
    end

    // UART baud rate for 115200 bps
    parameter BAUD_PERIOD = 8680; // 1/115200 seconds = ~8.68 microseconds

    // Testbench procedure
    initial begin
        // Initialize inputs
        RES = 0;
        RD1 = 0; WR1 = 0; BE1 = 4'b1111; DATAI1 = 32'h00000000;
        RD2 = 0; WR2 = 0; BE2 = 4'b1111; DATAI2 = 32'h00000000;

        // Enable waveform dump
        $dumpfile("darkuart_tb.vcd");
        $dumpvars(0, darkuart_tb);

        // Reset sequence
        #20;
        RES = 1;
        #20;
        RES = 0;

        // Test transmission from uart1 to uart2
        #10;
        DATAI1 = 32'h00004100; // ASCII 'A' in DATAI[15:8]
        WR1 = 1;
        #10; // Ensure WR is active for one clock cycle
        WR1 = 0;

        // Wait for data to be transmitted and received
        #(BAUD_PERIOD * 12); // 1 start + 8 data + 1 stop + buffer

        // Read the received data from uart2
        RD2 = 1;
        #10;
        RD2 = 0;

        // Test transmission from uart2 to uart1
        #10;
        DATAI2 = 32'h00004200; // ASCII 'B' in DATAI[15:8]
        WR2 = 1;
        #10; // Ensure WR is active for one clock cycle
        WR2 = 0;

        // Wait for data to be transmitted and received
        #(BAUD_PERIOD * 12); // 1 start + 8 data + 1 stop + buffer

        // Read the received data from uart1
        RD1 = 1;
        #10;
        RD1 = 0;

        // Wait and finish
        #200;
        $finish;
    end
endmodule
