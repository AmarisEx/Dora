#PCIe reference clock
set_property PACKAGE_PIN AB8 [get_ports i_pcie_refclkp]

# PCIe rst
set_property PACKAGE_PIN AV35 [get_ports i_pcie_rstn]
set_property IOSTANDARD LVCMOS18 [get_ports i_pcie_rstn]
set_property PULLUP true [get_ports i_pcie_rstn]

# PCIe MGT interface
set_property LOC GTHE2_CHANNEL_X1Y23 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN Y3 [get_ports {i_pcie_rxn[0]}]
set_property PACKAGE_PIN Y4 [get_ports {i_pcie_rxp[0]}]
set_property PACKAGE_PIN W1 [get_ports {o_pcie_txn[0]}]
set_property PACKAGE_PIN W2 [get_ports {o_pcie_txp[0]}]
set_property LOC GTHE2_CHANNEL_X1Y22 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AA5 [get_ports {i_pcie_rxn[1]}]
set_property PACKAGE_PIN AA6 [get_ports {i_pcie_rxp[1]}]
set_property PACKAGE_PIN AA1 [get_ports {o_pcie_txn[1]}]
set_property PACKAGE_PIN AA2 [get_ports {o_pcie_txp[1]}]
set_property LOC GTHE2_CHANNEL_X1Y21 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AB3 [get_ports {i_pcie_rxn[2]}]
set_property PACKAGE_PIN AB4 [get_ports {i_pcie_rxp[2]}]
set_property PACKAGE_PIN AC1 [get_ports {o_pcie_txn[2]}]
set_property PACKAGE_PIN AC2 [get_ports {o_pcie_txp[2]}]
set_property LOC GTHE2_CHANNEL_X1Y20 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AC5 [get_ports {i_pcie_rxn[3]}]
set_property PACKAGE_PIN AC6 [get_ports {i_pcie_rxp[3]}]
set_property PACKAGE_PIN AE1 [get_ports {o_pcie_txn[3]}]
set_property PACKAGE_PIN AE2 [get_ports {o_pcie_txp[3]}]
set_property LOC GTHE2_CHANNEL_X1Y19 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AD3 [get_ports {i_pcie_rxn[4]}]
set_property PACKAGE_PIN AD4 [get_ports {i_pcie_rxp[4]}]
set_property PACKAGE_PIN AG1 [get_ports {o_pcie_txn[4]}]
set_property PACKAGE_PIN AG2 [get_ports {o_pcie_txp[4]}]
set_property LOC GTHE2_CHANNEL_X1Y18 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AE5 [get_ports {i_pcie_rxn[5]}]
set_property PACKAGE_PIN AE6 [get_ports {i_pcie_rxp[5]}]
set_property PACKAGE_PIN AH3 [get_ports {o_pcie_txn[5]}]
set_property PACKAGE_PIN AH4 [get_ports {o_pcie_txp[5]}]
set_property LOC GTHE2_CHANNEL_X1Y17 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AF3 [get_ports {i_pcie_rxn[6]}]
set_property PACKAGE_PIN AF4 [get_ports {i_pcie_rxp[6]}]
set_property PACKAGE_PIN AJ1 [get_ports {o_pcie_txn[6]}]
set_property PACKAGE_PIN AJ2 [get_ports {o_pcie_txp[6]}]
set_property LOC GTHE2_CHANNEL_X1Y16 [get_cells {u_xdma_0/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN AG5 [get_ports {i_pcie_rxn[7]}]
set_property PACKAGE_PIN AG6 [get_ports {i_pcie_rxp[7]}]
set_property PACKAGE_PIN AK3 [get_ports {o_pcie_txn[7]}]
set_property PACKAGE_PIN AK4 [get_ports {o_pcie_txp[7]}]

# user link up
set_property PACKAGE_PIN AM39 [get_ports {o_led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_led[0]}]

# msix enable
set_property PACKAGE_PIN AN39 [get_ports {o_led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_led[1]}]

# status
set_property PACKAGE_PIN AP42 [get_ports {o_led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_led[2]}]

set_property PACKAGE_PIN AU39 [get_ports {o_led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_led[3]}]

# BPI FLASH
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]

create_pblock pblock_u_led
add_cells_to_pblock [get_pblocks pblock_u_led] [get_cells -quiet [list u_led]]
resize_pblock [get_pblocks pblock_u_led] -add {SLICE_X106Y475:SLICE_X133Y495}
resize_pblock [get_pblocks pblock_u_led] -add {DSP48_X7Y190:DSP48_X9Y197}
resize_pblock [get_pblocks pblock_u_led] -add {RAMB18_X7Y190:RAMB18_X8Y197}
resize_pblock [get_pblocks pblock_u_led] -add {RAMB36_X7Y95:RAMB36_X8Y98}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_u_led]
set_property SNAPPING_MODE ROUTING [get_pblocks pblock_u_led]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
