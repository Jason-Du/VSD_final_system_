`ifndef AXI_SVH
`define AXI_SVH

`define AXI_ID_BITS 4
`define AXI_IDS_BITS 8
`define AXI_ADDR_BITS 32
`define AXI_LEN_BITS 4
`define AXI_SIZE_BITS 3
`define AXI_DATA_BITS 32
`define AXI_STRB_BITS 4
`define AXI_LEN_ONE 4'h0
`define AXI_SIZE_BYTE 3'b000
`define AXI_SIZE_HWORD 3'b001
`define AXI_SIZE_WORD 3'b010
`define AXI_BURST_INC 2'h1
`define AXI_STRB_WORD 4'b1111
`define AXI_STRB_HWORD 4'b0011
`define AXI_STRB_BYTE 4'b0001
`define AXI_RESP_OKAY 2'h0
`define AXI_RESP_SLVERR 2'h2
`define AXI_RESP_DECERR 2'h3
`define M0_F_ID 4'h1
`define M1_L_ID 4'h2
`define M1_S_ID 4'h3
`define INST_BITS 32
`define DATA_BITS 32
`define MAXPEND 2'd1

// Read FSM
`define READSTATE_IDLE 2'd0
`define READSTATE_ARTRANS 2'd1
`define READSTATE_RTRANS 2'd2
// Write FSM
`define WRITESTATE_IDLE 2'd0
`define WRITESTATE_AWTRANS 2'd1
`define WRITESTATE_WTRANS 2'd2
`define WRITESTATE_BTRANS 2'd3

`define DefaultSlave 3'd7

// slave address
// ROM
`define SLAVE0_ADDR_START 32'h0000_0000
`define SLAVE0_ADDR_END 32'h0000_1fff

// CPI IM
`define SLAVE1_ADDR_START 32'h0001_0000
`define SLAVE1_ADDR_END 32'h0001_ffff

// CPU DM
`define SLAVE2_ADDR_START 32'h0002_0000
`define SLAVE2_ADDR_END 32'h0002_ffff

// sensor control
`define SLAVE3_ADDR_START 32'h1000_0000
`define SLAVE3_ADDR_END 32'h1000_03ff

// DRAM
`define SLAVE4_ADDR_START 32'h2000_0000
`define SLAVE4_ADDR_END 32'h202f_ffff

// DMA
`define SLAVE5_ADDR_START 32'hf000_0000
`define SLAVE5_ADDR_END 32'hf000_ffff

// CNN
`define SLAVE6_ADDR_START 32'hd000_0000
`define SLAVE6_ADDR_END 32'hdfff_ffff


`define result_address             32'hd000_0000
`define image_set_register_ADDRESS 32'hd111_0000
`define interrupr_rsgister_ADDRESS 32'hd000_0200

`define local_weight_mem_ADDRESS_START 32'hd333_0000
`define local_weight_mem_ADDRESS_END 32'hd333_ffff


`define local_bias_mem_ADDRESS_START 32'hd444_0000
`define local_bias_mem_ADDRESS_END 32'hd444_ffff

`define local_pixel_mem_ADDRESS_START 32'hd555_0000
`define local_pixel_mem_ADDRESS_END  32'hd555_ffff

`endif
