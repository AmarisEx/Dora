/*******************************************************
** NAME: mmcm_drp
** DESC: generate a clock for icap based on mmcm 
         primitive (support drp)
********************************************************/

`include "common.vh"

module mmcm_drp (
    // Clock out ports
    clk_in1,
    resetn,
    clk_out1,
    clk_out2,
    locked,
    // Dynamic reconfiguration ports
    daddr,
    dclk,
    den,
    din,
    dout,
    drdy,
    dwe
 );

//****** interface ******//

input         clk_in1;
input         resetn;
output        clk_out1;
output        clk_out2;
output        locked;
input   [6:0] daddr;
input         dclk;
input         den;
input  [15:0] din;
output [15:0] dout;
output        drdy;
input         dwe;

//****** internal signals ******//

// Input buffering
wire clk_in1_clk_wiz_0;
wire clk_in2_clk_wiz_0;

// Clocking PRIMITIVE
// Instantiation of the MMCM PRIMITIVE
//    * Unused inputs are tied off
//    * Unused outputs are labeled unused

wire clk_out1_clk_wiz_0;
wire clk_out2_clk_wiz_0;
wire clk_out3_clk_wiz_0;
wire clk_out4_clk_wiz_0;
wire clk_out5_clk_wiz_0;
wire clk_out6_clk_wiz_0;
wire clk_out7_clk_wiz_0;

wire psdone_unused;
wire locked_int;
wire clkfbout_clk_wiz_0;
wire clkfbout_buf_clk_wiz_0;
wire clkfboutb_unused;
wire clkout0b_unused;
wire clkout1b_unused;
wire clkout2_unused;
wire clkout2b_unused;
wire clkout3_unused;
wire clkout3b_unused;
wire clkout4_unused;
wire clkout5_unused;
wire clkout6_unused;
wire clkfbstopped_unused;
wire clkinstopped_unused;
wire reset_high;

//****** internal logic ******//

IBUF clkin1_ibufg (
    .O  (clk_in1_clk_wiz_0),
    .I  (clk_in1)
);

MMCME2_ADV # (
    .BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (4.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (10.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (4),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (4.000)
    ) mmcm_adv_inst (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clk_out2_clk_wiz_0),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (daddr),
    .DCLK                (dclk),
    .DEN                 (den),
    .DI                  (din),
    .DO                  (dout),
    .DRDY                (drdy),
    .DWE                 (dwe),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (reset_high)
);

assign reset_high = ~resetn; 
assign locked = locked_int;

// Clock Monitor clock assigning
// Output buffering

BUFG clkf_buf (
    .O  (clkfbout_buf_clk_wiz_0),
    .I  (clkfbout_clk_wiz_0)
);

BUFG clkout1_buf (
    .O  (clk_out1),
    .I  (clk_out1_clk_wiz_0)
);

BUFG clkout2_buf (
    .O  (clk_out2),
    .I  (clk_out2_clk_wiz_0)
);


endmodule