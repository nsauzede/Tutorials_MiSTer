module dut #(
    parameter integer BOARD_CK = 50000000,
    parameter INIT_FILE = "../sim4/darksocv_padded.hex"
) (
    input RXD,
    output TXD,
    output [7:0] leds,
    input XRES,
    input XCLK
);

    // clock and reset

    wire CLK,RES;
    darkpll darkpll0
    (
        .XCLK(XCLK),
        .XRES(XRES),
        .CLK(CLK),
        .RES(RES)
    );

    wire [3:0] LED;     // on-board leds
    wire [3:0] DEBUG;   // osciloscope
    wire UART_RXD;      // UART receive line
    wire UART_TXD;      // UART transmit line
    reg HLT = 0;
    assign TXD = UART_TXD;
    assign UART_RXD = RXD;

    // darkbridge interface

    wire        XIRQ;
    wire        XDREQ;
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XWR,
                XRD;
    wire [3:0]  XBE;
    wire [3:0]  XDREQMUX;

    assign XDREQMUX[0] = XDREQ && XADDR[31:30]==0;
    assign XDREQMUX[1] = XDREQ && XADDR[31:30]==1;
    assign XDREQMUX[2] = XDREQ && XADDR[31:30]==2;
    assign XDREQMUX[3] = XDREQ && XADDR[31:30]==3;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];

    // io block w/ CS==1

    wire [3:0] IODEBUG;

    assign XDREQ = 1'b1;
    assign XRD = rd;
    assign XWR = wr;
    assign XBE = be;
    assign XADDR = 32'h40000004;
    assign XATAO = datai;
    darkio io0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XDREQ  (XDREQMUX[1]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[1]),
        .XDACK  (XDACKMUX[1]),

        .RXD    (UART_RXD),
        .TXD    (UART_TXD),

        .LED    (LED),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (IODEBUG)
    );
    reg [31:0] UDATA;
    reg [31:0] count = 32'b0;
    wire [31:0] IADDR;
    wire [31:0] IDATA;
    reg [29:0] addr = 30'b0;
    reg [31:0] datai;
    reg rd, wr;
    reg [3:0] be;
    reg tx_busy, tx_busy2;

    assign IADDR = {addr,2'b0};
    assign leds = IDATA[7:0];
    always @(posedge CLK or posedge RES) begin
        if (RES) begin
            UDATA <= 0;
            count <= 32'b0;
            addr <= 30'd0;
            datai <= 32'h00000000;
            rd <= 0;
            wr <= 0;
            tx_busy <= 0;
            tx_busy2 <= 0;
            be <= 4'b1111;
        end else begin
            UDATA <= XATAIMUX[1];
            if (count >= BOARD_CK) begin
                count <= 32'b0;
                addr <= addr + 1;
            end else begin
                count <= count + 1;
                if (count == 1 && !tx_busy) begin
                    wr <= 1;
                    rd <= 1;
                    datai[15:8] <= (IDATA[7:4]<4'ha)?{4'h3, IDATA[7:4]}:{4'h4, IDATA[7:4]-4'ha+4'h1};
                    tx_busy <= 1;
                end
                if (tx_busy == 1) begin
                    if (rd && wr) begin
                        if (UDATA[0]) begin
                            wr <= 0;
                        end
                    end else if (rd && !wr) begin
                        if (!UDATA[0]) begin
                            rd <= 1;
                            wr <= 1;
                            tx_busy <= 0;
                            datai[15:8] <= (IDATA[3:0]<4'ha)?{4'h3, IDATA[3:0]}:{4'h4, IDATA[3:0]-4'ha+4'h1};
                            tx_busy2 <= 1;
                        end
                    end
                end
                if (tx_busy2 == 1) begin
                    if (rd && wr) begin
                        if (UDATA[0]) begin
                            wr <= 0;
                        end
                    end else if (rd && !wr) begin
                        if (!UDATA[0]) begin
                            rd <= 0;
                            wr <= 0;
                            tx_busy2 <= 0;
                        end
                    end
                end
            end
        end
    end

    // bram memory w/ CS==0

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
        .XATAO  (),
        .XDACK  ()
    );

    assign DEBUG = IODEBUG;
endmodule
