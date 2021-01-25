// `include "AXI_define.svh"

module par_Decoder_ready(
sel,
READY_in,
READY_out
);
parameter OutCount = 6;
parameter selNum = 3;

input [selNum-1:0] sel;
input READY_in;
output logic [OutCount-1:0] READY_out;

integer i;
always_comb begin
  READY_out = {OutCount{1'b0}};
  for(i=0;i<OutCount;i=i+1)
    READY_out[i]=(sel==i)?READY_in:1'b0;

  /* case(sel)
  `Slave0: READY_out0=READY_in;
  `Slave1: READY_out1=READY_in;
  `Slave2: READY_out2=READY_in;
  `Slave3: READY_out3=READY_in;
  `Slave4: READY_out4=READY_in;
  `Slave5: READY_out5=READY_in;
  default: begin
    READY_outD=READY_in; 
  end
  endcase*/
end
endmodule
