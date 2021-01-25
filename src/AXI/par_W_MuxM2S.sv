`include "AXI_define.svh"
module par_W_MuxM2S(
ACLK,ARESETn,state,sel_Master,
WDATA_MS,WSTRB_MS,WLAST_MS,WVALID_MS,
WDATA,WSTRB,WLAST,WVALID
);
parameter MasterCount = 2;

input ACLK;
input ARESETn;
input [1:0] state;
input [MasterCount-1:0] sel_Master;

// input : Masters
input [MasterCount-1:0][`AXI_DATA_BITS-1:0] WDATA_MS;
input [MasterCount-1:0][`AXI_STRB_BITS-1:0] WSTRB_MS;
input [MasterCount-1:0] WLAST_MS;
input [MasterCount-1:0] WVALID_MS;

// output
output logic [`AXI_DATA_BITS-1:0] WDATA;
output logic [`AXI_STRB_BITS-1:0] WSTRB;
output logic WLAST;
output logic WVALID;

// To store parameters
logic [`AXI_DATA_BITS-1:0] _WDATA;
logic [`AXI_STRB_BITS-1:0] _WSTRB;
logic _WLAST;
logic _WVALID;

// changed parameters
logic [`AXI_DATA_BITS-1:0] WDATA_tmp;
logic [`AXI_STRB_BITS-1:0] WSTRB_tmp;
logic WLAST_tmp;
logic WVALID_tmp;
  
always_ff @ (posedge ACLK or negedge ARESETn) begin
  if(~ARESETn) begin
    _WDATA <= 32'b0;
    _WSTRB <= 4'b0;
    _WLAST <= 1'b0;
    _WVALID <= 1'b0;
    end
  else  begin
    _WDATA <= WDATA;
    _WSTRB <= WSTRB;
    _WLAST <= WLAST;
    _WVALID <= WVALID;
    end
end

integer i;
always_comb begin 
  WDATA_tmp=`AXI_DATA_BITS'b0;
  WSTRB_tmp=`AXI_STRB_BITS'b1111;
  WLAST_tmp=1'b0;
  WVALID_tmp=1'b0;
  
  for(i=0;i<MasterCount;i=i+1)
    if(sel_Master[i]==1'b1) begin      
      WDATA_tmp=WDATA_MS[i];
      WSTRB_tmp=WSTRB_MS[i];
      WLAST_tmp=WLAST_MS[i];
      WVALID_tmp=WVALID_MS[i];
      end
     
  case(state)
  `WRITESTATE_IDLE: begin
    WVALID = (WVALID_tmp)? 1'b1:_WVALID;
    WDATA = (WVALID_tmp)? WDATA_tmp:_WDATA;
    WSTRB = (WVALID_tmp)? WSTRB_tmp:_WSTRB;
    WLAST = (WVALID_tmp)? WLAST_tmp:_WLAST;
    end

  `WRITESTATE_WTRANS: begin
    WVALID = (WVALID_tmp)? 1'b1:_WVALID;
    WDATA = (WVALID_tmp)? WDATA_tmp:_WDATA;
    WSTRB = (WVALID_tmp)? WSTRB_tmp:_WSTRB;
    WLAST = (WVALID_tmp)? WLAST_tmp:_WLAST;
    end
  `WRITESTATE_BTRANS: begin
    WVALID = 1'b0;
    
    WDATA = _WDATA;
    WSTRB =`AXI_STRB_BITS'b1111;
    // WLAST = _WLAST;
	WLAST = 1'b0;
  end
  default: begin
    WVALID = 1'b0;
    
    WDATA = _WDATA;
    WSTRB = `AXI_STRB_BITS'b1111;
    WLAST = 1'b0;
  end
  endcase  
end
endmodule
