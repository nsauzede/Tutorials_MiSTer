module dpram #(
    parameter init_file = " ",
    parameter widthad_a = 8,
    parameter width_a = 8,
    parameter INIT_FILE  = "image.hex"
)(
    input  [widthad_a-1:0] address_a,
    input  [widthad_a-1:0] address_b,
    input                  clock_a,
    input                  clock_b,
    input  [width_a-1:0]   data_a,
    input  [width_a-1:0]   data_b,
    input                  wren_a,
    input                  wren_b,
    output reg [width_a-1:0]   q_a,
    output reg [width_a-1:0]   q_b
);

    // Declare the RAM array
    reg [width_a-1:0] ram [(2**widthad_a)-1:0];

    // Initialize the RAM from the memory file
    initial begin
        $readmemh(INIT_FILE, ram, 0, (2**widthad_a)-1);  // Use $readmemh for hex format, or $readmemb for binary format
    end

    // Synchronous RAM operations for Port A
    always @(posedge clock_a) begin
        if (wren_a) begin
            ram[address_a] <= data_a;         // Write data to the RAM at the given address for Port A
        end
        q_a <= ram[address_a];               // Read data from the RAM at the given address for Port A
    end

    // Synchronous RAM operations for Port B
    always @(posedge clock_b) begin
        if (wren_b) begin
            ram[address_b] <= data_b;         // Write data to the RAM at the given address for Port B
        end
        q_b <= ram[address_b];               // Read data from the RAM at the given address for Port B
    end

endmodule
