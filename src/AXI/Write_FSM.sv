`include "AXI_define.svh"
// `define WRITESTATE_IDLE 2'd0
// `define WRITESTATE_AWTRANS 2'd1
// `define WRITESTATE_WTRANS 2'd2
// `define WRITESTATE_BTRANS 2'd3

module Write_FSM(
  input ACLK,
  input ARESETn,
  input WLAST,
  input AWVALID,
  input AWHandShake,
  input WHandShake,
  input BHandShake,
  output logic [1:0] state
);
logic [1:0] Nstate;

always_ff @ (posedge ACLK or negedge ARESETn) begin
  if(~ARESETn) begin
    state <= `WRITESTATE_IDLE;
    end
  else  begin
    state <= Nstate;
    end
end

always_comb begin      
  case(state)
  `WRITESTATE_IDLE: begin
    if(AWHandShake)
      Nstate = (WHandShake&&WLAST)?`WRITESTATE_BTRANS:`WRITESTATE_WTRANS;
    else if(AWVALID)
      Nstate = `WRITESTATE_AWTRANS;
    else
      Nstate = `WRITESTATE_IDLE;
  end
  `WRITESTATE_AWTRANS: begin
    Nstate = (AWHandShake)? `WRITESTATE_WTRANS:`WRITESTATE_AWTRANS;
    end
  `WRITESTATE_WTRANS: begin
    Nstate = (WHandShake&&WLAST)? `WRITESTATE_BTRANS:`WRITESTATE_WTRANS;
    end     
  `WRITESTATE_BTRANS: begin
    Nstate = (BHandShake)? `WRITESTATE_IDLE:`WRITESTATE_BTRANS;
  end
  endcase 
end

endmodule
