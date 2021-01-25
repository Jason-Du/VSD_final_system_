// Usage:
// par_SelSlave #(.SlaveCount(t_SlaveCount),.SelSlaveCount(t_SelSlaveCount))
// par_SelSlave_my(
// ACLK,ARESETn,VALID_Slave,
// AddrHandShake,RespHandShake,sel_Slave);
`include "AXI_define.svh"

module par_SelSlave(
ACLK,ARESETn,VALID_Slave,
AddrHandShake,RespHandShake,sel_Slave);

parameter SlaveCount = 7;
parameter SelSlaveCount = 3;

input ACLK;
input ARESETn;
input [SlaveCount-1:0] VALID_Slave;
input AddrHandShake;
input RespHandShake;
output logic [SelSlaveCount-1:0] sel_Slave;

logic [SelSlaveCount-1:0] sel_Slave_tmp;
logic [SelSlaveCount-1:0] _sel_Slave;

// To decide when to change parameters
logic flag_change;
logic Nflag_change;

always_ff@(posedge ACLK or negedge ARESETn)
begin
  if(~ARESETn) begin
    _sel_Slave <= `DefaultSlave;
    flag_change <= 1'b1;
    end
  else begin
    _sel_Slave <= sel_Slave;  
    flag_change <= Nflag_change;
  end    
end

integer i;

always_comb begin
  sel_Slave_tmp = `DefaultSlave;
  for(i=0;i<SlaveCount;i=i+1)
    if(VALID_Slave[i]==1'b1)
      sel_Slave_tmp = i;
  /* case(VALID_Slave)
  7'd1: sel_Slave_tmp = `Slave0;
  7'd2: sel_Slave_tmp = `Slave1;
  7'd4: sel_Slave_tmp = `Slave2;
  7'd8: sel_Slave_tmp = `Slave3;
  7'd16: sel_Slave_tmp = `Slave4;
  7'd32: sel_Slave_tmp = `Slave5;
  7'd64: sel_Slave_tmp = `DefaultSlave;      
  default: sel_Slave_tmp = `DefaultSlave; 
  endcase */
  
  if(flag_change) begin
    Nflag_change = (AddrHandShake)? 1'b0 : flag_change;
    sel_Slave = (AddrHandShake)? sel_Slave_tmp:_sel_Slave;
    end
  else begin
    Nflag_change = (RespHandShake)? 1'b1 : flag_change;
    sel_Slave = _sel_Slave;
    end
end
endmodule
