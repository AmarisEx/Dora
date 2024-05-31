/*******************************************************
** NAME: width_convert
** DESC: convert data width - large to small
********************************************************/

`include "common.vh"

module width_convert (
    clk,
    resetn,
    din,
    en,
    dout,
    done
);

//****** parameter ******//

parameter IWIDTH = 288;
parameter OWIDTH = 36;

localparam AMOUNT = IWIDTH/OWIDTH;
localparam CNT_WIDTH = $clog2(AMOUNT);

//****** interface ******//

input               clk;
input               resetn;
input  [IWIDTH-1:0] din;
input               en;
output [OWIDTH-1:0] dout;
output              done;

//****** internal signal ******//

reg [CNT_WIDTH-1:0] cnt_r;

reg [IWIDTH-1:0] din_r;
reg [OWIDTH-1:0] dout_lut [AMOUNT-1:0];

//****** internal logic ******//

assign done = (cnt_r == 'b0);

// register din
always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        din_r <= 'b0;
    end
    else if (~en | cnt_r == AMOUNT - 1) begin
        din_r <= din;
    end
end

// count frag
always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        cnt_r <= 'b0;
    end
    else if (en) begin
        cnt_r <= (cnt_r != AMOUNT - 1) ? cnt_r + 1'b1 : 'b0;
    end
end

// select frag
assign dout = dout_lut[cnt_r];

genvar i;
generate
for (i = 0; i < AMOUNT; i = i + 1) begin
    always @(*) begin
        dout_lut[i] = din_r[(i+1)*OWIDTH-1 : i*OWIDTH];
    end
end
endgenerate


endmodule