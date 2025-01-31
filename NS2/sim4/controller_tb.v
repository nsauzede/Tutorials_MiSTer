module controller_tb;
    reg clk;
    reg RES;
    reg uart_done;
    reg [7:0] data_in;
    wire [7:0] uart_data;
    wire uart_start;
    wire [31:0] addr;

    controller uut (
        .clk(clk),
        .RES(RES),
        .uart_done(uart_done),
        .data_in(data_in),
        .uart_data(uart_data),
        .uart_start(uart_start),
        .addr(addr)
    );

    always #5 clk = ~clk; // 10 time unit clock period

    initial begin
        $dumpfile("controller_tb.vcd");
        $dumpvars(0, controller_tb);

        clk = 0;
        RES = 1;
        uart_done = 0;
        data_in = 8'h00;
        #20;

        RES = 0;

        // Test case 1: data_in = 0x6F
        data_in = 8'h6F;
        #20; // Wait for FSM to start

        uart_done = 1; #10; uart_done = 0; // Simulate first UART completion
        #20;

        uart_done = 1; #10; uart_done = 0; // Simulate second UART completion
        #50;

        // Test case 2: data_in = 0xB7
        data_in = 8'hB7;
        #20; // Wait for FSM to start

        uart_done = 1; #10; uart_done = 0; // Simulate first UART completion
        #20;

        uart_done = 1; #10; uart_done = 0; // Simulate second UART completion
        #50;

        $finish;
    end
endmodule
