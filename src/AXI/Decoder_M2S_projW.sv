// Without considering Slave0
`include "AXI_define.svh"

module Decoder_M2S_projW(
  input VALID,
  input [31:0] ADDR,

  output [6:0] VALID_SS
); 
wire [5:0] IS_SLAVE;

assign IS_SLAVE[0] = ((ADDR>=`SLAVE1_ADDR_START)&&(ADDR<=`SLAVE1_ADDR_END));
assign IS_SLAVE[1] = ((ADDR>=`SLAVE2_ADDR_START)&&(ADDR<=`SLAVE2_ADDR_END));
assign IS_SLAVE[2] = ((ADDR>=`SLAVE3_ADDR_START)&&(ADDR<=`SLAVE3_ADDR_END));
assign IS_SLAVE[3] = ((ADDR>=`SLAVE4_ADDR_START)&&(ADDR<=`SLAVE4_ADDR_END));
assign IS_SLAVE[4] = ((ADDR>=`SLAVE5_ADDR_START)&&(ADDR<=`SLAVE5_ADDR_END));
assign IS_SLAVE[5] = ((ADDR>=`SLAVE6_ADDR_START)&&(ADDR<=`SLAVE6_ADDR_END));

assign VALID_SS[0] = (IS_SLAVE[0])? VALID:1'b0;
assign VALID_SS[1] = (IS_SLAVE[1])? VALID:1'b0;
assign VALID_SS[2] = (IS_SLAVE[2])? VALID:1'b0;
assign VALID_SS[3] = (IS_SLAVE[3])? VALID:1'b0;
assign VALID_SS[4] = (IS_SLAVE[4])? VALID:1'b0;
assign VALID_SS[5] = (IS_SLAVE[5])? VALID:1'b0;
assign VALID_SS[6] = (|IS_SLAVE)? 1'b0:VALID;

endmodule
