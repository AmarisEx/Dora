/*******************************************************
** NAME: axil_interconnect
** DESC: axi lite interconnect(one master, two slaves)
********************************************************/

`include "common.vh"

module axil_interconnect (
    // sys
    clk,
    resetn,
    // master0
    m0_axil_awaddr,
    m0_axil_awprot,
    m0_axil_awvalid,
    m0_axil_awready,
    m0_axil_wdata,
    m0_axil_wstrb,
    m0_axil_wvalid,
    m0_axil_wready,
    m0_axil_bresp,
    m0_axil_bvalid,
    m0_axil_bready,
    m0_axil_araddr,
    m0_axil_arprot,
    m0_axil_arready,
    m0_axil_arvalid,
    m0_axil_rdata,
    m0_axil_rresp,
    m0_axil_rready,
    m0_axil_rvalid,
    // slave0,
    s0_axil_awaddr,
    s0_axil_awprot,
    s0_axil_awvalid,
    s0_axil_awready,
    s0_axil_wdata,
    s0_axil_wstrb,
    s0_axil_wvalid,
    s0_axil_wready,
    s0_axil_bresp,
    s0_axil_bvalid,
    s0_axil_bready,
    s0_axil_araddr,
    s0_axil_arprot,
    s0_axil_arready,
    s0_axil_arvalid,
    s0_axil_rdata,
    s0_axil_rresp,
    s0_axil_rready,
    s0_axil_rvalid,
    // slave1
    s1_axil_awaddr,
    s1_axil_awprot,
    s1_axil_awvalid,
    s1_axil_awready,
    s1_axil_wdata,
    s1_axil_wstrb,
    s1_axil_wvalid,
    s1_axil_wready,
    s1_axil_bresp,
    s1_axil_bvalid,
    s1_axil_bready,
    s1_axil_araddr,
    s1_axil_arprot,
    s1_axil_arready,
    s1_axil_arvalid,
    s1_axil_rdata,
    s1_axil_rresp,
    s1_axil_rready,
    s1_axil_rvalid
);

//****** parameter ******//

parameter SLAVE0_OFFSET = 0;
parameter SLAVE1_OFFSET = 2048;

//****** interface ******//

// sys
input clk;
input resetn;

// axi lite master0
input  [31:0] m0_axil_awaddr;
input   [2:0] m0_axil_awprot;
input         m0_axil_awvalid;
output        m0_axil_awready;
input  [31:0] m0_axil_wdata;
input   [3:0] m0_axil_wstrb;
input         m0_axil_wvalid;
output        m0_axil_wready;
output  [1:0] m0_axil_bresp;
output        m0_axil_bvalid;
input         m0_axil_bready;
input  [31:0] m0_axil_araddr;
input   [2:0] m0_axil_arprot;
input         m0_axil_arvalid;
output        m0_axil_arready;
output [31:0] m0_axil_rdata;
output  [1:0] m0_axil_rresp;
output        m0_axil_rvalid;
input         m0_axil_rready;

// axi lite slave0
output [31:0] s0_axil_awaddr;
output  [2:0] s0_axil_awprot;
output        s0_axil_awvalid;
input         s0_axil_awready;
output [31:0] s0_axil_wdata;
output  [3:0] s0_axil_wstrb;
output        s0_axil_wvalid;
input         s0_axil_wready;
input   [1:0] s0_axil_bresp;
input         s0_axil_bvalid;
output        s0_axil_bready;
output [31:0] s0_axil_araddr;
output  [2:0] s0_axil_arprot;
output        s0_axil_arvalid;
input         s0_axil_arready;
input  [31:0] s0_axil_rdata;
input   [1:0] s0_axil_rresp;
input         s0_axil_rvalid;
output        s0_axil_rready;

// axi lite slave1
output [31:0] s1_axil_awaddr;
output  [2:0] s1_axil_awprot;
output        s1_axil_awvalid;
input         s1_axil_awready;
output [31:0] s1_axil_wdata;
output  [3:0] s1_axil_wstrb;
output        s1_axil_wvalid;
input         s1_axil_wready;
input   [1:0] s1_axil_bresp;
input         s1_axil_bvalid;
output        s1_axil_bready;
output [31:0] s1_axil_araddr;
output  [2:0] s1_axil_arprot;
output        s1_axil_arvalid;
input         s1_axil_arready;
input  [31:0] s1_axil_rdata;
input   [1:0] s1_axil_rresp;
input         s1_axil_rvalid;
output        s1_axil_rready;

//****** internal signal ******//

wire wsel;
wire rsel;

//****** internal logic ******//

// reg write

assign wsel = m0_axil_awaddr >= SLAVE1_OFFSET;

assign m0_axil_awready = ~wsel ? s0_axil_awready : s1_axil_awready;
assign m0_axil_wready  = ~wsel ? s0_axil_wready  : s1_axil_wready;
assign m0_axil_bresp   = ~wsel ? s0_axil_bresp   : s1_axil_bresp;
assign m0_axil_bvalid  = ~wsel ? s0_axil_bvalid  : s1_axil_bvalid;

assign s0_axil_awaddr  = ~wsel ? (m0_axil_awaddr-SLAVE0_OFFSET) : 'b0;
assign s0_axil_awprot  = ~wsel ? m0_axil_awprot  : 'b0;
assign s0_axil_awvalid = ~wsel ? m0_axil_awvalid : 'b0;
assign s0_axil_wdata   = ~wsel ? m0_axil_wdata   : 'b0;
assign s0_axil_wvalid  = ~wsel ? m0_axil_wvalid  : 'b0;
assign s0_axil_bready  = ~wsel ? m0_axil_bready  : 'b0;
assign s0_axil_wdata   = ~wsel ? m0_axil_wdata   : 'b0;

assign s1_axil_awaddr  = wsel ? (m0_axil_awaddr-SLAVE1_OFFSET)  : 'b0;
assign s1_axil_awprot  = wsel ? m0_axil_awprot  : 'b0;
assign s1_axil_awvalid = wsel ? m0_axil_awvalid : 'b0;
assign s1_axil_wdata   = wsel ? m0_axil_wdata   : 'b0;
assign s1_axil_wvalid  = wsel ? m0_axil_wvalid  : 'b0;
assign s1_axil_bready  = wsel ? m0_axil_bready  : 'b0;
assign s1_axil_wdata   = wsel ? m0_axil_wdata   : 'b0;

// reg read

assign rsel = m0_axil_araddr >= SLAVE1_OFFSET;

assign m0_axil_arready = ~rsel ? s0_axil_arready : s1_axil_arready;
assign m0_axil_rdata   = ~rsel ? s0_axil_rdata   : s1_axil_rdata;
assign m0_axil_rresp   = ~rsel ? s0_axil_rresp   : s1_axil_rresp;
assign m0_axil_rvalid  = ~rsel ? s0_axil_rvalid  : s1_axil_rvalid;

assign s0_axil_araddr  = ~rsel ? (m0_axil_araddr-SLAVE0_OFFSET) : 'b0;
assign s0_axil_arprot  = ~rsel ? m0_axil_arprot  : 'b0;
assign s0_axil_arvalid = ~rsel ? m0_axil_arvalid : 'b0;
assign s0_axil_rready  = ~rsel ? m0_axil_rready  : 'b0;

assign s1_axil_araddr  = rsel ? (m0_axil_araddr-SLAVE1_OFFSET) : 'b0;
assign s1_axil_arprot  = rsel ? m0_axil_arprot  : 'b0;
assign s1_axil_arvalid = rsel ? m0_axil_arvalid : 'b0;
assign s1_axil_rready  = rsel ? m0_axil_rready  : 'b0;

ila_axil_icn u_ila_axil_icn (
    .clk(clk),
    .probe0(m0_axil_araddr),
    .probe1(m0_axil_arvalid),
    .probe2(m0_axil_arready),
    .probe3(m0_axil_rvalid),
    .probe4(m0_axil_rready),
    .probe5(m0_axil_rdata),

    .probe6(s0_axil_araddr),
    .probe7(s0_axil_arvalid),
    .probe8(s0_axil_arready),
    .probe9(s0_axil_rvalid),
    .probe10(s0_axil_rready),
    .probe11(s0_axil_rdata),

    .probe12(s1_axil_araddr),
    .probe13(s1_axil_arvalid),
    .probe14(s1_axil_arready),
    .probe15(s1_axil_rvalid),
    .probe16(s1_axil_rready),
    .probe17(s1_axil_rdata)
);


endmodule