/*******************************************************
** NAME: clk_gen
** DESC: generate a clock for icap
********************************************************/

`include "common.vh"

module clk_gen (
    i_clk,
    i_resetn,
    o_clk1,
    o_clk2,
    o_resetn,
    // reg write/read
    wen,
    waddr,
    wdata,
    wstrb,
    wrdy,
    ren,
    raddr,
    rdata,
    rrdy
);

//****** interface ******//

input i_clk;
input i_resetn;

output o_clk1;
output o_clk2;
output o_resetn;

input         wen;
input  [31:0] waddr;
input  [31:0] wdata;
input   [7:0] wstrb;
output        wrdy;
input         ren;
input  [31:0] raddr;
output [31:0] rdata;
output        rrdy;

//****** internal signal ******//

// drp
wire [10:0] daddr;
wire        den;
wire [15:0] din;
wire [15:0] dout;
wire        drdy;
wire        dwe;

//****** internal logic ******//

assign daddr = wen ? waddr[10:0] : raddr[10:0];
assign den = wen | ren;
assign din = wdata[15:0];
assign rdata = {{16{1'b0}}, dout};
assign dwe = wen;

// axil -> reg rw
assign wrdy = drdy;
assign rrdy = drdy;

// mmcm_drp u_mmcm_drp (
//     .clk_in1   (i_clk),
//     .resetn    (i_resetn),
//     .clk_out1  (o_clk1),
//     .clk_out2  (o_clk2),
//     .locked    (o_resetn),
//     // drp
//     .daddr     (daddr),
//     .dclk      (i_clk),
//     .den       (den),
//     .din       (din),
//     .dout      (dout),
//     .drdy      (drdy),
//     .dwe       (dwe)
// );

mmcm_drp_xilinx u_mmcm_drp_xilinx (
    .clk_in1   (i_clk),
    .resetn    (i_resetn),
    .clk_out1  (o_clk1),
    .clk_out2  (o_clk2),
    .locked    (o_resetn),
    // drp
    .daddr     (daddr),
    .dclk      (i_clk),
    .den       (den),
    .din       (din),
    .dout      (dout),
    .drdy      (drdy),
    .dwe       (dwe)
);


endmodule