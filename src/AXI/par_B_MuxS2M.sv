`include "AXI_define.svh"

module par_B_MuxS2M(
ACLK,ARESETn,AWVALID,state,Bsel_Slave,
BVALID_SS,BID_SS,BRESP_SS,
BVALID_DS,BID_DS,BRESP_DS,
BVALID,BID,BRESP
);
parameter SelSlaveCount = 3;
parameter SlaveCount = 5;


input ACLK;
input ARESETn;
input AWVALID;
input [1:0] state;
input [SelSlaveCount-1:0] Bsel_Slave;
// input : S0
input [SlaveCount-2:0] BVALID_SS;
input [SlaveCount-2:0][`AXI_IDS_BITS-1:0] BID_SS;
input [SlaveCount-2:0][1:0] BRESP_SS;
// input : DS
input BVALID_DS;
input [`AXI_IDS_BITS-1:0] BID_DS;
input [1:0] BRESP_DS;
// output
output logic BVALID;
output logic [`AXI_IDS_BITS-1:0] BID;
output logic [1:0] BRESP;

logic _BVALID;
logic [`AXI_IDS_BITS-1:0] _BID;
logic [1:0] _BRESP;

logic BVALID_tmp;
logic [`AXI_IDS_BITS-1:0] BID_tmp;
logic [1:0] BRESP_tmp;

always_ff @ (posedge ACLK or negedge ARESETn) begin
  if(~ARESETn) begin
    _BVALID <= 1'b0;
    _BID <= 8'b0;
    _BRESP <= 2'b0;
    end
  else begin
    _BVALID <= BVALID;
    _BID <= BID;
    _BRESP <= BRESP;
    end
end

integer i;

always_comb begin
  BVALID_tmp=BVALID_DS; 
  BID_tmp=BID_DS;
  BRESP_tmp=BRESP_DS;

  for(i=0;i<SlaveCount-1;i=i+1)
    if(Bsel_Slave==i) begin      
      BVALID_tmp=BVALID_SS[i];
      BID_tmp=BID_SS[i];
      BRESP_tmp=BRESP_SS[i];
    end
/* 
  case(Bsel_Slave)
    `Slave0: begin
      BVALID_tmp=BVALID_S0;
      BID_tmp=BID_S0[3:0];
      BRESP_tmp=BRESP_S0;
      end
    `Slave1: begin
      BVALID_tmp=BVALID_S1;    
      BID_tmp=BID_S1[3:0];
      BRESP_tmp=BRESP_S1;
      end
    `Slave2: begin
      BVALID_tmp=BVALID_S2;    
      BID_tmp=BID_S2[3:0];
      BRESP_tmp=BRESP_S2;
      end
    `Slave3: begin
      BVALID_tmp=BVALID_S3;    
      BID_tmp=BID_S3[3:0];
      BRESP_tmp=BRESP_S3;
      end  
    `Slave4: begin
      BVALID_tmp=BVALID_S4;    
      BID_tmp=BID_S4[3:0];
      BRESP_tmp=BRESP_S4;
      end 
    `Slave5: begin
      BVALID_tmp=BVALID_S5;    
      BID_tmp=BID_S5[3:0];
      BRESP_tmp=BRESP_S5;
      end       
    default: begin
      BVALID_tmp=BVALID_DS; 
      BID_tmp=BID_DS[3:0];
      BRESP_tmp=BRESP_DS;
      end
  endcase
 */
  case(state)
  `WRITESTATE_IDLE: begin
    BVALID = 1'b0;
    BID = _BID;
    BRESP = _BRESP;
    end
  `WRITESTATE_AWTRANS: begin
    BVALID = 1'b0;
    BID = _BID;
    BRESP = _BRESP;
    end
  `WRITESTATE_WTRANS: begin
    BVALID = 1'b0;
    BID = _BID;
    BRESP = _BRESP;
    end
  `WRITESTATE_BTRANS: begin
    BVALID = (BVALID_tmp)? BVALID_tmp:_BVALID;
    BID = (BVALID_tmp)? BID_tmp:_BID;
    BRESP = (BVALID_tmp)? BRESP_tmp:_BRESP;
    end
  endcase 
end
endmodule


