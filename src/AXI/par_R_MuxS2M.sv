//================================================
// Filename:    R_MuxS2M.sv
// Description: Slave to master multiplexer which is for R channel
// Selector signal (Rsel_Slave) is from RSelSlave.
// Data is from input registers.
// Version:     1.0
// -------------- 20201206 ------------------
// parameter can decide slave count
// -------------- 20201207 ------------------
// add SelSlaveCount
//================================================
// Slave0 = 2'd0;
// Slave1 = 2'd1;
// DefaultSlave = 2'd2;
// SlaveCount = 3
`include "AXI_define.svh"

module par_R_MuxS2M(
  ACLK,
  ARESETn,
  RREADY,
  state,
  Rsel_Slave,
  
  RID_SS,
  RDATA_SS,
  RRESP_SS,
  RLAST_SS,
  RVALID_SS,
  
  RID_DS,
  RRESP_DS,  
  RVALID_DS,
  // output
  RID,RDATA,RRESP,RLAST,RVALID
);
parameter SelSlaveCount = 3;
parameter SlaveCount = 5;

input ACLK;
input ARESETn;
input RREADY;
input [1:0] state;
input [SelSlaveCount-1:0] Rsel_Slave;

input [SlaveCount-2:0][`AXI_IDS_BITS-1:0] RID_SS;
input [SlaveCount-2:0][`AXI_DATA_BITS-1:0] RDATA_SS;
input [SlaveCount-2:0][1:0] RRESP_SS;
input [SlaveCount-2:0] RLAST_SS;
input [SlaveCount-2:0] RVALID_SS;

input [`AXI_IDS_BITS-1:0] RID_DS;
input [1:0] RRESP_DS;  
input RVALID_DS;
// output
output logic [`AXI_IDS_BITS-1:0] RID;
output logic [`AXI_DATA_BITS-1:0] RDATA;
output logic [1:0] RRESP;
output logic RLAST;
output logic RVALID;
  
// To store parameters
logic [`AXI_IDS_BITS-1:0] _RID;
logic [`AXI_DATA_BITS-1:0] _RDATA;
logic [1:0] _RRESP;
logic _RLAST;
logic _RVALID;
logic _RREADY;

// Changed parameters
logic [`AXI_IDS_BITS-1:0] RID_tmp;
logic [`AXI_DATA_BITS-1:0] RDATA_tmp;
logic [1:0] RRESP_tmp;
logic RLAST_tmp;
logic RVALID_tmp;


always_ff @ (posedge ACLK or negedge ARESETn) begin
  if(~ARESETn) begin
    _RID <= 8'b0;
    _RDATA <= 32'b0;
    _RRESP <= 2'b00;
    _RLAST <= 1'b0;
    _RVALID <= 1'b0;
    _RREADY <= 1'b0;
    end
  else begin
    _RID <= RID;
    _RDATA <= RDATA;
    _RRESP <= RRESP;
    _RLAST <= RLAST;
    _RVALID <= RVALID;
    _RREADY <= RREADY;
    end
end
integer i;
always_comb begin
  RID_tmp=RID_DS;
  RDATA_tmp=`AXI_DATA_BITS'b0;
  RRESP_tmp=RRESP_DS;
  RLAST_tmp=1'b1;
  RVALID_tmp=RVALID_DS;

  for(i=0;i<SlaveCount-1;i=i+1)
    if(Rsel_Slave==i) begin      
      RID_tmp=RID_SS[i];
      RDATA_tmp=RDATA_SS[i];
      RRESP_tmp=RRESP_SS[i];
      RLAST_tmp=RLAST_SS[i];
      RVALID_tmp=RVALID_SS[i];
    end
    
  case(state)
  `READSTATE_IDLE: begin 
    RID = _RID;
    RDATA = _RDATA;
    RRESP = _RRESP; 
    RLAST = 1'b0;
    RVALID = 1'b0;
  end
  `READSTATE_ARTRANS: begin
    RID = _RID;
    RDATA = _RDATA;
    RRESP = _RRESP; 
    RLAST = _RLAST;
    RVALID = 1'b0;
  end
  `READSTATE_RTRANS: begin
    RID = (RVALID_tmp)? RID_tmp:_RID;
    RDATA = (RVALID_tmp)? RDATA_tmp:_RDATA;
    RRESP = (RVALID_tmp)? RRESP_tmp:_RRESP; 
    RLAST = (RVALID_tmp)? RLAST_tmp:_RLAST;
    if((RVALID_tmp)||(_RREADY&_RVALID==1'b1)) //start this state or Rhandshake
      RVALID = RVALID_tmp;
    else 
      RVALID = _RVALID;
  end
  default: begin
    RID = _RID;
    RDATA = _RDATA;
    RRESP = _RRESP; 
    RLAST = 1'b0;
    RVALID = 1'b0;
  end
  endcase
end
endmodule
