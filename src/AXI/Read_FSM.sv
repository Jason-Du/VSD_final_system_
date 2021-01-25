`include "AXI_define.svh"

module Read_FSM(
  input ARESETn,
  input ACLK,
  input ARVALID,
  input ARHandShake,
  input RHandShake,
  input RLAST,
  output logic [1:0] state
);
  logic [1:0] Nstate;
  
  always_ff @ (posedge ACLK or negedge ARESETn) begin
	if(~ARESETn) begin
      state <= `READSTATE_IDLE;
      end
    else  begin
      state <= Nstate;
      end
  end
  
  always_comb begin
    case(state)
    `READSTATE_IDLE: begin
      if(ARHandShake)
        Nstate = `READSTATE_RTRANS;
      else if(ARVALID)
        Nstate = `READSTATE_ARTRANS;
      else
        Nstate = `READSTATE_IDLE;
    end
    `READSTATE_ARTRANS: begin
      Nstate = (ARHandShake)? `READSTATE_RTRANS:`READSTATE_ARTRANS;
      end
    `READSTATE_RTRANS: begin
      Nstate = (RHandShake&RLAST)? `READSTATE_IDLE:`READSTATE_RTRANS;
    end
    default: begin
      Nstate = `READSTATE_IDLE;
    end
    endcase
  end
endmodule
