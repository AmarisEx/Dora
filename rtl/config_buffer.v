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

input                   rclk;
input                   rresetn;
output                  m_axis_tvalid;
input                   m_axis_tready;
output     [WWIDTH-1:0] m_axis_tdata;
output [(WWIDTH/8)-1:0] m_axis_tkeep;
output                  m_axis_tlast;


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
    .m_axis_tvalid  (m_axis_tvalid),
    .m_axis_tready  (m_axis_tready),
    .m_axis_tdata   (m_axis_tdata),
    .m_axis_tkeep   (m_axis_tkeep),
    .m_axis_tlast   (m_axis_tlast)
);


endmodule