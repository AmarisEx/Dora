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
