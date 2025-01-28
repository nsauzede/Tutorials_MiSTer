`timescale 1ns / 1ps

module darkuart_dut (
    input wire CLK,
    input wire RES,
    input wire greet,
    output wire TXD,
    input wire RXD
);
    // Signals for darkuart
    reg RD, WR;
    reg [3:0] BE;
    reg [31:0] DATAI;
    wire [31:0] DATAO;
    wire IRQ;

    // Instantiate the darkuart module
    darkuart uart (
        .CLK(CLK),
        .RES(RES),
        .RD(RD),
        .WR(WR),
        .BE(BE),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .IRQ(IRQ),
        .RXD(RXD),
        .TXD(TXD)
    );

    // UART baud rate for 115200 bps
    parameter BAUD_PERIOD = 8680; // 1/115200 seconds = ~8.68 microseconds

    // TX FIFO and message for greeting
    reg [7:0] tx_message [0:12];
    integer tx_index;

    initial begin
        // Initialize the message "Hello World!\n"
        tx_message[0] = "H";
        tx_message[1] = "e";
        tx_message[2] = "l";
        tx_message[3] = "l";
        tx_message[4] = "o";
        tx_message[5] = " ";
        tx_message[6] = "W";
        tx_message[7] = "o";
        tx_message[8] = "r";
        tx_message[9] = "l";
        tx_message[10] = "d";
        tx_message[11] = "!";
        tx_message[12] = "\n";
        tx_index = 0;
    end

    // Process to send "Hello World!\n" on greet
    always @(posedge greet) begin
        tx_index = 0;
        while (tx_index < 13) begin
            DATAI = {16'b0, tx_message[tx_index], 8'b0}; // Load byte into DATAI[15:8]
            WR = 1;
            #10;
            WR = 0;
            #(BAUD_PERIOD * 12); // Wait for byte transmission
            tx_index = tx_index + 1;
        end
    end

    // Drive RD low, as it is unused in this DUT
    always @(*) begin
        RD = 0;
    end
endmodule

module darkuart_tb;
    // Testbench signals
    reg CLK;
    reg RES;
    reg greet;
    wire TXD;
    wire RXD;

    // Instantiate the DUT
    darkuart_dut dut (
        .CLK(CLK),
        .RES(RES),
        .greet(greet),
        .TXD(TXD),
        .RXD(RXD)
    );

    // Loopback RXD to TXD
    assign RXD = TXD;

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100 MHz clock
    end

    initial begin
        // Initialize inputs
        RES = 0;
        greet = 0;

        // Enable waveform dump
        $dumpfile("darkuart_tb.vcd");
        $dumpvars(0, darkuart_tb);

        // Reset sequence
        #20;
        RES = 1;
        #20;
        RES = 0;

        // Trigger greet
        #50;
        greet = 1;
        #10;
        greet = 0;

        // Wait and finish
        #2000;
        $finish;
    end
endmodule
