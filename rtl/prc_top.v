/*******************************************************
** NAME: prc_top
** DESC: partial reconfiguration controller
********************************************************/

`include "common.vh"

module prc_top(
    // sys
    sys_clk,
    sys_resetn,
    // axi lite slave
    s_axil_awaddr,
    s_axil_awprot,
    s_axil_awvalid,
    s_axil_awready,
    s_axil_wdata,
    s_axil_wstrb,
    s_axil_wvalid,
    s_axil_wready,
    s_axil_bresp,
    s_axil_bvalid,
    s_axil_bready,
    s_axil_araddr,
    s_axil_arprot,
    s_axil_arready,
    s_axil_arvalid,
    s_axil_rdata,
    s_axil_rresp,
    s_axil_rready,
    s_axil_rvalid,
    // axi stream slave
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast,
    // user clk and resetn
    user_clk,
    user_resetn,
    // status
    config_start,
    // interrupt
    config_err_int_req,
    config_err_int_ack
);

//****** parameter ******//

parameter ICAP_OFFSET = 0;
parameter DRP_OFFSET  = 2048;

parameter CFG_BUF_WWIDTH = 256;
parameter CFG_BUF_RWIDTH = 32;
parameter CFG_BUF_DEPTH  = 1024;

localparam CYC_CNT_WIDTH = 28;


//****** interface ******//

// sys
input sys_clk;
input sys_resetn;

// axi lite slave
input  [31:0] s_axil_awaddr;
input   [2:0] s_axil_awprot;
input         s_axil_awvalid;
output        s_axil_awready;
input  [31:0] s_axil_wdata;
input   [3:0] s_axil_wstrb;
input         s_axil_wvalid;
output        s_axil_wready;
output  [1:0] s_axil_bresp;
output        s_axil_bvalid;
input         s_axil_bready;
input  [31:0] s_axil_araddr;
input   [2:0] s_axil_arprot;
input         s_axil_arvalid;
output        s_axil_arready;
output [31:0] s_axil_rdata;
output  [1:0] s_axil_rresp;
output        s_axil_rvalid;
input         s_axil_rready;

// axi stream slave
input                           s_axis_tvalid;
output                          s_axis_tready;
input      [CFG_BUF_WWIDTH-1:0] s_axis_tdata;
input  [(CFG_BUF_WWIDTH/8)-1:0] s_axis_tkeep;
input                           s_axis_tlast;

// user clk and resetn
output user_clk;
output user_resetn;

// status
input config_start;

// interrupt
output config_err_int_req;
input  config_err_int_ack;

//****** internal signal ******//

// clk and reset
wire gen_resetn;

wire icap_clk;
wire icap_resetn;

// icap status
wire icap_config_start;
wire icap_config_done;
wire icap_config_err;
// sync icap status
wire config_err;

// stream
wire                          m_axis_tvalid;
wire                          m_axis_tready;
wire [CFG_BUF_RWIDTH-1:0]     m_axis_tdata;
wire [(CFG_BUF_RWIDTH/8)-1:0] m_axis_tkeep;
wire                          m_axis_tlast;

// perf monitor
wire [CYC_CNT_WIDTH-1:0] h2b_cyc_cnt;
wire [CYC_CNT_WIDTH-1:0] b2c_cyc_cnt;
wire [CYC_CNT_WIDTH-1:0] h2c_cyc_cnt;

// axil slave
wire        m0_wen;
wire [31:0] m0_waddr;
wire [31:0] m0_wdata;
wire  [7:0] m0_wstrb;
wire        m0_wrdy;
wire        m0_ren;
wire [31:0] m0_raddr;
wire [31:0] m0_rdata;
wire        m0_rrdy;

wire        s0_wen;
wire [31:0] s0_waddr;
wire [31:0] s0_wdata;
wire  [7:0] s0_wstrb;
wire        s0_wrdy;
wire        s0_ren;
wire [31:0] s0_raddr;
wire [31:0] s0_rdata;
wire        s0_rrdy;

wire        s1_wen;
wire [31:0] s1_waddr;
wire [31:0] s1_wdata;
wire  [7:0] s1_wstrb;
wire        s1_wrdy;
wire        s1_ren;
wire [31:0] s1_raddr;
wire [31:0] s1_rdata;
wire        s1_rrdy;

//****** internal logic ******//

axil_bridge u_axil_bridge (
    // sys
    .clk                 (sys_clk),
    .resetn              (sys_resetn),
    // axi lite slave
    .s_axil_awaddr       (s_axil_awaddr),
    .s_axil_awprot       (s_axil_awprot),
    .s_axil_awvalid      (s_axil_awvalid),
    .s_axil_awready      (s_axil_awready),
    .s_axil_wdata        (s_axil_wdata),
    .s_axil_wstrb        (s_axil_wstrb),
    .s_axil_wvalid       (s_axil_wvalid),
    .s_axil_wready       (s_axil_wready),
    .s_axil_bresp        (s_axil_bresp),
    .s_axil_bvalid       (s_axil_bvalid),
    .s_axil_bready       (s_axil_bready),
    .s_axil_araddr       (s_axil_araddr),
    .s_axil_arprot       (s_axil_arprot),
    .s_axil_arready      (s_axil_arready),
    .s_axil_arvalid      (s_axil_arvalid),
    .s_axil_rdata        (s_axil_rdata),
    .s_axil_rresp        (s_axil_rresp),
    .s_axil_rready       (s_axil_rready),
    .s_axil_rvalid       (s_axil_rvalid),
    // reg write/read
    .reg_wen             (m0_wen),
    .reg_waddr           (m0_waddr),
    .reg_wdata           (m0_wdata),
    .reg_wstrb           (m0_wstrb),
    .reg_wrdy            (m0_wrdy),
    .reg_ren             (m0_ren),
    .reg_raddr           (m0_raddr),
    .reg_rdata           (m0_rdata),
    .reg_rrdy            (m0_rrdy)
);

assign icap_resetn = gen_resetn;
assign user_resetn = gen_resetn;

// generate icap_clk
clk_gen u_clk_gen (
    .i_clk     (sys_clk),
    .i_resetn  (sys_resetn),
    .o_clk1    (icap_clk),
    .o_clk2    (user_clk),
    .o_resetn  (gen_resetn),
    // reg rw
    .wen    (s1_wen),
    .waddr  (s1_waddr),
    .wdata  (s1_wdata),
    .wstrb  (s1_wstrb),
    .wrdy   (s1_wrdy),
    .ren    (s1_ren),
    .raddr  (s1_raddr),
    .rdata  (s1_rdata),
    .rrdy   (s1_rrdy)
);

// icap ctrl
icap_ctrl u_icap_ctrl (
    // sys
    .clk     (icap_clk),
    .resetn  (icap_resetn),
    // status
    .start  (icap_config_start),
    .done   (icap_config_done),
    .err    (icap_config_err),
    // axi stream slave
    .s_axis_tvalid  (m_axis_tvalid),
    .s_axis_tready  (m_axis_tready),
    .s_axis_tdata   (m_axis_tdata),
    .s_axis_tkeep   (m_axis_tkeep),
    .s_axis_tlast   (m_axis_tlast)
);

prc_reg #(
    .BASE_ADDR      (ICAP_OFFSET),
    .CYC_CNT_WIDTH  (CYC_CNT_WIDTH)
    ) u_prc_reg (
    // sys
    .clk     (sys_clk),
    .resetn  (sys_resetn),
    // reg rw
    .wen    (s0_wen),
    .waddr  (s0_waddr),
    .wdata  (s0_wdata),
    .wstrb  (s0_wstrb),
    .wrdy   (s0_wrdy),
    .ren    (s0_ren),
    .raddr  (s0_raddr),
    .rdata  (s0_rdata),
    .rrdy   (s0_rrdy),
    // function signal for reg
    .config_done         (icap_config_done),
    .config_err          (config_err),
    .h2b_cyc_cnt         (h2b_cyc_cnt),
    .b2c_cyc_cnt         (b2c_cyc_cnt),
    .h2c_cyc_cnt         (h2c_cyc_cnt),
    .config_err_int_req  (config_err_int_req)
);

config_buffer # (
    .WWIDTH  (CFG_BUF_WWIDTH),
    .RWIDTH  (CFG_BUF_RWIDTH),
    .DEPTH   (CFG_BUF_DEPTH)
) u_config_buffer_0 (
    .wclk           (sys_clk),
    .wresetn        (sys_resetn),
    .s_axis_tvalid  (s_axis_tvalid),
    .s_axis_tready  (s_axis_tready),
    .s_axis_tdata   (s_axis_tdata),
    .s_axis_tkeep   (s_axis_tkeep),
    .s_axis_tlast   (s_axis_tlast),
    .rclk           (icap_clk),
    .rresetn        (icap_resetn),
    .m_axis_tvalid  (m_axis_tvalid),
    .m_axis_tready  (m_axis_tready),
    .m_axis_tdata   (m_axis_tdata),
    .m_axis_tkeep   (m_axis_tkeep),
    .m_axis_tlast   (m_axis_tlast)
);

two_stage_sync config_err_two_stage_sync (
    .clk     (sys_clk),
    .resetn  (sys_resetn),
    .s       (icap_config_err),
    .s_sync  (config_err)
);

reg_mux # (
    .SLAVE0_OFFSET  (ICAP_OFFSET),
    .SLAVE1_OFFSET  (DRP_OFFSET)
) u_reg_mux (
    .clk       (sys_clk),
    .resetn    (sys_resetn),
    // master0
    .m0_wen    (m0_wen),
    .m0_waddr  (m0_waddr),
    .m0_wdata  (m0_wdata),
    .m0_wstrb  (m0_wstrb),
    .m0_wrdy   (m0_wrdy),
    .m0_ren    (m0_ren),
    .m0_raddr  (m0_raddr),
    .m0_rdata  (m0_rdata),
    .m0_rrdy   (m0_rrdy),
    // slave0
    .s0_wen    (s0_wen),
    .s0_waddr  (s0_waddr),
    .s0_wdata  (s0_wdata),
    .s0_wstrb  (s0_wstrb),
    .s0_wrdy   (s0_wrdy),
    .s0_ren    (s0_ren),
    .s0_raddr  (s0_raddr),
    .s0_rdata  (s0_rdata),
    .s0_rrdy   (s0_rrdy),
    // slave1
    .s1_wen    (s1_wen),
    .s1_waddr  (s1_waddr),
    .s1_wdata  (s1_wdata),
    .s1_wstrb  (s1_wstrb),
    .s1_wrdy   (s1_wrdy),
    .s1_ren    (s1_ren),
    .s1_raddr  (s1_raddr),
    .s1_rdata  (s1_rdata),
    .s1_rrdy   (s1_rrdy)
);

`ifdef PERF_MON

perf_mon #(
    .CNT_WIDTH  (CYC_CNT_WIDTH)
    ) u_perf_mon (
    .sys_clk      (sys_clk),
    .sys_resetn   (sys_resetn),
    .icap_clk     (icap_clk),
    .icap_resetn  (icap_resetn),
    .h2b_start    (config_start),
    .h2b_end      (s_axis_tlast),
    .b2c_start    (icap_config_start),
    .b2c_end      (icap_config_done),
    .h2b_cyc_cnt  (h2b_cyc_cnt),
    .b2c_cyc_cnt  (b2c_cyc_cnt),
    .h2c_cyc_cnt  (h2c_cyc_cnt)
);

`else 

    assign h2b_cyc_cnt = 'b0;
    assign b2c_cyc_cnt = 'b0;
    assign h2c_cyc_cnt = 'b0;

`endif

endmodule