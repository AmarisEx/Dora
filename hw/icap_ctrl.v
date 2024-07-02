/*******************************************************
** NAME: icap_ctrl
** DESC: transfer config data from buffer to config mem
**       based on icap
********************************************************/

`include "common.vh"

module icap_ctrl (
    // sys
    clk,
    resetn,
    // status
    start,
    done,
    err,
    // axi stream slave
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tlast
);

//****** interface ******//

// sys
input clk;
input resetn;

// record
output reg start;
output reg done;
output reg err;

// axi stream slave
input        s_axis_tvalid;
output       s_axis_tready;
input [31:0] s_axis_tdata;
input  [3:0] s_axis_tkeep;
input        s_axis_tlast;


//****** internal signals ******//

// icap
wire        icap_csib;
wire [31:0] icap_din;
wire [31:0] icap_dout;

//****** internal logic ******//

assign s_axis_tready = 1'b1;

assign icap_csib = ~(s_axis_tvalid & s_axis_tready);
assign icap_din  = s_axis_tdata;

// assign start = ~icap_csib;
// assign done  = ~icap_dout[6];
// assign err   = ~icap_dout[7];

// opt timing - reg out
always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        start <= 'b0;
    end
    else begin
        start <= ~icap_csib;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        done <= 'b0;
    end
    else begin
        // done <= ~icap_dout[6];
        done <= icap_csib; // opt timing - icap_dout is metastable
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        err <= 'b0;
    end
    else begin
        err <= ~icap_dout[7];
    end
end

// ICAPE2: Internal Configuration Access Port
// 7 Series
ICAPE2 #(
    // .DEVICE_ID          (0'h3691093), // Specifies the pre-programmed Device ID value to be used for simulation purposes.
    .ICAP_WIDTH         ("X32")       // Specifies the input and output data width.
    // .SIM_CFG_FILE_NAME  ("None")      // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation model.
) u_ICAPE2 (
    .O      (icap_dout), // 32-bit output: Configuration data output bus
    .CLK    (clk),       // 1-bit input: Clock Input
    .CSIB   (icap_csib), // 1-bit input: Active-Low ICAP Enable
    .I      (icap_din),  // 32-bit input: Configuration data input bus
    .RDWRB  (1'b0)       // 1-bit input: Read/Write Select input
);

`ifdef DEBUG

ila_icap_ctrl u_ila_icap_ctrl (
    .clk     (clk),
    .probe0  (s_axis_tvalid),
    .probe1  (s_axis_tready),
    .probe2  (s_axis_tdata),
    .probe3  (s_axis_tkeep),
    .probe4  (s_axis_tlast),
    .probe5  (icap_csib),
    .probe6  (icap_din),
    .probe7  (icap_dout),
    .probe8  (done)
);

`endif


endmodule