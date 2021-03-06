//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    def.svh
// Description: Hart defination
// Version:     0.1
//================================================
`ifndef DEF_SVH
`define DEF_SVH

// CPU
`define DATA_BITS 32

// Cache
`define CACHE_BLOCK_BITS 2
`define CACHE_INDEX_BITS 6
`define CACHE_TAG_BITS 22
`define CACHE_DATA_BITS 128
`define CACHE_LINES 2**(`CACHE_INDEX_BITS)
`define CACHE_WRITE_BITS 16
`define CACHE_TYPE_BITS 3
`define CACHE_BYTE `CACHE_TYPE_BITS'b000
`define CACHE_HWORD `CACHE_TYPE_BITS'b001
`define CACHE_WORD `CACHE_TYPE_BITS'b010
`define CACHE_BYTE_U `CACHE_TYPE_BITS'b100
`define CACHE_HWORD_U `CACHE_TYPE_BITS'b101

//Read Write data length
`define WRITE_LEN_BITS 2
`define BYTE `WRITE_LEN_BITS'b00
`define HWORD `WRITE_LEN_BITS'b01
`define WORD `WRITE_LEN_BITS'b10


// cache state
`define STATE_IDLE	 4'd0
`define STATE_READ	 4'd1
// `define STATE_READMISS	 4'd2
`define STATE_READSYS 	 4'd3
`define STATE_READDATA	 4'd4
`define STATE_WRITE	 4'd5
`define STATE_WRITEHIT 	 4'd6
`define STATE_WRITEMISS	 4'd7
// `define STATE_WRITESYS	 4'd8
`define STATE_WRITEDATA	 4'd9 
`define STATE_SENSORSYS	 4'd10 
`define STATE_SENSORDATA	 4'd11
`define STATE_SENSORSYS_w	 4'd12
`define STATE_SENSORDATA_w	 4'd13 

//////////////////////////////////////
//CNN
//////////////////////////////////////
`define WORDLENGTH 16
`define MAXIMUM_OUTPUT_CHANNEL 8
`define MAXIMUM_OUTPUT_LENGTH `MAXIMUM_OUTPUT_CHANNEL*`WORDLENGTH
`define KERNEL_SIZE 3*3
`define PICTURE_CHANNEL 3

`define LAYER1_WIDTH 32
`define LAYER1_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd31//32-1
`define LAYER1_BUFFER_LENGTH `WORDLENGTH'd29//32-3
`define LAYER1_SET_COUNT `WORDLENGTH'd67//32*2+3-1+1  + 1FOR PIPELINE
`define LAYER1_OUTPUT_LENGTH `LAYER1_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER1_WEIGHT_INPUT_LENGTH 48
`define LAYER1_WEIGHT_SET_COUNT `WORDLENGTH'd73//LAYER1_SYSTOLIC_WEIGHT_NUM SRAM:72+1
`define LAYER1_OUTPUT_CHANNEL_NUM 8
`define LAYER1_SYSTOLIC_WEIGHT_NUM `LAYER1_OUTPUT_CHANNEL_NUM*9
`define LAYER1_PIPELINE_ROW `WORDLENGTH'd1//
`define LAYER1_PIPELINE_COL `WORDLENGTH'd27//30-4+  2 prevent same address and read delay 1 cycle

`define LAYER2_WIDTH 30
`define LAYER2_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd29//30-1
`define LAYER2_BUFFER_LENGTH `WORDLENGTH'd27//30-3
`define LAYER2_SET_COUNT `WORDLENGTH'd64//`LAYER2_WIDTH*2+3-1+1+1//SRAM+1SRAM_REG+PIPELINE
`define LAYER2_OUTPUT_LENGTH `LAYER2_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER2_WEIGHT_INPUT_LENGTH 128//`LAYER1_OUTPUT_LENGTH
`define LAYER2_WEIGHT_SET_COUNT `WORDLENGTH'd73//LAYER2_SYSTOLIC_WEIGHT_NUM//SRAM:72+1+
`define LAYER2_OUTPUT_CHANNEL_NUM 8
`define LAYER2_SYSTOLIC_WEIGHT_NUM `LAYER2_OUTPUT_CHANNEL_NUM*9
`define LAYER2_PIPELINE_ROW `WORDLENGTH'd21
`define LAYER2_PIPELINE_COL `WORDLENGTH'd13//13
`define LAYER2_PIPELINE_ROW_VALUE `LAYER3_WIDTH-((`LAYER4_WIDTH**2-`LAYER4_WIDTH)/`LAYER3_WIDTH)-1
`define LAYER2_PIPELINE_COL_VALUE `LAYER3_WIDTH-((`LAYER4_WIDTH**2-`LAYER4_WIDTH)%`LAYER3_WIDTH)-1

`define LAYER3_WIDTH 28
`define LAYER3_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd13//LAYER4_WIDTH-1
`define LAYER3_SET_COUNT `LAYER3_WIDTH*1+2-1 //for no SRAM VERSION
`define LAYER3_OUTPUT_LENGTH `LAYER3_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER3_WEIGHT_INPUT_LENGTH 128//`LAYER2_OUTPUT_LENGTH
`define LAYER3_OUTPUT_CHANNEL_NUM 8


`define LAYER4_WIDTH 14
`define LAYER4_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd13//LAYER4_WIDTH-1
`define LAYER4_BUFFER_LENGTH `WORDLENGTH'd11//14-3
`define LAYER4_SET_COUNT `WORDLENGTH'd32//`LAYER4_WIDTH*2+3-1+1//SRAM+1PIPELINE
`define LAYER4_OUTPUT_LENGTH `LAYER4_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER4_WEIGHT_INPUT_LENGTH 128//`LAYER3_OUTPUT_LENGTH
`define LAYER4_WEIGHT_SET_COUNT `WORDLENGTH'd73//LAYER4_SYSTOLIC_WEIGHT_NUM//SRAM:72+1
`define LAYER4_OUTPUT_CHANNEL_NUM 8
`define LAYER4_SYSTOLIC_WEIGHT_NUM `LAYER4_OUTPUT_CHANNEL_NUM*9
`define LAYER4_PIPELINE_ROW `WORDLENGTH'd1//1
`define LAYER4_PIPELINE_COL `WORDLENGTH'd10//`LAYER5_WIDTH-4+2


`define LAYER5_WIDTH 12
`define LAYER5_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd11//12-1
`define LAYER5_BUFFER_LENGTH `WORDLENGTH'd9//12-3
`define LAYER5_SET_COUNT `WORDLENGTH'd28//`LAYER5_WIDTH*2+3-1+1//SRAM+1PIPELIME
`define LAYER5_OUTPUT_LENGTH `LAYER5_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER5_WEIGHT_INPUT_LENGTH 128//`LAYER4_OUTPUT_LENGTH
`define LAYER5_OUTPUT_CHANNEL_NUM 8
`define LAYER5_SYSTOLIC_WEIGHT_NUM `LAYER5_OUTPUT_CHANNEL_NUM*9
`define LAYER5_WEIGHT_SET_COUNT `WORDLENGTH'd73//LAYER5_SYSTOLIC_WEIGHT_NUM//SRAM:72+1
`define LAYER5_PIPELINE_ROW `WORDLENGTH'd7
`define LAYER5_PIPELINE_COL `WORDLENGTH'd9
`define LAYER5_PIPELINE_ROW_VALUE`LAYER6_WIDTH-((`LAYER7_WIDTH**2-`LAYER7_WIDTH)/`LAYER6_WIDTH)-1
`define LAYER5_PIPELINE_COL_VALUE `LAYER6_WIDTH-((`LAYER7_WIDTH**2-`LAYER7_WIDTH)%`LAYER6_WIDTH)-1

//______________________________________SRAM only in layer1~layer4 mem

`define LAYER6_WIDTH 10
`define LAYER6_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd4//LAYER7-1
`define LAYER6_SET_COUNT `LAYER6_WIDTH*1+2-1 
`define LAYER6_OUTPUT_LENGTH `LAYER6_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER6_WEIGHT_INPUT_LENGTH 128//`LAYER5_OUTPUT_LENGTH
`define LAYER6_OUTPUT_CHANNEL_NUM 8


`define LAYER7_WIDTH 5
`define LAYER7_READ_PIXEL_COUNT_COL_END `WORDLENGTH'd4//LAYER7-1
`define LAYER7_SET_COUNT 16'd26//`LAYER7_WIDTH**2 +1//SRAM
`define LAYER7_OUTPUT_LENGTH `LAYER7_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER7_WEIGHT_INPUT_LENGTH 128//`LAYER6_OUTPUT_LENGTH
`define LAYER7_OUTPUT_CHANNEL_NUM 10

`endif
