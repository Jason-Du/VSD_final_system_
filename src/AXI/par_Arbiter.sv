//=====================================================
// File Name:   Arbiter_2M.sv                            
// Version:     2.0 
// Description:
// Select which master to active
// This version is two masters
// sel_Src 2 bits
//=======================================================
`include "AXI_define.svh"

module par_Arbiter(
	input ACLK,
	input ARESETn,
  input HandShake,  
  input VALID_M0,
  input VALID_M1,
  // input VALID_M2,
  // input VALID_M3,

  output [1:0] grant_M1toM0_out
);

parameter Count = 3;


// last - to be stable
logic [1:0] Last_sel_Src;
// changed 
// logic [1:0] sel_Src_tmp; 

// To decide when to change parameters
logic flag_change;
logic Nflag_change;

logic mode;
logic Nmode;
logic [1:0] grant_M1toM0;
// logic grant_M2;
// logic grant_M3;
logic [1:0] order;
// LSB has higher priority than RSB

wire VALID;

assign VALID = VALID_M0|VALID_M1/*|VALID_M2|VALID_M3*/;
assign grant_M1toM0_out = (flag_change&VALID)? grant_M1toM0:Last_sel_Src;   

always_ff@(posedge ACLK or negedge ARESETn)
begin
if(~ARESETn) begin
  Last_sel_Src <= 2'b00;
  flag_change <= 1'b1;
  mode <= 2'd0;
  end
else begin
  Last_sel_Src <= grant_M1toM0_out;
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
    order = {VALID_M1,VALID_M0};
    grant_M1toM0[0] = order[0]? 1'b1:1'b0;
    grant_M1toM0[1] = (order[1]&~order[0])? 1'b1:1'b0;
    // grant_M2 = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    // grant_M3 = (order[3]&~order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end
  1'd1: begin
    order = {VALID_M0,VALID_M1};
    grant_M1toM0[1] = order[0]? 1'b1:1'b0;
    // grant_M2 = (order[1]&~order[0])? 1'b1:1'b0;
    // grant_M3 = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    grant_M1toM0[0] = (order[1]&~order[0])? 1'b1:1'b0;
    end
  /*2'd2: begin
    order = {VALID_M1,VALID_M0,VALID_M3,VALID_M2};
    grant_M2 = order[0]? 1'b1:1'b0;
    grant_M3 = (order[1]&~order[0])? 1'b1:1'b0;
    grant_M0 = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    grant_M1 = (order[3]&~order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end 
  2'd3: begin
    order = {VALID_M2,VALID_M1,VALID_M0,VALID_M3};
    grant_M3 = order[0]? 1'b1:1'b0;
    grant_M0 = (order[1]&~order[0])? 1'b1:1'b0;
    grant_M1 = (order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    grant_M2 = (order[3]&~order[2]&~order[1]&~order[0])? 1'b1:1'b0;
    end */
  endcase

  case(grant_M1toM0_out)
  2'b01: Nmode = 1'd1;
  2'b10: Nmode = 1'd0;
  // 2'b01: Nmode = 2'd3;
  // 2'b01: Nmode = 2'd0;
  default: Nmode = 1'd0;
  endcase
end
endmodule
