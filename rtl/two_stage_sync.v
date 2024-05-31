/*******************************************************
** NAME: two_stage_sync
** DESC: a synchronizer used for single-bit signal 
**       transmission across clock domains
********************************************************/

`include "common.vh"

module two_stage_sync (
    clk,
    resetn,
    s,
    s_sync
);

input clk;
input resetn;
input s;
output s_sync;

reg s_r;
reg s_rr;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        {s_r, s_rr}  <= 2'b0;
    end
    else begin
        {s_r, s_rr}  <= {s, s_r};
    end
end

assign s_sync = s_rr;


endmodule