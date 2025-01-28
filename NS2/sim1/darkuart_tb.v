`timescale 1ns / 1ps

module darkuart_tb;
    // Testbench signals
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

    // Instantiate the darkuart module
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
        .ESIMACK(ESIMACK),
        .DEBUG(DEBUG)
    );

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
        RES = 1;
        RD = 0;
        WR = 0;
        BE = 4'b0010;
        DATAI = 32'h00000000;
        RXD = 1; // Idle UART state
        ESIMACK = 0;

        // Enable waveform dump
        $dumpfile("darkuart_tb.vcd");
        $dumpvars(0, darkuart_tb);

        // Reset sequence
        #20;
        RES = 1;
        #20;
        RES = 0;

        // Test transmission (write to TXD)
        #10;
        DATAI = 32'h00004100; // ASCII 'A'
        WR = 1;
        #20;
        WR = 0;

        // Wait for transmission to complete
        #(BAUD_PERIOD * 10); // 1 start + 8 data + 1 stop bits

        #(BAUD_PERIOD*2);

        // Test reception (simulate data coming in RXD)
        RXD = 0; // Start bit
        #(BAUD_PERIOD);

        // Transmit data bits (ASCII 'B' = 0x42)
        RXD = 0; // Bit 0
        #(BAUD_PERIOD);
        RXD = 1; // Bit 1
        #(BAUD_PERIOD);
        RXD = 0; // Bit 2
        #(BAUD_PERIOD);
        RXD = 0; // Bit 3
        #(BAUD_PERIOD);
        RXD = 0; // Bit 4
        #(BAUD_PERIOD);
        RXD = 0; // Bit 5
        #(BAUD_PERIOD);
        RXD = 1; // Bit 6
        #(BAUD_PERIOD);
        RXD = 0; // Bit 7
        #(BAUD_PERIOD);

        RXD = 1; // Stop bit
        #(BAUD_PERIOD);

        // Wait and finish
        #20000;
        $finish;
    end
endmodule
