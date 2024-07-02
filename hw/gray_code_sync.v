/*******************************************************
** NAME: gray_code_sync
** DESC: a synchronizer used for multi-bits counter 
**       transmission across clock domains
********************************************************/

`include "common.vh"

module gray_code_sync (
    clk,
    resetn,
    cnt,
    cnt_sync
);

parameter WIDTH = 28;

input              clk;
input              resetn;
input  [WIDTH-1:0] cnt;
output [WIDTH-1:0] cnt_sync;

wire [WIDTH-1:0] cnt_gray;

reg  [WIDTH-1:0] cnt_gray_r;
reg  [WIDTH-1:0] cnt_gray_rr;
reg  [WIDTH-1:0] cnt_gray_rrr;
reg  [WIDTH-1:0] cnt_sync_r;

assign cnt_gray = cnt ^ (cnt >> 1);

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        {cnt_gray_r, cnt_gray_rr, cnt_gray_rrr}  <= 'b0;
    end
    else begin
        {cnt_gray_r, cnt_gray_rr, cnt_gray_rrr}  <= {cnt_gray, cnt_gray_r, cnt_gray_rr};
    end
end


// cnt_sync[WIDTH-1] = cnt_sync_rr[WIDTH-1];
// genvar i;
// generate
// for (i = WIDTH-2; i >= 0; i = i - 1) begin
//     always @(*) begin
//          cnt_sync[i] = cnt_sync[i+1] ^ cnt_sync_rr[i];
//     end
// end
// endgenerate

integer i;
always @(*) begin
    cnt_sync_r[WIDTH-1] = cnt_gray_rrr[WIDTH-1];
    for (i = WIDTH-2; i >= 0; i = i - 1) begin  
        cnt_sync_r[i] = cnt_sync_r[i+1] ^ cnt_gray_rrr[i];
    end
end

assign cnt_sync = cnt_sync_r;

endmodule