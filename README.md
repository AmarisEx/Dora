<h1 align="center" style="margin: 10px 0 10px; font-weight: bold;">Dora</h1>
<h4 align="center">a low-latency partial reconfiguration controller</h4>

# Introduction

- Dora, a low-latency FPGA partial reconfiguration controller, is proposed in this letter to address the latency challenge faced by traditional solutions in highly real-time reconfigurable systems.
- Based on the producer-consumer model, a SG-streaming-based hybrid reconfiguration mechanism and an adaptive ICAP overclocking clock training method are proposed and integrated into Dora, aiming to achieve efficient production and consumption of configuration bitstreams.

# Structure

```txt
.
├── README.md
├── example
│   └── vc709
│       ├── demo.bit
│       ├── rm0.bin
│       └── rm1.bin
├── hw
│   ├── rtl
│   │   ├── async_fifo.v
│   │   ├── axil_bridge.v
│   │   ├── axis_async_fifo.v
│   │   ├── clk_gen.v
│   │   ├── common.vh
│   │   ├── config_buffer.v
│   │   ├── counter.v
│   │   ├── edge_dect.v
│   │   ├── gray_code_sync.v
│   │   ├── icap_ctrl.v
│   │   ├── mmcm_drp.v
│   │   ├── perf_mon.v
│   │   ├── prc_reg.v
│   │   ├── prc_top.v
│   │   ├── reg_mux.v
│   │   ├── simple_dual_port_ram.v
│   │   ├── two_stage_sync.v
│   │   └── width_convert.v
│   └── xdc
│       └── prc_timing.xdc
└── sw
    ├── sdma
    │   ├── Makefile
    │   ├── sdma.h
    │   ├── sdma_drv.c
    │   └── sdma_hw.c
    └── test
        ├── main.c
        └── run.sh
```

# Performance

Experiments show that Dora reduces FPGA resource utilization by over 60%, achieves a high reconfiguration rate, and slashes latency to 11.1 ms—merely 2.6% of the standard Xilinx solution. This remarkable performance positions Dora as a superior choice for a wide range of scenarios and domains.

# How to use

## For secondary development

All the modules in Dora are self-developed, and it is only necessary to integrate the verilog implementation (/hw/rtl) and timing constraint (/hw/xdc) into the project source code.

## Just for test

We provide an example (/example/vc709) on VC709 Board where users can test our Dora by switching between different lighting applications.

1. Configure the demo.bit
2. Install the xdma driver
3. Transfer rm0.bin or rm1.bin using driver
