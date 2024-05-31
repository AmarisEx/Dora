/*******************************************************
** NAME: simple_dual_port_ram
** DESC: support simultaneous read and write
********************************************************/

`include "common.vh"

module simple_dual_port_ram (
    wclk,
    wen,
    waddr,
    wdata,
    rclk,
    ren,
    raddr,
    rdata
);

//****** parameter ******//

parameter WIDTH = 256;
parameter DEPTH = 1024;

localparam ADDR_WDITH = $clog2(DEPTH);

//****** interface ******//

input                  wclk;
input                  wen;
input [ADDR_WDITH-1:0] waddr;
input      [WIDTH-1:0] wdata;

input                  rclk;
input                  ren;
input [ADDR_WDITH-1:0] raddr;
output     [WIDTH-1:0] rdata;

//****** internal signal ******//

// (*ram_style="block"*) reg [WIDTH-1:0] MEM [DEPTH-1:0];  // specify bram (need rclk)
reg [WIDTH-1:0] MEM [DEPTH-1:0];  // dram (no rclk)

reg [WIDTH-1:0] rdata_r;

//****** internal logic ******//

always @(posedge wclk) begin
    if (wen) begin
        MEM[waddr] <= wdata;
    end
end

// TODO
always @(posedge rclk) begin
    if (ren) begin
        rdata_r <= MEM[raddr];
    end
end

assign rdata = rdata_r;


endmodule