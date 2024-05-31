/*******************************************************
** NAME: edge_dect
** DESC: detect the positive edge or negative edge of 
**       level signal
********************************************************/

`include "common.vh"

module edge_dect (
    clk,
    resetn,
    s,
    pos,
    s_edge
);

input clk;
input resetn;
input s;
input pos;  // 1: pos, 0: neg
output s_edge;

reg s_r;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        s_r <= 1'b0;
    end
    else begin
        s_r <= s;
    end
end

assign s_edge = pos ? (s & ~s_r) : (~s & s_r);


endmodule