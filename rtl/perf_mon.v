/*******************************************************
** NAME: perf_mon
** DESC: a performance monitor for prc
********************************************************/

`include "common.vh"

module perf_mon (
    sys_clk,
    sys_resetn,
    icap_clk,
    icap_resetn,
    h2b_start,
    h2b_end,
    b2c_start,
    b2c_end,
    h2b_cyc_cnt,
    b2c_cyc_cnt,
    h2c_cyc_cnt
);

parameter CNT_WIDTH = 28;

//****** interface ******//

input sys_clk;
input sys_resetn;
input icap_clk;
input icap_resetn;

input h2b_start;
input h2b_end;
input b2c_start;
input b2c_end;

output [CNT_WIDTH-1:0] h2b_cyc_cnt;
output [CNT_WIDTH-1:0] b2c_cyc_cnt;
output [CNT_WIDTH-1:0] h2c_cyc_cnt;

//****** internal signals ******//

wire h2b_start_pos;
wire h2b_end_pos;

wire b2c_start_pos;
wire b2c_end_pos;

wire h2c_start_pos;
wire h2c_end_pos;

//****** internal logic ******//

// edge dection

edge_dect h2b_start_pos_edge_dect (
    .clk     (sys_clk),
    .resetn  (sys_resetn),
    .s       (h2b_start),
    .pos     (1'b1),
    .s_edge  (h2b_start_pos)
);

edge_dect h2b_end_pos_edge_dect (
    .clk     (sys_clk),
    .resetn  (sys_resetn),
    .s       (h2b_end),
    .pos     (1'b1),
    .s_edge  (h2b_end_pos)
);

edge_dect b2c_start_pos_edge_dect (
    .clk     (icap_clk),
    .resetn  (icap_resetn),
    .s       (b2c_start),
    .pos     (1'b1),
    .s_edge  (b2c_start_pos)
);

edge_dect b2c_end_pos_edge_dect (
    .clk     (icap_clk),
    .resetn  (icap_resetn),
    .s       (b2c_end),
    .pos     (1'b1),
    .s_edge  (b2c_end_pos)
);

assign h2c_start_pos = h2b_start_pos;

two_stage_sync b2c_end_edge_two_stage_sync (
    .clk     (sys_clk),
    .resetn  (sys_resetn),
    .s       (b2c_end_pos),
    .s_sync  (h2c_end_pos)
);

// count

counter # (
    .WIDTH  (CNT_WIDTH)
    ) h2b_cyc_counter (
    .clk        (sys_clk),
    .resetn     (sys_resetn),
    .cnt_start  (h2b_start_pos),
    .cnt_end    (h2b_end_pos),
    .cnt        (h2b_cyc_cnt)
);

counter # (
    .WIDTH  (CNT_WIDTH)
    ) b2c_cyc_counter (
    .clk        (icap_clk),
    .resetn     (icap_resetn),
    .cnt_start  (b2c_start_pos),
    .cnt_end    (b2c_end_pos),
    .cnt        (b2c_cyc_cnt)
);

counter # (
    .WIDTH  (CNT_WIDTH)
    ) h2c_cyc_counter (
    .clk        (sys_clk),
    .resetn     (sys_resetn),
    .cnt_start  (h2c_start_pos),
    .cnt_end    (h2c_end_pos),
    .cnt        (h2c_cyc_cnt)
);


endmodule