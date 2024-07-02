/*******************************************************
** NAME: config_buffer
** DESC: buffer the configuration data from host
********************************************************/

`include "common.vh"

module config_buffer (
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
parameter DEPTH  = 1024;

//****** interface ******//

input                  wclk;
input                  wresetn;
input                  s_axis_tvalid;
output                 s_axis_tready;
input     [WWIDTH-1:0] s_axis_tdata;
input [(WWIDTH/8)-1:0] s_axis_tkeep;
input                  s_axis_tlast;

input                       rclk;
input                       rresetn;
output reg                  m_axis_tvalid;
input                       m_axis_tready;
output reg     [WWIDTH-1:0] m_axis_tdata;
output reg [(WWIDTH/8)-1:0] m_axis_tkeep;
output reg                  m_axis_tlast;

//****** internal signal ******//

wire                  m_axis_tvalid_tmp;
wire [WWIDTH-1:0]     m_axis_tdata_tmp;
wire [(WWIDTH/8)-1:0] m_axis_tkeep_tmp;
wire                  m_axis_tlast_tmp;


//****** internal logic ******//

axis_async_fifo # (
    .WWIDTH  (WWIDTH),
    .RWIDTH  (RWIDTH),
    .DEPTH   (DEPTH)
) u_axis_async_fifo_0 (
    .wclk           (wclk),
    .wresetn        (wresetn),
    .s_axis_tvalid  (s_axis_tvalid),
    .s_axis_tready  (s_axis_tready),
    .s_axis_tdata   (s_axis_tdata),
    .s_axis_tkeep   (s_axis_tkeep),
    .s_axis_tlast   (s_axis_tlast),
    .rclk           (rclk),
    .rresetn        (rresetn),
    .m_axis_tvalid  (m_axis_tvalid_tmp),
    .m_axis_tready  (m_axis_tready),
    .m_axis_tdata   (m_axis_tdata_tmp),
    .m_axis_tkeep   (m_axis_tkeep_tmp),
    .m_axis_tlast   (m_axis_tlast_tmp)
);

// opt timing - icap csib
always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        m_axis_tvalid <= 'b0;
    end
    else begin
        m_axis_tvalid <= m_axis_tvalid_tmp;
    end
end

always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        m_axis_tdata <= 'b0;
    end
    else begin
        m_axis_tdata <= m_axis_tdata_tmp;
    end
end

always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        m_axis_tkeep <= 'b0;
    end
    else begin
        m_axis_tkeep <= m_axis_tkeep_tmp;
    end
end

always @(posedge rclk or negedge rresetn) begin
    if (~rresetn) begin
        m_axis_tlast <= 'b0;
    end
    else begin
        m_axis_tlast <= m_axis_tlast_tmp;
    end
end

endmodule