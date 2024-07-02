module reg_mux (
    // sys
    clk,
    resetn,
    // master0
    m0_wen,
    m0_waddr,
    m0_wdata,
    m0_wstrb,
    m0_wrdy,
    m0_ren,
    m0_raddr,
    m0_rdata,
    m0_rrdy,
    // slave0,
    s0_wen,
    s0_waddr,
    s0_wdata,
    s0_wstrb,
    s0_wrdy,
    s0_ren,
    s0_raddr,
    s0_rdata,
    s0_rrdy,
    // slave1
    s1_wen,
    s1_waddr,
    s1_wdata,
    s1_wstrb,
    s1_wrdy,
    s1_ren,
    s1_raddr,
    s1_rdata,
    s1_rrdy
);

//****** parameter ******//

parameter SLAVE0_OFFSET = 0;
parameter SLAVE1_OFFSET = 2048;

//****** interface ******//

// sys
input clk;
input resetn;

input         m0_wen;
input  [31:0] m0_waddr;
input  [31:0] m0_wdata;
input   [7:0] m0_wstrb;
output        m0_wrdy;
input         m0_ren;
input  [31:0] m0_raddr;
output [31:0] m0_rdata;
output        m0_rrdy;

output        s0_wen;
output [31:0] s0_waddr;
output [31:0] s0_wdata;
output  [7:0] s0_wstrb;
input         s0_wrdy;
output        s0_ren;
output [31:0] s0_raddr;
input  [31:0] s0_rdata;
input         s0_rrdy;

output        s1_wen;
output [31:0] s1_waddr;
output [31:0] s1_wdata;
output  [7:0] s1_wstrb;
input         s1_wrdy;
output        s1_ren;
output [31:0] s1_raddr;
input  [31:0] s1_rdata;
input         s1_rrdy;

//****** internal signal ******//

// sel
wire wsel;
wire rsel;

//****** internal logic ******//

assign wsel = m0_waddr >= SLAVE1_OFFSET;

// reg write
assign m0_wrdy = ~wsel ? s0_wrdy : s1_wrdy;

assign s0_wen   = ~wsel & m0_wen;
assign s0_waddr = ~wsel ? (m0_waddr-SLAVE0_OFFSET) : 32'b0;
assign s0_wdata = ~wsel ? m0_wdata                 : 32'b0;
assign s0_wstrb = ~wsel ? m0_wstrb                 : 8'b0;

assign s1_wen   = wsel & m0_wen;
assign s1_waddr = wsel ? (m0_waddr-SLAVE1_OFFSET) : 32'b0;
assign s1_wdata = wsel ? m0_wdata                 : 32'b0;
assign s1_wstrb = wsel ? m0_wstrb                 : 8'b0;

// reg read
assign rsel = m0_raddr >= SLAVE1_OFFSET;

assign m0_rdata = ~rsel ? s0_rdata : s1_rdata;
assign m0_rrdy  = ~rsel ? s0_rrdy  : s1_rrdy;

assign s0_ren   = ~rsel & m0_ren;
assign s0_raddr = ~rsel ? (m0_raddr-SLAVE0_OFFSET) : 32'b0;

assign s1_ren   = rsel & m0_ren;
assign s1_raddr = rsel ? (m0_raddr-SLAVE1_OFFSET) : 32'b0;


endmodule