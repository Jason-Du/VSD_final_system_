//=====================================================
// File Name:   Arbiter_2M.sv                            
// Version:     2.0 
// Description:
// Select which master to active
// This version is 2 masters
//=======================================================
`include "AXI_define.svh"

module Arbiter_2M(
	input ACLK,
	input ARESETn,
  input HandShake,  
  input [1:0] VALID_2M,
  output [1:0] grant_2M_out // real output
);
logic [1:0] Last_grant_2M; // last - to be stable
logic [1:0] grant_M1toM0; // always change

// To decide when to change parameters
logic flag_change;
logic Nflag_change;

// To change ordering
logic mode;
logic Nmode;
logic [1:0] order; // LSB has higher priority than RSB

wire VALID;

assign VALID = |VALID_2M;
assign grant_2M_out = (flag_change&VALID)? grant_M1toM0:Last_grant_2M;   

always_ff@(posedge ACLK or negedge ARESETn)
begin
if(~ARESETn) begin
  Last_grant_2M <= 2'b00;
  flag_change <= 1'b1;
  mode <= 1'b0;
  end
else begin
  Last_grant_2M <= grant_2M_out;
  flag_change <= Nflag_change;
  mode <= Nmode;
  end    
end

always_comb begin
  if(flag_change) begin
    Nflag_change = (VALID)? 1'b0 : flag_change;
    end
  else begin
    Nflag_change = (HandShake)? 1'b1 : flag_change;
  end

  case(mode)
  1'd0: begin
    order = {VALID_2M[1],VALID_2M[0]};
    grant_M1toM0[0] = order[0]? 1'b1:1'b0;
    grant_M1toM0[1] = (order[1]&~order[0])? 1'b1:1'b0;
    end
  1'd1: begin
    order = {VALID_2M[0],VALID_2M[1]};
    grant_M1toM0[1] = order[0]? 1'b1:1'b0;
    grant_M1toM0[0] = (order[1]&~order[0])? 1'b1:1'b0;
    end
  endcase

  case(grant_2M_out)
  2'b01: Nmode = 1'd1;
  2'b10: Nmode = 1'd0;
  default: Nmode = 1'd0;
  endcase
end
endmodule
