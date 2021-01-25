module par_MuxS2M_Ready(
VALID_SS,READYs_in,READY_out
);
parameter SlaveCount = 6;
// selection signal
input [SlaveCount-1:0] VALID_SS;
// input signal  
input [SlaveCount-1:0] READYs_in;
output logic READY_out;

integer i;
always_comb begin
  READY_out = 1'b0;
  for(i=0;i<SlaveCount;i=i+1)
    if(VALID_SS[i]==1'b1)
    READY_out = READYs_in[i];
/*   case(VALID_DS_S4toS0)
  6'd1: READY=READY_DS_S4toS0[0];
  6'd2: READY=READY_DS_S4toS0[1];
  6'd4: READY=READY_DS_S4toS0[2];
  6'd8: READY=READY_DS_S4toS0[3];
  6'd16: READY=READY_DS_S4toS0[4];
  6'd32: READY=READY_DS_S4toS0[5];
  default: READY=1'b0;  
  endcase */
end
endmodule
