`ifndef CNN_SVH
`define CNN_SVH

`define WORDLENGTH 16
`define MAXIMUM_OUTPUT_CHANNEL 8
`define MAXIMUM_OUTPUT_LENGTH `MAXIMUM_OUTPUT_CHANNEL*`WORDLENGTH


`define LAYER1_WIDTH 32
`define LAYER1_SET_COUNT `LAYER1_WIDTH*2+3-1
`define LAYER1_OUTPUT_LENGTH `LAYER1_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER1_WEIGHT_INPUT_LENGTH 48
`define LAYER1_OUTPUT_CHANNEL_NUM 8
`define LAYER1_SYSTOLIC_WEIGHT_NUM `LAYER1_OUTPUT_CHANNEL_NUM*9

`define LAYER2_WIDTH 30
`define LAYER2_SET_COUNT `LAYER2_WIDTH*2+3-1 
`define LAYER2_OUTPUT_LENGTH `LAYER2_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER2_WEIGHT_INPUT_LENGTH `LAYER1_OUTPUT_LENGTH
`define LAYER2_OUTPUT_CHANNEL_NUM 8
`define LAYER2_SYSTOLIC_WEIGHT_NUM `LAYER2_OUTPUT_CHANNEL_NUM*9


`define LAYER3_WIDTH 28
`define LAYER3_SET_COUNT `LAYER3_WIDTH*1+2-1 
`define LAYER3_OUTPUT_LENGTH `LAYER3_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER3_WEIGHT_INPUT_LENGTH `LAYER2_OUTPUT_LENGTH
`define LAYER3_OUTPUT_CHANNEL_NUM 8


`define LAYER4_WIDTH 14
`define LAYER4_SET_COUNT `LAYER4_WIDTH*2+3-1
`define LAYER4_OUTPUT_LENGTH `LAYER4_OUTPUT_CHANNEL_NUM*`WORDLENGTH
`define LAYER4_WEIGHT_INPUT_LENGTH `LAYER3_OUTPUT_LENGTH
`define LAYER4_OUTPUT_CHANNEL_NUM 8
`define LAYER4_SYSTOLIC_WEIGHT_NUM `LAYER4_OUTPUT_CHANNEL_NUM*9


/*
`define LAYER3_SYSTOLIC_WEIGHT_NUM `LAYER1_OUTPUT_CHANNEL_NUM*9
*/


`endif
