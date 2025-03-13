`timescale 1ns / 1ps

module darkspi_tb;
    // Parameters
    parameter integer SPI_DIV_COEF = 32'd1;

    localparam clk_period = 10;

    // Testbench signals
    reg CLK;
    reg RES = 1;
    reg RD;
    reg WR;
    reg [3:0] BE;
    reg [31:0] DATAI;
    wire [31:0] DATAO;
    wire IRQ;
    wire SCK;
    wire CSN;
    reg ESIMACK;
    wire [3:0] DEBUG;
    localparam
        DEBUG_0 = 8'hff,
        DEBUG_1 = 8'hfe,
        DEBUG_2 = 8'hfd,
        DEBUG_3 = 8'hfb,
        DEBUG_4 = 8'hf7,
        DEBUG_5 = 8'hef;
    reg [7:0] leds = DEBUG_0;
    wire x_l_flag;
    reg [15:0] x_l_response = 16'h9a00;

    // Instantiate the darkspi module
    darkspi #(.DIV_COEF(SPI_DIV_COEF)) darkspi1 (
        .CLK(CLK),
        .RES(RES),
        .RD(RD),
        .WR(WR),
        .BE(BE),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .IRQ(IRQ),
        .SCK(SCK),
        .MOSI(MOSI),
        .MISO(MISO),
        .CSN(CSN),
`ifdef SIMULATION
        .ESIMACK(ESIMACK),
`endif
        .DEBUG(DEBUG)
    );
    lis3dh_stub lis3dh_stub0 (
        .out_x_l_flag(x_l_flag),
        .out_x_l_response(x_l_response),
        .clk(CLK),
        .sck(SCK),
        .cs(CSN),
        .mosi(MOSI),
        .miso(MISO)
    );

    // Clock generation
    initial begin
        forever begin
            CLK = 1'b0;
            #(clk_period / 2);
            CLK = 1'b1;
            #(clk_period / 2);
        end
    end

    task spi_write_read_expect;
        input [3:0] be_in;
        input [31:0] data_in;
        input [31:0] expected_in;
    begin
        // Write SPI command
        BE = be_in;
        DATAI = data_in;
        WR = 1;
        wait (~CSN);
        WR = 0;
        // Wait for SPI Cycle to complete
        wait (CSN);#20
        // Read SPI response
        if (BE == 4'b0011) BE = 4'b0001;
        else if (BE == 4'b1111) BE = 4'b0011;
        RD = 1; #10; RD = 0; #10;
        BE = 0;
        if (DATAO != expected_in) begin
            $display("Bad SPI response: %08x (expected %08x)", DATAO, expected_in);
            $fatal(1);
        end
    end
    endtask
    integer i;
    // Testbench procedure
    initial begin
        // Initialize inputs
        RES = 1;
        RD = 0;
        WR = 0;
        BE = 4'b0000;
        DATAI = 32'h00000000;
        ESIMACK = 0;
        leds = DEBUG_0;

        // Enable waveform dump
        $dumpfile("darkspi_tb.vcd");
        $dumpvars(0, darkspi_tb);

        // Reset sequence
        #1e3       RES = 1'b0;

        leds = DEBUG_1;
        spi_write_read_expect(4'b0011, 32'h00008f00, 32'hzz33);
        leds = DEBUG_2;
        spi_write_read_expect(4'b0011, 32'h00002077, 32'hzz00);
        leds = DEBUG_3;
        spi_write_read_expect(4'b0011, 32'h00001fc0, 32'hzz00);
        leds = DEBUG_4;
        spi_write_read_expect(4'b0011, 32'h00002388, 32'hzz00);

        for (i = 0; i < 42; i = i + 1) begin
            spi_write_read_expect(4'b1111, 32'h00e80000, {16'hzz, x_l_response[7:0], x_l_response[15:8]});
            leds = 1 << ((x_l_response[15:8] + 8'Sb1000_0000) >> 5);
            //leds = x_l_response[15:8];
            x_l_response[15:8] = x_l_response[15:8] + 32;
        end

        $finish;
    end
endmodule
