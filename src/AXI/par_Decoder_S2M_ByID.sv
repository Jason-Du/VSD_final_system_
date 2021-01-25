// `include "AXI_define.svh"

module par_Decoder_S2M_ByID(
ID,Din,Dout
);
parameter MasterCount = 2;

input [3:0] ID;
input Din;
output logic [MasterCount-1:0] Dout;

integer i;

always_comb begin
  for(i=0;i<MasterCount;i=i+1)
    Dout[i]=(ID==i)?Din:1'b0;
end
// assign Dout0 = (ID==`ID_Master0)? Din:1'b0;
// assign Dout1 = (ID==`ID_Master1)? Din:1'b0;
// assign Dout2 = (ID==`ID_Master2)? Din:1'b0;
// assign Dout3 = (ID==`ID_Master3)? Din:1'b0;
endmodule
