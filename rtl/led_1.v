module led (
    clk,
    resetn,
    mode
);

input clk;
input resetn;

output [1:0] mode;

assign mode = 2'b10;

endmodule