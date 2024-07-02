create_clock -period 4.000 -name sys_clk -waveform {0.000 2.000} [get_ports sys_clk]

create_generated_clock -name icap_clk -source [get_pins u_clk_gen/u_mmcm_drp_xilinx/clk_out1] -multiply_by 1 -add -master_clock clk_out1_mmcm_drp_xilinx [get_pins u_clk_gen/clk_out1]
create_generated_clock -name user_clk -source [get_pins u_clk_gen/u_mmcm_drp_xilinx/clk_out2] -multiply_by 1 -add -master_clock clk_out2_mmcm_drp_xilinx [get_pins u_clk_gen/clk_out2]
set_clock_groups -name async_sys_icap -asynchronous -group [get_clocks sys_clk] -group [get_clocks icap_clk]
