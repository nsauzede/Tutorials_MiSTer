module darkuart_dut (
    input wire CLK,
    input wire RES,
    output reg [7:0] leds,
    output wire TXD,
    input wire RXD
);

    wire [31:0] datao;
    reg [31:0] datai;
    reg rd, rdff, wr, wrff;
    wire irq;
    reg [3:0] be;

    reg irq_prev; // Track previous IRQ state
    //reg [7:0] rx_data;
    reg tx_busy;

    // Instantiate darkuart
    darkuart uart_inst (
        .CLK(CLK),
        .RES(RES),
        .RD(rd),
        .WR(wr),
        .BE(be),
        .DATAI(datai),
        .DATAO(datao),
        .IRQ(irq),
        .RXD(RXD),
        .TXD(TXD),
`ifdef SIMULATION
        .ESIMREQ(),
        .ESIMACK(1'b0),
`endif
        .DEBUG()
    );

    always @(posedge CLK or posedge RES) begin
        if (RES) begin
            leds <= 8'b0;
            datai <= 8'b0;
            rd <= 0;
            rdff <= 0;
            wr <= 0;
            wrff <= 0;
            tx_busy <= 0;
            be <= 4'b1111;
            irq_prev <= 1'b0;
        end else begin
            irq_prev <= irq; // Store previous IRQ state
            //rd <= 0;
            //wr <= 0;

            //if (!irq && irq_prev) begin  // Detect falling edge of IRQ
            if (irq && !irq_prev && !tx_busy) begin // Detect rising edge of IRQ    
                rd <= 1; // Start reading data
            end

            if (rd && !rdff) begin
                //rx_data <= datao[15:8] ^ 8'h20; // XOR received byte with 0x20
                leds <= datao[15:8];
                rdff <= 1;
                //datai <= {24'b0, rx_data}; // Prepare TX data
                if (datao[15:8] >= "A" && datao[15:8] <= "z")
                datai <= {16'b0, datao[15:8] ^ 8'h20, 8'b0}; // Prepare TX data
                else
                datai <= {16'b0, datao[15:8], 8'b0}; // Prepare TX data
            end else if (rdff) begin
                rd <= 0;
                rdff <= 0;
                wrff <= 1;
            end else if (wrff) begin
                //rd <= 0;
                wr <= 1;
                wrff <= 0;
            end else if (wr) begin
                wr <= 0;
                tx_busy <= 1;
            end else if (!irq) begin
                tx_busy <= 0;
            end
        end
    end

endmodule
