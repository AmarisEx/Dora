/*******************************************************
** NAME: system_top
** DESC: a system supporting partial reconfiguration
**       based on xdma
********************************************************/

`include "common.vh"

module system_top (
    i_pcie_refclkp,
    i_pcie_refclkn,
    i_pcie_rstn,
    i_pcie_rxp,
    i_pcie_rxn,
    o_pcie_txp,
    o_pcie_txn,
    o_led
);

//****** parameter ******//

localparam ICAP_OFFSET = 0;
localparam DRP_OFFSET  = 2048;

localparam AXIS_DATA_WIDTH = 256;
localparam ICAP_WIDTH      = 32;
localparam CFG_BUF_DEPTH   = 4096;


//****** interface ******//

input        i_pcie_refclkp;
input        i_pcie_refclkn;
input        i_pcie_rstn;
input  [7:0] i_pcie_rxp;
input  [7:0] i_pcie_rxn;

output [3:0] o_led;
output [7:0] o_pcie_txp;
output [7:0] o_pcie_txn;

//****** internal signal ******//

// multi clk domains

wire pcie_refclk;
wire pcie_rstn;

wire axi_aclk;
wire axi_aresetn;

wire user_clk;
wire user_resetn;

// PCIe XDMA's AXI Stream interface
wire                           axis_h2c_tvalid;
wire                           axis_h2c_tready;
wire [AXIS_DATA_WIDTH-1:0]     axis_h2c_tdata;
wire [(AXIS_DATA_WIDTH/8)-1:0] axis_h2c_tkeep;
wire                           axis_h2c_tlast;

wire                           axis_c2h_tvalid;
wire                           axis_c2h_tready;
wire [AXIS_DATA_WIDTH-1:0]     axis_c2h_tdata;
wire [(AXIS_DATA_WIDTH/8)-1:0] axis_c2h_tkeep;
wire                           axis_c2h_tlast;

// PCIe XDMA's AXI Lite interface
wire [31:0] axil_awaddr;
wire [2:0]  axil_awprot;
wire        axil_awvalid;
wire        axil_awready;

wire [31:0] axil_wdata;
wire [3:0]  axil_wstrb;
wire        axil_wvalid;
wire        axil_wready;

wire        axil_bvalid;
wire [1:0]  axil_bresp;
wire        axil_bready;

wire [31:0] axil_araddr;
wire [2:0]  axil_arprot;
wire        axil_arvalid;
wire        axil_arready;

wire [31:0] axil_rdata;
wire [1:0]  axil_rresp;
wire        axil_rvalid;
wire        axil_rready;

// DMA status
wire [7:0] h2c_sts_0;

// PCIe XDMA's int
wire [15:0] usr_irq_req;
wire [15:0] usr_irq_ack;

//****** internal logic ******//

// unused signals
assign axis_c2h_tvalid = 1'b0;
assign axis_c2h_tdata  = {AXIS_DATA_WIDTH{1'b0}};
assign axis_c2h_tkeep  = {((AXIS_DATA_WIDTH/8)-1){1'b0}};
assign axis_c2h_tlast  = 1'b0;

assign usr_irq_req[15:1] = 15'b0;

// Ref clock input buffer
IBUFDS_GTE2 refclk_ibuf (
    .CEB    (1'b0),
    .I      (i_pcie_refclkp),
    .IB     (i_pcie_refclkn),
    .O      (pcie_refclk),
    .ODIV2  ()
);

// Reset input buffer
IBUF sys_reset_n_ibuf (
    .I  (i_pcie_rstn),
    .O  (pcie_rstn)
);

// PCIe XDMA core
xdma_0 u_xdma_0 (
    // PCI Express (PCIe) Interface : connect to the pins of FPGA chip
    .sys_rst_n       (pcie_rstn),
    .sys_clk         (pcie_refclk),
    .pci_exp_txn     (o_pcie_txn),
    .pci_exp_txp     (o_pcie_txp),
    .pci_exp_rxn     (i_pcie_rxn), 
    .pci_exp_rxp     (i_pcie_rxp),
    // PCIe link up
    .user_lnk_up     (o_led[0]),
    // interrupts
    .usr_irq_req     (usr_irq_req),
    .usr_irq_ack     (usr_irq_ack),
    //
    .msix_enable     (o_led[1]),
    // clock/reset for user (for AXI)
    .axi_aclk        (axi_aclk),
    .axi_aresetn     (axi_aresetn),
    // axi lite
    .m_axil_awaddr   (axil_awaddr), 
    .m_axil_awprot   (axil_awprot),
    .m_axil_awvalid  (axil_awvalid),
    .m_axil_awready  (axil_awready),
    .m_axil_wdata    (axil_wdata),
    .m_axil_wstrb    (axil_wstrb),
    .m_axil_wvalid   (axil_wvalid),
    .m_axil_wready   (axil_wready),
    .m_axil_bvalid   (axil_bvalid),
    .m_axil_bresp    (axil_bresp),
    .m_axil_bready   (axil_bready),
    .m_axil_araddr   (axil_araddr),
    .m_axil_arprot   (axil_arprot),
    .m_axil_arvalid  (axil_arvalid),
    .m_axil_arready  (axil_arready),
    .m_axil_rdata    (axil_rdata),
    .m_axil_rresp    (axil_rresp),
    .m_axil_rvalid   (axil_rvalid),
    .m_axil_rready   (axil_rready),
    // axi stream
    .s_axis_c2h_tvalid_0  (axis_c2h_tvalid),
    .s_axis_c2h_tready_0  (axis_c2h_tready),
    .s_axis_c2h_tdata_0   (axis_c2h_tdata),
    .s_axis_c2h_tkeep_0   (axis_c2h_tkeep),
    .s_axis_c2h_tlast_0   (axis_c2h_tlast),
    .m_axis_h2c_tvalid_0  (axis_h2c_tvalid),
    .m_axis_h2c_tready_0  (axis_h2c_tready),
    .m_axis_h2c_tdata_0   (axis_h2c_tdata),
    .m_axis_h2c_tkeep_0   (axis_h2c_tkeep),
    .m_axis_h2c_tlast_0   (axis_h2c_tlast),
    // dma status
    .c2h_sts_0            (),
    .h2c_sts_0            (h2c_sts_0)
);

// User Application
led u_led (
    .clk     (user_clk),
    .resetn  (user_resetn),
    .mode    (o_led[3:2])
);

// PRC TOP connected to PCIe XDMA's AXI interface
prc_top # (
    .ICAP_OFFSET     (ICAP_OFFSET),
    .DRP_OFFSET      (DRP_OFFSET),
    .CFG_BUF_WWIDTH  (AXIS_DATA_WIDTH),
    .CFG_BUF_RWIDTH  (ICAP_WIDTH),
    .CFG_BUF_DEPTH   (CFG_BUF_DEPTH)
    ) u_prc_top (
    .sys_clk         (axi_aclk),
    .sys_resetn      (axi_aresetn),
    // axi lite slave
    .s_axil_awaddr   (axil_awaddr), 
    .s_axil_awprot   (axil_awprot),
    .s_axil_awvalid  (axil_awvalid),
    .s_axil_awready  (axil_awready),
    .s_axil_wdata    (axil_wdata),
    .s_axil_wstrb    (axil_wstrb),
    .s_axil_wvalid   (axil_wvalid),
    .s_axil_wready   (axil_wready),
    .s_axil_bvalid   (axil_bvalid),
    .s_axil_bresp    (axil_bresp),
    .s_axil_bready   (axil_bready),
    .s_axil_araddr   (axil_araddr),
    .s_axil_arprot   (axil_arprot),
    .s_axil_arvalid  (axil_arvalid),
    .s_axil_arready  (axil_arready),
    .s_axil_rdata    (axil_rdata),
    .s_axil_rresp    (axil_rresp),
    .s_axil_rvalid   (axil_rvalid),
    .s_axil_rready   (axil_rready),
    // axi stream slave
    .s_axis_tvalid   (axis_h2c_tvalid),
    .s_axis_tready   (axis_h2c_tready),
    .s_axis_tdata    (axis_h2c_tdata),
    .s_axis_tkeep    (axis_h2c_tkeep),
    .s_axis_tlast    (axis_h2c_tlast),
    // user clk and resetn
    .user_clk        (user_clk),
    .user_resetn     (user_resetn),
    // status
    .config_start    (h2c_sts_0[0]),  // dma_run
    // interrupt
    .config_err_int_req  (usr_irq_req[0]),
    .config_err_int_ack  (usr_irq_ack[0])
);


endmodule