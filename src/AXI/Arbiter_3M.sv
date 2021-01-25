//=====================================================
// File Name:   Arbiter_3M.sv                            
// Version:     2.0 
// Description:
// Select which master to active
// This version is 3 masters
//=======================================================
`include "AXI_define.svh"

module Arbiter_3M(
	input ACLK,
	input ARESETn,
  input HandShake,  
  input [2:0] VALID_3M,
  output [2:0] grant_3M_out
);
logic [2:0] Last_grant_3M;// last
logic [2:0] grant_3M;// changed

// To decide when to change parameters
logic flag_change;
logic Nflag_change;

logic [1:0] mode;
logic [1:0] Nmode;
logic [2:0] order; // LSB has higher priority than RSB

wire VALID;

assign VALID = |VALID_3M;

assign grant_3M_out = (flag_change&VALID)? grant_3M:Last_grant_3M;   

always_ff@(posedge ACLK or negedge ARESETn)
begin
if(~ARESETn) begin
  Last_grant_3M <= 3'b000;
  flag_change <= 1'b1;
  mode <= 2'd0;
  end
else begin
  Last_grant_3M <= grant_3M_out;
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
  2'd0: begin
    order = {VALID_3M[2],VALID_3M[1],VALID_3M[0]};
    grant_3M[0] = order[0]? 1'b1:1'b0;
    grant_3M[1] = (order[1]&~order[0])? 1'b1:1'b0;
    grant_3M[2] = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end
  2'd1: begin
    order = {VALID_3M[0],VALID_3M[2],VALID_3M[1]};
    grant_3M[1] = order[0]? 1'b1:1'b0;
    grant_3M[2] = (order[1]&~order[0])? 1'b1:1'b0;
    grant_3M[0] = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end 
  2'd2: begin
    order = {VALID_3M[1],VALID_3M[0],VALID_3M[2]};
    grant_3M[2] = order[0]? 1'b1:1'b0;
    grant_3M[0] = (order[1]&~order[0])? 1'b1:1'b0;
    grant_3M[1] = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end 
  default: begin
    order = {VALID_3M[2],VALID_3M[1],VALID_3M[0]};
    grant_3M[0] = 1'b0;
    grant_3M[1] = 1'b0;
    grant_3M[2] = 1'b0;
    end
  
  endcase

  case(grant_3M_out)
  3'b001: Nmode = 2'd2;
  3'b010: Nmode = 2'd1;
  3'b100: Nmode = 2'd0;
  default: Nmode = 2'd0; 
  endcase
end
endmodule
