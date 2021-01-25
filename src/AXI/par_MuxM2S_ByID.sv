// `include "AXI_define.svh"

module par_MuxM2S_ByID(
ID,READY_in,READY_out
);
parameter MasterCount = 2;
input [3:0] ID;
input [MasterCount-1:0] READY_in;
output logic READY_out;

integer i;

always_comb begin
  READY_out = 1'b0;
  for(i=0;i<MasterCount;i=i+1)
    if(ID==i)
      READY_out=READY_in[i];
/*   case(ID)
  `ID_Master0:
    READY=READY0;
  `ID_Master1:
    READY=READY1;
  `ID_Master2:
    READY=READY2;
  `ID_Master3:
    READY=READY3;  
  default:
    READY=1'b0;  // READY_DM
  endcase */
end
endmodule
