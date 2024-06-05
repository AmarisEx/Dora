<h1 align="center" style="margin: 10px 0 10px; font-weight: bold;">Dora</h1>
<h4 align="center">a low-latency partial reconfiguration controller</h4>

# Introduction
- Dora, a low-latency FPGA partial reconfiguration controller, is proposed in this letter to address the latency challenge faced by traditional solutions in highly real-time reconfigurable systems.
- Based on the producer-consumer model, a streaming transmission mechanism and an adaptive ICAP overclocking clock training algorithm are proposed and integrated into Dora, aiming to achieve efficient production and consumption of configuration bitstreams.

# Structure
```txt
+------+-----------------------------------+---------------------+------+
|      |Instance                           |Module               |Cells |
+------+-----------------------------------+---------------------+------+
|1     |top                                |                     |  1616|
|2     |  u_prc_top                        |prc_top              |  1122|
|3     |    u_icap_ctrl                    |icap_ctrl            |     6|
|4     |    config_err_two_stage_sync      |two_stage_sync       |     2|
|5     |    u_axil_bridge                  |axil_bridge          |   176|
|6     |    u_clk_gen                      |clk_gen              |    24|
|7     |      u_mmcm_drp                   |mmcm_drp             |    24|
|8     |    u_config_buffer_0              |config_buffer        |   665|
|9     |      u_axis_async_fifo_0          |axis_async_fifo      |   665|
|10    |        u_async_fifo_0             |async_fifo           |   253|
|11    |          u_simple_dual_port_ram_0 |simple_dual_port_ram |    37|
|12    |        u_width_convert            |width_convert        |   407|
|13    |    u_perf_mon                     |perf_mon             |   207|
|14    |      b2c_cyc_counter              |counter              |    31|
|15    |      b2c_end_edge_two_stage_sync  |two_stage_sync_0     |     3|
|16    |      b2c_end_pos_edge_dect        |edge_dect            |     3|
|17    |      b2c_start_pos_edge_dect      |edge_dect_1          |    36|
|18    |      h2b_cyc_counter              |counter_2            |    31|
|19    |      h2b_end_pos_edge_dect        |edge_dect_3          |     2|
|20    |      h2b_start_pos_edge_dect      |edge_dect_4          |    71|
|21    |      h2c_cyc_counter              |counter_5            |    30|
|22    |    u_prc_reg                      |prc_reg              |    42|
+------+-----------------------------------+---------------------+------+

```

# Performance
Experiments show that Dora reduces FPGA resource utilization by over 60%, achieves a high reconfiguration rate, and slashes latency to 11.1 ms—merely 2.6% of the standard Xilinx solution. This remarkable performance positions Dora as a superior choice for a wide range of scenarios and domains.


# How to use

## For secondary development
All the modules in Dora are self-developed, and it is only necessary to integrate their verilog implementation (/rtl) into the project source code.

## Just for test
We provide an example (/example/vc709) on VC709 Board where users can test our Dora by switching between different lighting applications.
1. Configure the demo.bit
2. Install the xdma driver
3. Transfer rm0.bin or rm1.bin using driver
