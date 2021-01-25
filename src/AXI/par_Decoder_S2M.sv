// `include "AXI_define.svh"

module par_Decoder_S2M(ARsel_in,ARREADY_in,ARREADY_out);

parameter MasterCount = 2;

input [MasterCount-1:0] ARsel_in;
input ARREADY_in;
output [MasterCount-1:0] ARREADY_out;
 
assign ARREADY_out = ARsel_in & {MasterCount{ARREADY_in}};
/* integer i;
always_comb begin
  ARREADY_out = {{MasterCount-1{1'b0}},ARREADY_in}; 
  i=1;
  while(i<ARsel_in) begin
    ARREADY_out = {{MasterCount-1{1'b0}},ARREADY_in}<<1;
    i=i*2;
    end
end */
endmodule
