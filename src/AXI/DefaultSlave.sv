`include "AXI_define.svh"

module DefaultSlave(
  input ACLK,
  input ARESETn,
  // AR channel
  input ARVALID_DS,
  output logic ARREADY_DS,
  input [7:0] ARID_DS,
  // R channel
  input RREADY_DS,
  output logic RVALID_DS,
  output logic [1:0] RRESP_DS,
  output logic [7:0] RID_DS,
  // AW channel
  input AWVALID_DS,
  input [7:0] AWID_DS,
  output logic AWREADY_DS, 
  
  // W channel
  input WVALID_DS,
  output logic WREADY_DS,
  // B channel
  input BREADY_DS,
  output logic BVALID_DS,
  output logic [1:0] BRESP_DS,
  output logic [7:0] BID_DS  
);

logic NRVALID_DS;
// logic [1:0] NRRESP_DS;
logic NBVALID_DS;
// logic [1:0] NBRESP_DS;
//logic [3:0] Store_RID_DS;
logic [7:0] NStore_RID_DS;
logic [7:0] NStore_BID_DS;


wire ARhandshake = ARVALID_DS&ARREADY_DS;
wire Whandshake = WVALID_DS&WREADY_DS;
assign ARREADY_DS = 1'd1;
assign AWREADY_DS = 1'd1;
assign WREADY_DS = 1'd1;

always_ff @(posedge ACLK or negedge ARESETn)
begin
  if (~ARESETn) begin
    RVALID_DS <= 1'b0;
    BVALID_DS <= 1'b0;
    RID_DS <= 8'b0;
    BID_DS <= 8'b0;
    end
  else begin
    RVALID_DS <= NRVALID_DS;
    BVALID_DS <= NBVALID_DS;
    RID_DS <= NStore_RID_DS;
    BID_DS <= NStore_BID_DS;
  end
end

always_comb
begin
  if(ARhandshake)
    NStore_RID_DS = ARID_DS;
  else
    NStore_RID_DS = RID_DS;
    
// For Read
  if (ARhandshake) begin
    NRVALID_DS = 1'b1;

    end
  else if (RREADY_DS) begin
    NRVALID_DS = 1'b0;
    end
  else begin
    NRVALID_DS = RVALID_DS;
    end


  if(RVALID_DS)
    RRESP_DS = `AXI_RESP_DECERR;
  else
    RRESP_DS = `AXI_RESP_OKAY;
    
// For Write
  if(Whandshake)
    NStore_BID_DS = AWID_DS;
  else
    NStore_BID_DS = BID_DS;


  if (Whandshake)
    NBVALID_DS = 1'b1;
  else if (BREADY_DS)
    NBVALID_DS = 1'b0;
  else
    NBVALID_DS = BVALID_DS;

  if(BVALID_DS)
    BRESP_DS = `AXI_RESP_DECERR;
  else
    BRESP_DS = `AXI_RESP_OKAY;
end

endmodule
