module dut (
    input wire clk,
    input wire reset,
    output wire [3:0] out
);
    reg [3:0] count = 0;
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1;
    end
    assign out = count;
endmodule
