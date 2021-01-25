//================================================
// Filename:    AWADDR_Reg.sv
// Description: Store Write Addr until it was used. 
// Version:     1.0
//================================================
`include "AXI_define.svh"

module AWADDR_Reg(
  input ACLK,
  input ARESETn,
  input [`AXI_ADDR_BITS-1:0] AWADDR,
  input AWHandShake,
  input BHandShake, //unused
  output logic [`AXI_ADDR_BITS-1:0] WADDR 
);
logic [`AXI_ADDR_BITS-1:0] _WADDR;
logic flag_change;
logic Nflag_change;

assign WADDR = (flag_change & AWHandShake)? AWADDR:_WADDR;

always_ff @(posedge ACLK or negedge ARESETn)
begin
  if (~ARESETn) begin
    _WADDR <= `AXI_ADDR_BITS'b0;
    flag_change <= 1'b1;
    end
  else begin
    _WADDR <= WADDR;
    flag_change <= Nflag_change;
    end
end
  
always_comb begin
	if(flag_change)
	  Nflag_change = (AWHandShake)? 1'b0 : flag_change;
	else
	  Nflag_change = (BHandShake)? 1'b1 : flag_change;
	  
end
endmodule
