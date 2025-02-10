module dut #(
    parameter integer BOARD_CK = 50000000,
    parameter INIT_FILE = "../sim4/darksocv_padded.hex"
) (
    input RXD,
    output TXD,
    output [7:0] leds,
    input RES,
    input CLK
);
    reg [31:0] count = 32'b0;
    reg [29:0] addr = 30'b0;

    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire IDACK;
    wire [31:0] XATAO;
    wire XDACK;

    wire [31:0] datao;
    reg [31:0] datai;
    reg rd, rdff, wr, wrff;
    wire irq;
    reg [3:0] be;
    reg irq_prev;
    reg tx_busy, tx_busy2;
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

    assign IADDR = {addr,2'b0};
    assign leds = IDATA[7:0];
//    assign leds = 8'h55;
    always @(posedge CLK or posedge RES) begin
        if (RES) begin
            count <= 32'b0;
            addr <= 30'd0;
            datai <= 0;
            rd <= 0;
            wr <= 0;
            wrff <= 0;
            tx_busy <= 0;
            tx_busy2 <= 0;
            be <= 4'b1111;
            irq_prev <= 1'b0;
        end else begin
            irq_prev <= irq;
            if (count >= BOARD_CK) begin
                count <= 32'b0;
                addr <= addr + 1;
            end else begin
                count <= count + 1;
                if (count == 1 && !tx_busy) begin
                    wrff <= 1;
                    datai[15:8] <= (IDATA[7:4]<4'ha)?{4'h3, IDATA[7:4]}:{4'h4, IDATA[7:4]-4'ha+4'h1};
                    tx_busy <= 1;
                end
                if (tx_busy == 1) begin
                    if (wrff) begin
                        wr <= 1;
                        wrff <= 0;
                    end else if (wr) begin
                        wr <= 0;
                    end else if (!irq) begin
                        tx_busy <= 0;
                        wrff <= 1;
                        datai[15:8] <= (IDATA[3:0]<4'ha)?{4'h3, IDATA[3:0]}:{4'h4, IDATA[3:0]-4'ha+4'h1};
                        tx_busy2 <= 1;
                    end
                end
                if (tx_busy2 == 1) begin
                    if (wrff) begin
                        wr <= 1;
                        wrff <= 0;
                    end else if (wr) begin
                        wr <= 0;
                    end else if (!irq) begin
                        tx_busy2 <= 0;
                    end
                end
            end
        end
    end

    darkram #(.INIT_FILE(INIT_FILE)) u_bram (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (1'b0),

        .IDREQ  (1'b0),
        .IADDR  (IADDR),
        .IDATA  (IDATA),
        .IDACK  (IDACK),

        .XDREQ  (1'b0),
        .XRD    (1'b0),
        .XWR    (1'b0),
        .XBE    (4'hf),
        .XADDR  (0),
        .XATAI  (0),
        .XATAO  (XATAO),
        .XDACK  (XDACK)
    );
endmodule
