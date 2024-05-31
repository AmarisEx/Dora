/*******************************************************
** NAME: axis_async_fifo
** DESC: an asynchronous fifo supporting axi stream 
**       interface
********************************************************/

`include "common.vh"

module axis_async_fifo (
    wclk,
    wresetn,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast,
    rclk,
    rresetn,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tdata,
    m_axis_tkeep,
    m_axis_tlast
);

//****** parameter ******//

parameter WWIDTH = 256;
parameter RWIDTH = 32;
parameter DEPTH = 1024; 

localparam FIFO_WWIDTH = WWIDTH + WWIDTH/8;
localparam FIFO_RWIDTH = RWIDTH + RWIDTH/8;
localparam FIFO_DEPTH = DEPTH;

//****** interface ******//

input                  wclk;
input                  wresetn;
input                  s_axis_tvalid;
output                 s_axis_tready;
input     [WWIDTH-1:0] s_axis_tdata;
input [(WWIDTH/8)-1:0] s_axis_tkeep;
input                  s_axis_tlast;

input                   rclk;
input                   rresetn;
output                  m_axis_tvalid;
input                   m_axis_tready;
output     [RWIDTH-1:0] m_axis_tdata;
output [(RWIDTH/8)-1:0] m_axis_tkeep;
output                  m_axis_tlast;

//****** internal signal ******//

wire                   fifo_wen;
reg  [FIFO_WWIDTH-1:0] fifo_wdata;
wire                   fifo_ren;
wire [FIFO_WWIDTH-1:0] fifo_rdata;
wire                   fifo_full;
wire                   fifo_empty;

reg  [FIFO_WWIDTH-1:0] fifo_rdata_r;
wire [FIFO_RWIDTH-1:0] fifo_rdata_frag;

wire frag_ren;
wire frag_done;

//****** internal logic ******//

assign s_axis_tready = ~fifo_full;
assign m_axis_tvalid = ~fifo_empty;

assign fifo_wen = s_axis_tvalid & s_axis_tready;

assign frag_ren = m_axis_tvalid & m_axis_tready;
assign fifo_ren = frag_ren & frag_done;

assign m_axis_tlast = 1'b0;

// joint s_axis_tdata and s_axis_tkeep -> fifo_wdata
genvar i;
generate
for (i = 0; i < WWIDTH / RWIDTH; i = i + 1) begin
    always @(*) begin
        fifo_wdata[(i+1)*FIFO_RWIDTH-1 : i*FIFO_RWIDTH] = {s_axis_tdata[(i+1)*RWIDTH-1 : i*RWIDTH], s_axis_tkeep[(i+1)*RWIDTH/8-1 : i*RWIDTH/8]};
    end
end
endgenerate

// split fifo_rdata_frag -> m_axis_tdata and m_axis_tkeep
assign {m_axis_tdata, m_axis_tkeep} = fifo_rdata_frag;

async_fifo # (
    .WIDTH  (FIFO_WWIDTH),
    .DEPTH  (FIFO_DEPTH)
    ) u_async_fifo_0 (
    .wclk     (wclk),
    .wresetn  (wresetn),
    .wen      (fifo_wen),
    .wdata    (fifo_wdata),
    .rclk     (rclk),
    .rresetn  (rresetn),
    .ren      (fifo_ren),
    .rdata    (fifo_rdata),
    .full     (fifo_full),
    .empty    (fifo_empty)
);

// bram_async_fifo u_bram_async_fifo (
//     .wr_clk  (wclk),
//     .wr_rst  (~wresetn),
//     .wr_en   (fifo_wen),
//     .din     (fifo_wdata),
//     .rd_clk  (rclk),
//     .rd_rst  (~rresetn),
//     .rd_en   (fifo_ren),
//     .dout    (fifo_rdata),
//     .full    (fifo_full),
//     .empty   (fifo_empty)
// );

// dram_async_fifo u_dram_async_fifo (
//     .wr_clk  (wclk),
//     .wr_rst  (~wresetn),
//     .wr_en   (fifo_wen),
//     .din     (fifo_wdata),
//     .rd_clk  (rclk),
//     .rd_rst  (~rresetn),
//     .rd_en   (fifo_ren),
//     .dout    (fifo_rdata),
//     .full    (fifo_full),
//     .empty   (fifo_empty)
// );

// converter

width_convert #(
    .IWIDTH  (FIFO_WWIDTH),
    .OWIDTH  (FIFO_RWIDTH)
    ) u_width_convert (
    .clk     (rclk),
    .resetn  (rresetn),
    .din     (fifo_rdata),
    .en      (frag_ren),
    .dout    (fifo_rdata_frag),
    .done    (frag_done)
);

ila_async_fifo u_ila_async_fifo_wclk (
    .clk     (wclk),
    .probe0  (fifo_wen),
    .probe1  (fifo_wdata),
    .probe2  (fifo_full)
);

ila_async_fifo u_ila_async_fifo_rclk (
    .clk     (rclk),
    .probe0  (fifo_ren),
    .probe1  (fifo_rdata),
    .probe2  (fifo_empty)
);


endmodule