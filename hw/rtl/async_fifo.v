/*******************************************************
** NAME: async_fifo
** DESC: a native asynchronous fifo
********************************************************/

`include "common.vh"

module async_fifo (
    wclk,
    wresetn,
    wen,
    wdata,
    rclk,
    rresetn,
    ren,
    rdata,
    full,
    empty
);

//****** parameter ******//

parameter WIDTH = 256;
parameter DEPTH = 1024;

localparam ADDR_WIDTH = $clog2(DEPTH);

//****** interface ******//

input             wclk;
input             wresetn;
input             wen;
input [WIDTH-1:0] wdata;

input              rclk;
input              rresetn;
input              ren;
output [WIDTH-1:0] rdata;

output reg full;
output reg empty;

//****** internal signal ******//

reg [ADDR_WIDTH:0] wptr_bin;
reg [ADDR_WIDTH:0] rptr_bin;

wire [ADDR_WIDTH:0] wptr_bin_next;
wire [ADDR_WIDTH:0] rptr_bin_next;

reg [ADDR_WIDTH:0] wptr_gray;
reg [ADDR_WIDTH:0] wptr_gray_r;
reg [ADDR_WIDTH:0] wptr_gray_rr;
reg [ADDR_WIDTH:0] wptr_gray_rrr;

reg [ADDR_WIDTH:0] rptr_gray;
reg [ADDR_WIDTH:0] rptr_gray_r;
reg [ADDR_WIDTH:0] rptr_gray_rr;
reg [ADDR_WIDTH:0] rptr_gray_rrr;

wire [ADDR_WIDTH:0] wptr_gray_next;
wire [ADDR_WIDTH:0] rptr_gray_next;

wire mem_wen;
wire mem_ren;

wire [ADDR_WIDTH-1:0] mem_waddr;
wire [ADDR_WIDTH-1:0] mem_raddr;

reg empty_ahead;


//****** internal logic ******//

// write/read pointer
assign wptr_bin_next = wptr_bin + mem_wen;
assign rptr_bin_next = rptr_bin + mem_ren;

assign wptr_gray_next = wptr_bin ^ (wptr_bin >> 1);
assign rptr_gray_next = rptr_bin ^ (rptr_bin >> 1);

// judge fifo full/empty

// assign full  = (wptr_gray_next == {~rptr_gray_rrr[ADDR_WIDTH:ADDR_WIDTH-1], rptr_gray_rrr[ADDR_WIDTH-2:0]});
// assign empty = (rptr_gray == wptr_gray_rrr);

// opt timing - icap csib(empty->m_axis_tvalid)
always @(posedge wclk or negedge wresetn) begin
    if (~wresetn) begin
        full <= 'b0;
    end
    else begin
        full <= (wptr_gray_next == {~rptr_gray_rrr[ADDR_WIDTH:ADDR_WIDTH-1], rptr_gray_rrr[ADDR_WIDTH-2:0]});
    end
end

always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        empty <= 'b0;
    end
    else begin
        empty <= (rptr_gray == wptr_gray_rrr);
    end
end

// assign empty_ahead = (rptr_gray_next == wptr_gray_rr);  // One cycle ahead of the empty signal

always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        empty_ahead <= 'b0;
    end
    else begin
        empty_ahead <= (rptr_gray_next == wptr_gray_rr); // One cycle ahead of the empty signal
    end
end

// ram memory
assign mem_wen = wen & ~full;
assign mem_ren = (ren | empty) & (~empty_ahead);

assign mem_waddr = wptr_bin[ADDR_WIDTH-1:0];
assign mem_raddr = rptr_bin[ADDR_WIDTH-1:0];

// convert wptr when writing
always @(posedge wclk or negedge wresetn) begin
    if (~wresetn) begin
        {wptr_bin, wptr_gray} <= 'b0;
    end
    else begin
        {wptr_bin, wptr_gray} <= {wptr_bin_next, wptr_gray_next};
    end
end

// convert rptr when reading
always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        {rptr_bin, rptr_gray} <= 'b0;
    end
    else begin
        {rptr_bin, rptr_gray} <= {rptr_bin_next, rptr_gray_next};
    end
end

// synchronize wptr to rclk clock domain
always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        {wptr_gray_r, wptr_gray_rr, wptr_gray_rrr} <= 'b0;
    end
    else begin
        {wptr_gray_r, wptr_gray_rr, wptr_gray_rrr} <= {wptr_gray, wptr_gray_r, wptr_gray_rr};
    end
end

// synchronize rptr to wclk clock domain
always @(posedge wclk or negedge wresetn) begin
    if (~wresetn) begin
        {rptr_gray_r, rptr_gray_rr, rptr_gray_rrr} <= 'b0;
    end
    else begin
        {rptr_gray_r, rptr_gray_rr, rptr_gray_rrr} <= {rptr_gray, rptr_gray_r, rptr_gray_rr};
    end
end

// ram memory
simple_dual_port_ram # (
    .WIDTH  (WIDTH),
    .DEPTH  (DEPTH)
    ) u_simple_dual_port_ram_0 (
    .wclk   (wclk),
    .wen    (mem_wen),
    .waddr  (mem_waddr),
    .wdata  (wdata),
    .rclk   (rclk),
    .raddr  (mem_raddr),
    .ren    (mem_ren),
    .rdata  (rdata)
);


endmodule
