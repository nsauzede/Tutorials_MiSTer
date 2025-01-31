module controller(
    input wire clk,
    input wire RES,
    input wire uart_done,
    input wire [7:0] data_in,
    output reg [7:0] uart_data,
    output reg uart_start,
    output reg [31:0] addr
);

    parameter BOARD_CK = 32'd50000000; // Example clock frequency

    reg [31:0] count;
    reg [3:0] state;

    localparam IDLE       = 4'd0,
               SEND_DIGIT1 = 4'd1,
               WAIT_DIGIT1 = 4'd2,
               SEND_DIGIT2 = 4'd3,
               WAIT_DIGIT2 = 4'd4;

    function [7:0] nibble_to_ascii;
        input [3:0] nibble;
        begin
            if (nibble < 4'ha)
                nibble_to_ascii = 8'h30 + nibble;
            else
                nibble_to_ascii = 8'h41 + (nibble - 4'ha);
        end
    endfunction

    always @(posedge clk or posedge RES) begin
        if (RES) begin
            count <= 0;
            addr <= 0;
            uart_data <= 0;
            uart_start <= 0;
            state <= IDLE;
        end else begin
            if (count > BOARD_CK) begin
                count <= 0;
                addr <= addr + 1;
            end else begin
                count <= count + 1;
                if (count == 1) begin
                    state <= SEND_DIGIT1;
                end
            end

            case (state)
                IDLE: begin
                    uart_start <= 0;
                end

                SEND_DIGIT1: begin
                    uart_data <= nibble_to_ascii(data_in[7:4]); // Convert upper nibble to ASCII
                    uart_start <= 1;
                    state <= WAIT_DIGIT1;
                end

                WAIT_DIGIT1: begin
                    if (uart_done) begin
                        uart_start <= 0;
                        state <= SEND_DIGIT2;
                    end
                end

                SEND_DIGIT2: begin
                    uart_data <= nibble_to_ascii(data_in[3:0]); // Convert lower nibble to ASCII
                    uart_start <= 1;
                    state <= WAIT_DIGIT2;
                end

                WAIT_DIGIT2: begin
                    if (uart_done) begin
                        uart_start <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
