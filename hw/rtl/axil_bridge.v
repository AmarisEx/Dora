/*******************************************************
** NAME: axil_bridge
** DESC: convert axi lite to a simple register 
**       read/write interface
********************************************************/

`include "common.vh"

module axil_bridge (
    // sys
    clk,
    resetn,
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
    // reg write/read
    reg_wen,
    reg_waddr,
    reg_wdata,
    reg_wstrb,
    reg_wrdy,
    reg_ren,
    reg_raddr,
    reg_rdata,
    reg_rrdy
);

//****** parameter ******//

localparam OKAY = 2'b00;


//****** interface ******//

// sys
input clk;
input resetn;

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

// reg write/read
output        reg_wen;
output [31:0] reg_waddr;
output [31:0] reg_wdata;
output  [3:0] reg_wstrb;
input         reg_wrdy;  // write trans is done
output        reg_ren;
output [31:0] reg_raddr;
input  [31:0] reg_rdata;
input         reg_rrdy;  // rdata is ready

//****** internal signal ******//

// axi lite
reg        wbusy_r;
reg        s_axil_awready_r;
reg [31:0] s_axil_awaddr_r;
reg        s_axil_wready_r;
reg [31:0] s_axil_wdata_r;
reg  [3:0] s_axil_wstrb_r;

reg        rbusy_r;
reg        s_axil_arready_r;
reg [31:0] s_axil_araddr_r;

//****** internal logic ******//

// control write/read enable signals based on axi4 lite protocol

// write channels
assign s_axil_awready = s_axil_awready_r;
assign s_axil_wready  = s_axil_wready_r;
assign s_axil_bvalid  = reg_wrdy;
assign s_axil_bresp   = OKAY;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        wbusy_r          <= 1'b0;
        s_axil_awready_r <= 1'b0;
        s_axil_awaddr_r  <= 32'b0;
        s_axil_wready_r  <= 1'b0;
        s_axil_wdata_r   <= 32'b0;
        s_axil_wstrb_r   <= 4'b0;
    end
    else if (~wbusy_r && ~s_axil_awready_r && ~s_axil_wready_r && s_axil_awvalid && s_axil_wvalid) begin
        wbusy_r          <= 1'b1;
        s_axil_awready_r <= 1'b1;
        s_axil_awaddr_r  <= s_axil_awaddr;
        s_axil_wready_r  <= 1'b1;
        s_axil_wdata_r   <= s_axil_wdata;
        s_axil_wstrb_r   <= s_axil_wstrb;
    end
    else if (wbusy_r && s_axil_bvalid && s_axil_bready) begin
        wbusy_r          <= 1'b0;
        s_axil_awready_r <= 1'b0;
        s_axil_awaddr_r  <= s_axil_awaddr_r;
        s_axil_wready_r  <= 1'b0;
        s_axil_wdata_r   <= 32'b0;
        s_axil_wstrb_r   <= 4'b0;
    end
    else begin
        wbusy_r          <= wbusy_r;
        s_axil_awready_r <= 1'b0;
        s_axil_awaddr_r  <= s_axil_awaddr_r;
        s_axil_wready_r  <= 1'b0;
        s_axil_wdata_r   <= 32'b0;
        s_axil_wstrb_r   <= 4'b0;
    end
end

// read channels

assign s_axil_arready = s_axil_arready_r;
assign s_axil_rdata   = reg_rdata;
assign s_axil_rvalid  = reg_rrdy;
assign s_axil_rresp   = OKAY;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        rbusy_r          <= 1'b0;
        s_axil_arready_r <= 1'b0;
        s_axil_araddr_r  <= 32'b0;
    end
    else if (~rbusy_r && ~s_axil_arready_r && s_axil_arvalid) begin
        rbusy_r          <= 1'b1;
        s_axil_arready_r <= 1'b1;
        s_axil_araddr_r  <= s_axil_araddr;
    end
    else if (rbusy_r && s_axil_rvalid && s_axil_rready) begin
        rbusy_r          <= 1'b0;
        s_axil_arready_r <= 1'b0;
        s_axil_araddr_r  <= s_axil_araddr_r;
    end
    else begin
        rbusy_r          <= rbusy_r;
        s_axil_arready_r <= 1'b0;
        s_axil_araddr_r  <= s_axil_araddr_r;
    end
end

// bridged: reg w/r output

assign reg_wen   = s_axil_awvalid && s_axil_awready && s_axil_wvalid && s_axil_wready;
assign reg_waddr = s_axil_awaddr_r;
assign reg_wdata = s_axil_wdata_r;
assign reg_wstrb = s_axil_wstrb_r;

assign reg_ren   = s_axil_arvalid && s_axil_arready;
assign reg_raddr = s_axil_araddr_r;


endmodule