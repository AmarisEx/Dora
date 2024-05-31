/*******************************************************
** NAME: counter
** DESC: count cycles from start to end
********************************************************/

`include "common.vh"

module counter (
    clk,
    resetn,
    cnt_start,
    cnt_end,
    cnt
);

parameter WIDTH = 28;

input clk;
input resetn;
input cnt_start;
input cnt_end;

output [WIDTH-1:0] cnt;

reg [WIDTH-1:0] cnt_r;
reg             run_r;

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        cnt_r <= {WIDTH{1'b0}};
        run_r <= 1'b0;
    end
    else if (cnt_start) begin
        cnt_r <= {{(WIDTH-1){1'b0}}, 1'b1};
        run_r <= 1'b1;
    end
    else if (~cnt_end & run_r) begin
        cnt_r <= cnt_r + 1'b1;
    end
    else if (cnt_end & run_r) begin
        cnt_r <= cnt_r;
        run_r <= 1'b0;
    end
end

assign cnt = cnt_r;


endmodule