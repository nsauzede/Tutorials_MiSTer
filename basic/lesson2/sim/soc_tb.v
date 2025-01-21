`timescale 1ns / 1ps
`ifndef DUT_VCD
`define DUT_VCD "soc_tb.vcd"
`endif
module soc_tb;
    // Parameters
    parameter integer SHIFT = 0; // Counter shift to increment the address
    parameter integer BOARD_CK = 32000000;

    localparam clk_period = 10;

    reg clk = 0;
    reg reset = 0;

assign CLK_VIDEO = clk;
wire CLK_VIDEO;
wire copy_in_progress;
wire VGA_HS;
wire VGA_VS;
wire [7:0] VGA_R;
wire [7:0] VGA_G;
wire [7:0] VGA_B;
wire VGA_DE;

soc soc1(
   .pixel_clock(CLK_VIDEO),
   .joy(0),
   .progress(copy_in_progress),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_DE(VGA_DE)
);

    // Clock generation
    initial begin
        forever begin
            clk = 1'b0;
            #(clk_period / 2);
            clk = 1'b1;
            #(clk_period / 2);
        end
    end

    // Stimulus process
    initial begin
        $dumpfile(`DUT_VCD);
        $dumpvars(0, soc1);
        // Hold reset state for 100 ns
        #100;

        // Insert stimulus
        reset = 1'b1;
        #(clk_period * 2);
        reset = 1'b0;

        // Additional stimulus or waiting
        #(clk_period * 333333); // display a complete VGA image

        // Wait more and finish
`ifndef __ICARUS__
        #1000
`endif
        $finish;
    end
endmodule

