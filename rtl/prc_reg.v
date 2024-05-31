/*******************************************************
** NAME: prc_reg
** DESC: prc internal registers
********************************************************/

`include "common.vh"

module prc_reg (
    // sys
    clk,
    resetn,
    // reg write/read
    wen,
    waddr,
    wdata,
    wstrb,
    wrdy,
    ren,
    raddr,
    rdata,
    rrdy,
    // function signal for reg
    // input
    config_done,
    config_err,
    h2b_cyc_cnt,
    b2c_cyc_cnt,
    h2c_cyc_cnt,
    // output
    config_err_int_req
);

//****** parameter ******//

// base addr of regs
parameter BASE_ADDR      = 0;
parameter CYC_CNT_WIDTH  = 28;

localparam STATUS_ADDR   = BASE_ADDR + 32'h00;
localparam INT_ADDR      = BASE_ADDR + 32'h04;
localparam PERF_H2B_ADDR = BASE_ADDR + 32'h08;
localparam PERF_B2C_ADDR = BASE_ADDR + 32'h0C;
localparam PERF_H2C_ADDR = BASE_ADDR + 32'h10;

//****** interface ******//

// sys
input clk;
input resetn;

input             wen;
input      [31:0] waddr;
input      [31:0] wdata;
input       [7:0] wstrb;
output            wrdy;
input             ren;
input      [31:0] raddr;
output reg [31:0] rdata;
output            rrdy;

// function signals for reg
input                      config_done;
input                      config_err;
input  [CYC_CNT_WIDTH-1:0] h2b_cyc_cnt;
input  [CYC_CNT_WIDTH-1:0] b2c_cyc_cnt;
input  [CYC_CNT_WIDTH-1:0] h2c_cyc_cnt;

output                      config_err_int_req;

//****** internal signal ******//

// regs
reg                      cfg_done_r;
reg                      cfg_err_int_r;
reg [CYC_CNT_WIDTH-1:0]  h2b_cyc_cnt_r;
reg [CYC_CNT_WIDTH-1:0]  b2c_cyc_cnt_r;
reg [CYC_CNT_WIDTH-1:0]  h2c_cyc_cnt_r;

// rdy
reg wrdy_r;
reg rrdy_r;

//****** internal logic ******//

// Reg Write

// name        : STATUS
// field_name  : config_done
// field_width : [0]
// access_type : RO
always @(*) begin
    cfg_done_r = config_done;
end

// name        : INT
// field_name  : config_err
// field_width : [0]
// access_type : RO
always @(*) begin
    cfg_err_int_r = config_err;
end

// name        : PERF_H2B
// field_name  : h2b_cyc_cnt
// field_width : [27:0]
// access_type : RO
always @(*) begin
    h2b_cyc_cnt_r = h2b_cyc_cnt;
end

// name        : PERF_B2C
// field_name  : b2c_cyc_cnt
// field_width : [27:0]
// access_type : RO
always @(*) begin
    b2c_cyc_cnt_r = b2c_cyc_cnt;
end

// name        : PERF_H2C
// field_name  : h2c_cyc_cnt
// field_width : [27:0]
// access_type : RO
always @(*) begin
    h2c_cyc_cnt_r = h2c_cyc_cnt;
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        wrdy_r <= 1'b0;
    end
    else if (wen) begin
        wrdy_r <= 1'b1;
    end
    else begin
        wrdy_r <= 1'b0;
    end
end

//****** Reg Read ******//

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        rdata <= 32'b0;
    end
    else if (ren) begin
        case (raddr)
            STATUS_ADDR   : rdata <= {{31{1'b0}}, cfg_done_r};
            INT_ADDR      : rdata <= {{31{1'b0}}, cfg_err_int_r};
            PERF_H2B_ADDR : rdata <= {{4{1'b0}}, h2b_cyc_cnt_r};
            PERF_B2C_ADDR : rdata <= {{4{1'b0}}, b2c_cyc_cnt_r};
            PERF_H2C_ADDR : rdata <= {{4{1'b0}}, h2c_cyc_cnt_r};
            default       : rdata <= 32'b0;
        endcase
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        rrdy_r <= 1'b0;
    end
    else if (ren) begin
        rrdy_r <= 1'b1;
    end
    else begin
        rrdy_r <= 1'b0;
    end
end

// output
assign config_err_int_req = cfg_err_int_r;

assign wrdy = wrdy_r;
assign rrdy = rrdy_r;


endmodule