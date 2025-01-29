`timescale 1ns / 1ps

module darkuart_tb;

    // Declare signals for DUT
    reg CLK;
    reg RES;
    wire [7:0] leds;
    wire from_dut;
    wire to_dut;

    // Declare signals for the second darkuart (for loopback)
    wire [31:0] datao;
    reg [31:0] datai;
    reg rd, wr;
    wire irq;
    reg [3:0] be;
    //reg [7:0] uart_rx_data;
    //wire uart_tx_data;

    // Instantiate the DUT (darkuart_dut)
    darkuart_dut dut (
        .CLK(CLK),
        .RES(RES),
        .leds(leds),
        .TXD(from_dut),
        .RXD(to_dut)
    );

    // Instantiate second darkuart (for loopback communication)
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

    // Clock generation
    always begin
        #5 CLK = ~CLK; // Generate a clock with a period of 10ns
    end

    // Testbench logic
    initial begin
        $dumpfile("darkuart_tb.vcd");
        $dumpvars(0, darkuart_tb);
        // Initialize signals
        CLK = 0;
        RES = 0;
        datai = 32'b0;
        be = 4'b1111;
        wr = 0;
        rd = 0;

        // Apply reset
        #20
        RES = 1;
        #20
        RES = 0;

        // Send 'A' (0x41) from uart_inst to DUT via TXD
        #20
        datai = 32'h4100; // Send 'A'
        wr = 1;
        #20 wr = 0;
        wait(irq == 1);
        wait(irq == 0);

        // Wait for the reception on the DUT and check the leds
        // The expected value for leds should be 'A' = 0x41
        wait(leds == 8'h41);
        $display("Received data displayed on LEDs: %h", leds);

        wait(irq == 1);
        #20
        rd = 1;
        #20
        rd = 0;
        wait(irq == 0);

        // The expected received value should be 'A' ^ 0x20 = 0x61 ('a')
        wait(datao[15:8] == 8'h61);
        $display("Received data XOR'd: %h", datao[15:8]);

        #500
        // Finish simulation
        $finish;
    end

endmodule

/*
module darkuart_tb_inf;

    reg CLK = 0;
    reg RES = 1;
    wire TXD_DUT, TXD_TST;
    wire RXD_DUT, RXD_TST;
    wire [7:0] leds;

    // Instantiate the DUT
    darkuart_dut dut (
        .CLK(CLK),
        .RES(RES),
        .leds(leds),
        .TXD(TXD_DUT),
        .RXD(RXD_TST)  // RX of DUT connected to TX of tester
    );

    // Instantiate the testing UART
    darkuart tester (
        .CLK(CLK),
        .RES(RES),
        .RD(rd_tst),
        .WR(wr_tst),
        .BE(4'b0001),
        .DATAI(datai_tst),
        .DATAO(datao_tst),
        .IRQ(irq_tst),
        .RXD(RXD_DUT),  // RX of tester connected to TX of DUT
        .TXD(TXD_TST),
        .ESIMREQ(),
        .ESIMACK(1'b0),
        .DEBUG()
    );

    // Tester control signals
    reg rd_tst = 0, wr_tst = 0;
    reg [31:0] datai_tst;
    wire [31:0] datao_tst;
    wire irq_tst;

    always #5 CLK = ~CLK;  // 10ns clock period

    initial begin
        $dumpfile("darkuart_tb.vcd");
        $dumpvars(0, darkuart_tb);
        // Reset sequence
        RES = 1;
        #20;
        RES = 0;
        #20;

        // Send 'A' (8'h41) via the tester UART
        datai_tst = 32'h00000041;
        wr_tst = 1;
        #10;
        wr_tst = 0;

        // Wait for IRQ from tester UART (Reception of modified byte)
        wait (irq_tst == 1);
        rd_tst = 1;
        #10;
        rd_tst = 0;

        // Check received byte (should be 'A' ^ 0x20 = 'a' = 8'h61)
        if (datao_tst[7:0] == 8'h61)
            $display("TEST PASSED: Received expected byte 'a' (0x61)");
        else
            $display("TEST FAILED: Expected 0x61, got %h", datao_tst[7:0]);

        // Check LED output
        if (leds == 8'h61)
            $display("TEST PASSED: LEDs show expected value 0x61");
        else
            $display("TEST FAILED: LEDs expected 0x61, got %h", leds);

        $finish;
    end

endmodule
*/
