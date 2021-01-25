//================================================
// Filename:    AR_MuxM2S.sv
// Description: Master to slave multiplexer which is for AR channel
// Selector signal (ARsel_Master) is from arbiter.
// Data is from input registers.
// Version:     1.0
// ------- 20201203 -------
// only mux 
//================================================
`include "AXI_define.svh"

module par_ARAW_MuxM2S(
ACLK,ARESETn,state,ARsel_Master,
ARID_MS,ARADDR_MS,ARLEN_MS,ARSIZE_MS,ARBURST_MS,ARVALID_MS,
ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID
);  
parameter MasterCount = 2;

input ACLK;
input ARESETn;
input [1:0] state;
input [MasterCount-1:0] ARsel_Master; //Arbiter to select which master to execute

// input : Masters
input [MasterCount-1:0][`AXI_ID_BITS-1:0] ARID_MS;
input [MasterCount-1:0][`AXI_ADDR_BITS-1:0] ARADDR_MS;
input [MasterCount-1:0][`AXI_LEN_BITS-1:0] ARLEN_MS;
input [MasterCount-1:0][`AXI_SIZE_BITS-1:0] ARSIZE_MS;
input [MasterCount-1:0][1:0] ARBURST_MS;
input [MasterCount-1:0] ARVALID_MS;

// output
output logic [`AXI_IDS_BITS-1:0] ARID;
output logic [`AXI_ADDR_BITS-1:0] ARADDR;
output logic [`AXI_LEN_BITS-1:0] ARLEN; 
output logic [`AXI_SIZE_BITS-1:0] ARSIZE;
output logic [1:0] ARBURST;
output logic ARVALID;

// To store parameters
logic [`AXI_IDS_BITS-1:0] _ARID; //fixed
logic [`AXI_ADDR_BITS-1:0] _ARADDR;
logic [`AXI_LEN_BITS-1:0] _ARLEN; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] _ARSIZE; // 0b010 == (Bytes in transfer=4)
logic [1:0] _ARBURST; 
logic _ARVALID;

// changed parameters
logic [`AXI_IDS_BITS-1:0] ARID_tmp; //fixed
logic [`AXI_ADDR_BITS-1:0] ARADDR_tmp;
logic [`AXI_LEN_BITS-1:0] ARLEN_tmp; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] ARSIZE_tmp; // 0b010 == (Bytes in transfer=4)
logic [1:0] ARBURST_tmp; 
logic ARVALID_tmp;

always_ff @ (posedge ACLK or negedge ARESETn) begin
  if(~ARESETn) begin
    _ARID <= 8'b0;
    _ARADDR <= 32'b0;
    _ARLEN <= 4'b0;
    _ARSIZE <= 3'b0;
    _ARBURST <= 2'b0;
    _ARVALID <= 1'b0;
    end
  else  begin
    _ARID <= ARID;
    _ARADDR <= ARADDR;
    _ARLEN <= ARLEN;
    _ARSIZE <= ARSIZE;
    _ARBURST <= ARBURST;
    _ARVALID <= ARVALID;
    end
end
integer i;
always_comb begin  
  ARID_tmp=`AXI_IDS_BITS'd0;
  ARADDR_tmp=`AXI_ADDR_BITS'd0;
  ARLEN_tmp=`AXI_LEN_BITS'd0;
  ARSIZE_tmp=`AXI_SIZE_BITS'd0;
  ARBURST_tmp=2'd0;
  ARVALID_tmp=1'b0;
  
  for(i=0;i<MasterCount;i=i+1)
    if(ARsel_Master[i]==1'b1) begin      
      ARID_tmp={i,ARID_MS[i]};
      ARADDR_tmp=ARADDR_MS[i];
      ARLEN_tmp=ARLEN_MS[i];
      ARSIZE_tmp=ARSIZE_MS[i];
      ARBURST_tmp=ARBURST_MS[i];
      ARVALID_tmp=ARVALID_MS[i];
    end
  /* case(ARsel_Master)
  4'b0001: begin
    ARID_tmp={4'b0000,ARID_M0};
    ARADDR_tmp=ARADDR_M0;
    ARLEN_tmp=ARLEN_M0;
    ARSIZE_tmp=ARSIZE_M0;
    ARBURST_tmp=ARBURST_M0;
    ARVALID_tmp=ARVALID_M0;
  end
  4'b0010: begin
    ARID_tmp={4'b0001,ARID_M1};
    ARADDR_tmp=ARADDR_M1;
    ARLEN_tmp=ARLEN_M1;
    ARSIZE_tmp=ARSIZE_M1;
    ARBURST_tmp=ARBURST_M1;
    ARVALID_tmp=ARVALID_M1;
  end
  4'b0100: begin
    ARID_tmp={4'b0010,ARID_M2};
    ARADDR_tmp=ARADDR_M2;
    ARLEN_tmp=ARLEN_M2;
    ARSIZE_tmp=ARSIZE_M2;
    ARBURST_tmp=ARBURST_M2;
    ARVALID_tmp=ARVALID_M2;
  end
  4'b1000: begin
    ARID_tmp={4'b0011,ARID_M3};
    ARADDR_tmp=ARADDR_M3;
    ARLEN_tmp=ARLEN_M3;
    ARSIZE_tmp=ARSIZE_M3;
    ARBURST_tmp=ARBURST_M3;
    ARVALID_tmp=ARVALID_M3;
  end
  default: begin
    ARID_tmp=`AXI_IDS_BITS'd0;
    ARADDR_tmp=`AXI_ADDR_BITS'd0;
    ARLEN_tmp=`AXI_LEN_BITS'd0;
    ARSIZE_tmp=`AXI_SIZE_BITS'd0;
    ARBURST_tmp=2'd0;
    ARVALID_tmp=1'b0;
  end
  endcase */
   
  case(state)
  `READSTATE_IDLE: begin
    ARVALID = (ARVALID_tmp)? 1'b1:_ARVALID;
    ARID = (ARVALID_tmp)? ARID_tmp:_ARID;
    ARADDR = (ARVALID_tmp)? ARADDR_tmp:_ARADDR;
    ARLEN = (ARVALID_tmp)? ARLEN_tmp:_ARLEN;
    ARSIZE = (ARVALID_tmp)? ARSIZE_tmp:_ARSIZE;
    ARBURST = (ARVALID_tmp)? ARBURST_tmp:_ARBURST;
  end
  `READSTATE_ARTRANS: begin
    ARVALID = _ARVALID;
    ARID = _ARID;
    ARADDR = _ARADDR;
    ARLEN = _ARLEN;
    ARSIZE = _ARSIZE;
    ARBURST = _ARBURST;
    end
  `READSTATE_RTRANS: begin
    ARVALID = 1'b0;
    ARID = _ARID;
    ARADDR = _ARADDR;
    ARLEN = _ARLEN;
    ARSIZE = _ARSIZE;
    ARBURST = _ARBURST;
  end
  default: begin
    ARVALID = 1'b0;
    ARID = _ARID;
    ARADDR = _ARADDR;
    ARLEN = _ARLEN;
    ARSIZE = _ARSIZE;
    ARBURST = _ARBURST;
  end
  endcase  
end
endmodule
