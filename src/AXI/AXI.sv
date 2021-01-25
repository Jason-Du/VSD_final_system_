//================================================         
// Filename:    AXI.sv                            
// Description: Top module of AXI 
// project & parameterize 3M/7S                
// Version:     1.0 
// ---20210113---
// remove read ports of slave 5
//================================================
// WRITE: M1, M2
// READ : M0, M1, M2
// WRITE: S1~S6 (x S0-ROM)
// READ : S0~S6 (x S5)

// Master0 3'd0 //CPU IM
// Master1 3'd1 //CPU DM
// Master2 3'd2 //DMA
// DefaultMaster 3'd3

// Slave0 3'd0 //ROM
// Slave1 3'd1 //SRAM IM
// Slave2 3'd2 //SRAM DM
// Slave3 3'd3 //sensor
// Slave4 3'd4 //DRAM
// Slave5 3'd5 //DMA xREAD
// Slave6 3'd6 //CNN
// DefaultSlave 3'd7

//================================================
`include "AXI_define.svh"
// FSM
`include "Read_FSM.sv"
`include "Write_FSM.sv"
// Some channels
`include "Arbiter_2M.sv" // AR
`include "Arbiter_3M.sv" // AW
`include "par_MuxS2M_Ready.sv" //AR AW W
`include "Decoder_M2S_projR.sv" //AR R
`include "Decoder_M2S_projW.sv" //AW W
`include "par_Decoder_ready.sv" //R B
`include "par_Register.sv" //R B - DefaultSlave
`include "par_Register_1b.sv" //R B - DefaultSlave
// One channel
`include "par_ARAW_MuxM2S.sv" //AR
`include "par_Decoder_S2M.sv" //AR
`include "par_Decoder_S2M_ByID.sv" //R
`include "par_MuxM2S_ByID.sv" //R
`include "par_R_MuxS2M.sv" //R
`include "par_B_MuxS2M.sv" //B
`include "par_W_MuxM2S.sv" //W 
// cross channel
`include "AWADDR_Reg.sv" //AW & W
`include "DefaultSlave.sv" //all
`include "par_SelSlave.sv" //AR R, AW W B

module AXI(
	input ACLK,
	input ARESETn,

	//MASTER INTERFACE
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,

	input AWVALID_M1,
	output AWREADY_M1,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output WREADY_M1,
	//WRITE RESPONSE
	output [`AXI_ID_BITS-1:0] BID_M1,
	output [1:0] BRESP_M1,
	output BVALID_M1,
	input BREADY_M1,
  /*---------------------------------*/
  /*--- WRITE CHANNELS : Master 2 ---*/
  /*---------------------------------*/
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M2, // = fixed
	input [`AXI_ADDR_BITS-1:0] AWADDR_M2,
	input [`AXI_LEN_BITS-1:0] AWLEN_M2,  // 0 == (len=1)
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M2, // 0b010 == (Bytes in transfer=4)
	input [1:0] AWBURST_M2, // = INCR = 0b01
	input AWVALID_M2,
	output AWREADY_M2,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	output WREADY_M2,
	//WRITE RESPONSE
	output [`AXI_ID_BITS-1:0] BID_M2,
	output [1:0] BRESP_M2,
	output BVALID_M2,
	input BREADY_M2,

  /*--------------------------------*/
  /*--- READ CHANNELS : Master 0 ---*/
  /*--------------------------------*/
	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,

	input ARVALID_M0,
	output ARREADY_M0,
	//READ DATA0
	output [`AXI_ID_BITS-1:0] RID_M0,
	output [`AXI_DATA_BITS-1:0] RDATA_M0,
	output [1:0] RRESP_M0,
	output RLAST_M0,
	output RVALID_M0,
	input RREADY_M0,

  /*--------------------------------*/
  /*--- READ CHANNELS : Master 1 ---*/
  /*--------------------------------*/
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1, // 0 == (len=1)
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1, // 0b010 == (Bytes in transfer=4)
	input [1:0] ARBURST_M1,  // = INCR = 0b01
	input ARVALID_M1,
	output ARREADY_M1,
	//READ DATA1
	output [`AXI_ID_BITS-1:0] RID_M1,
	output [`AXI_DATA_BITS-1:0] RDATA_M1,
	output [1:0] RRESP_M1,
	output RLAST_M1,
	output RVALID_M1,
	input RREADY_M1,

  /*--------------------------------*/
  /*--- READ CHANNELS : Master 2 ---*/
  /*--------------------------------*/
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M2,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M2,
	input [`AXI_LEN_BITS-1:0] ARLEN_M2, // 0 == (len=1)
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M2, // 0b010 == (Bytes in transfer=4)
	input [1:0] ARBURST_M2,  // = INCR = 0b01
	input ARVALID_M2,
	output ARREADY_M2,
	//READ DATA1
	output [`AXI_ID_BITS-1:0] RID_M2,
	output [`AXI_DATA_BITS-1:0] RDATA_M2,
	output [1:0] RRESP_M2,
	output RLAST_M2,
	output RVALID_M2,
	input RREADY_M2,

	//SLAVE INTERFACE
	/*//WRITE ADDRESS0
	output [`AXI_IDS_BITS-1:0] AWID_S0,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output [1:0] AWBURST_S0,
	output AWVALID_S0,
	input AWREADY_S0,
	//WRITE DATA0
	output [`AXI_DATA_BITS-1:0] WDATA_S0,
	output [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output WLAST_S0,
	output WVALID_S0,
	input WREADY_S0,
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output BREADY_S0,
	*/
	//WRITE ADDRESS1
	output [`AXI_IDS_BITS-1:0] AWID_S1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output [1:0] AWBURST_S1,

	output AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output [`AXI_DATA_BITS-1:0] WDATA_S1,
	output [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output WLAST_S1,
	output WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output BREADY_S1,
	
	//WRITE ADDRESS2
	output [`AXI_IDS_BITS-1:0] AWID_S2,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output [1:0] AWBURST_S2,

	output AWVALID_S2,
	input AWREADY_S2,
	//WRITE DATA2
	output [`AXI_DATA_BITS-1:0] WDATA_S2,
	output [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output WLAST_S2,
	output WVALID_S2,
	input WREADY_S2,
	//WRITE RESPONSE2
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output BREADY_S2,
	
	//WRITE ADDRESS3
	output [`AXI_IDS_BITS-1:0] AWID_S3,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output [1:0] AWBURST_S3,

	output AWVALID_S3,
	input AWREADY_S3,
	//WRITE DATA3
	output [`AXI_DATA_BITS-1:0] WDATA_S3,
	output [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output WLAST_S3,
	output WVALID_S3,
	input WREADY_S3,
	//WRITE RESPONSE3
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output BREADY_S3,
	
	//WRITE ADDRESS4
	output [`AXI_IDS_BITS-1:0] AWID_S4,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output [1:0] AWBURST_S4,

	output AWVALID_S4,
	input AWREADY_S4,
	//WRITE DATA4
	output [`AXI_DATA_BITS-1:0] WDATA_S4,
	output [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output WLAST_S4,
	output WVALID_S4,
	input WREADY_S4,
	//WRITE RESPONSE4
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output BREADY_S4,
  
  //WRITE ADDRESS5
	output [`AXI_IDS_BITS-1:0] AWID_S5,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output [1:0] AWBURST_S5,
	output AWVALID_S5,
	input AWREADY_S5,
	//WRITE DATA5
	output [`AXI_DATA_BITS-1:0] WDATA_S5,
	output [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output WLAST_S5,
	output WVALID_S5,
	input WREADY_S5,
	//WRITE RESPONSE5
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output BREADY_S5,
  
  //WRITE ADDRESS6
	output [`AXI_IDS_BITS-1:0] AWID_S6,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S6,
	output [`AXI_LEN_BITS-1:0] AWLEN_S6,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S6,
	output [1:0] AWBURST_S6,
	output AWVALID_S6,
	input AWREADY_S6,
	//WRITE DATA6
	output [`AXI_DATA_BITS-1:0] WDATA_S6,
	output [`AXI_STRB_BITS-1:0] WSTRB_S6,
	output WLAST_S6,
	output WVALID_S6,
	input WREADY_S6,
	//WRITE RESPONSE6
	input [`AXI_IDS_BITS-1:0] BID_S6,
	input [1:0] BRESP_S6,
	input BVALID_S6,
	output BREADY_S6,
  
	//READ ADDRESS0
	output [`AXI_IDS_BITS-1:0] ARID_S0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output [1:0] ARBURST_S0,

	output ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output RREADY_S0,
	//READ ADDRESS1
	output [`AXI_IDS_BITS-1:0] ARID_S1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output [1:0] ARBURST_S1,

	output ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output RREADY_S1,
	//READ ADDRESS2
	output [`AXI_IDS_BITS-1:0] ARID_S2,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output [1:0] ARBURST_S2,

	output ARVALID_S2,
	input ARREADY_S2,
	//READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output RREADY_S2,
	//READ ADDRESS3
	output [`AXI_IDS_BITS-1:0] ARID_S3,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output [1:0] ARBURST_S3,

	output ARVALID_S3,
	input ARREADY_S3,
	//READ DATA3
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output RREADY_S3,
	//READ ADDRESS4
	output [`AXI_IDS_BITS-1:0] ARID_S4,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output [1:0] ARBURST_S4,

	output ARVALID_S4,
	input ARREADY_S4,
	//READ DATA4
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output RREADY_S4,
  //READ ADDRESS5
	/*output [`AXI_IDS_BITS-1:0] ARID_S5,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output [1:0] ARBURST_S5,
	output ARVALID_S5,
	input ARREADY_S5,
	//READ DATA5
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output RREADY_S5,*/
  
  //READ ADDRESS6
	output [`AXI_IDS_BITS-1:0] ARID_S6,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S6,
	output [`AXI_LEN_BITS-1:0] ARLEN_S6,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S6,
	output [1:0] ARBURST_S6,
	output ARVALID_S6,
	input ARREADY_S6,
	//READ DATA6
	input [`AXI_IDS_BITS-1:0] RID_S6,
	input [`AXI_DATA_BITS-1:0] RDATA_S6,
	input [1:0] RRESP_S6,
	input RLAST_S6,
	input RVALID_S6,
	output RREADY_S6
);
/*------PARAMETER------*/
parameter ReadMasters = 3;
parameter ReadSlaves = 7;
parameter ReadSelSlaves = 3;
parameter WriteMasters = 2; //x M0
parameter WriteSlaves = 7; //x S0
parameter WriteSelSlaves = 3;
/*READ*/
wire [ReadMasters-1:0] ARgrant_M2toM0;
wire [ReadSlaves-1:0] ARVALID_DS_S6toS0_noS5;
wire [ReadSlaves-1:0] ARREADY_DS_S6toS0_noS5;
wire [ReadMasters-1:0] ARREADY_M2toM0;
wire [ReadSelSlaves-1:0] Rsel_Slave; //RSelSlave
/*WRITE*/
wire [WriteMasters-1:0] AWgrant_M3toM1;
wire [WriteSlaves-1:0] AWVALID_DS_S6toS1;
wire [WriteSlaves-1:0] AWREADY_DS_S6toS1;
wire [WriteMasters-1:0] AWREADY_M3toM1;
wire [WriteSlaves-1:0] WVALID_DS_S6toS1;
wire [WriteSlaves-1:0] WREADY_DS_S6toS1;
wire [WriteMasters-1:0] WREADY_M3toM1;
wire [WriteSelSlaves-1:0] Wsel_Slave; //WSelSlave

// READ ADDRESS
wire [`AXI_IDS_BITS-1:0] ARID;
wire [`AXI_ADDR_BITS-1:0] ARADDR;
wire [`AXI_LEN_BITS-1:0] ARLEN;
wire [`AXI_SIZE_BITS-1:0] ARSIZE;
wire [1:0] ARBURST;
//------------------
wire ARVALID;
wire ARREADY;

// READ DATA
wire [`AXI_IDS_BITS-1:0] RID;
wire [`AXI_DATA_BITS-1:0] RDATA;
wire [1:0] RRESP;
wire RLAST;
//------------------
wire RVALID;
wire RREADY;

// WRITE ADDRESS
wire [`AXI_IDS_BITS-1:0] AWID;
wire [`AXI_ADDR_BITS-1:0] AWADDR;
wire [`AXI_LEN_BITS-1:0] AWLEN;
wire [`AXI_SIZE_BITS-1:0] AWSIZE;
wire [1:0] AWBURST;
// ------------------
wire AWVALID;
wire AWREADY;

// WRITE DATA
wire [`AXI_DATA_BITS-1:0] WDATA;
wire [`AXI_STRB_BITS-1:0] WSTRB;
wire WLAST;
//-----------------
wire WVALID;
wire WREADY;
wire [`AXI_ADDR_BITS-1:0] WADDR;

// WRITE RESPONSE
wire [`AXI_IDS_BITS-1:0] BID;
wire [1:0] BRESP;
//------------------
wire BVALID;
wire BREADY;

// HandShake
wire ARHandShake = ARVALID & ARREADY;
wire RHandShake = RVALID & RREADY;
wire AWHandShake = AWVALID & AWREADY;
wire WHandShake = WVALID & WREADY;
wire BHandShake = BVALID & BREADY;

//*--------------------------*//
//---- For Default Slave -----//
//*--------------------------*//
// AR channel
wire ARVALID_DS;
wire ARREADY_DS;
wire [7:0] ARID_DS;
// R channel
wire RVALID_DS;
wire RREADY_DS;
wire [1:0] RRESP_DS;
wire RVALID_DS_Reg;
wire [1:0] RRESP_DS_Reg;
// AW channel
wire AWVALID_DS;
wire AWREADY_DS;
wire [7:0] AWID_DS;
// W channel
wire WVALID_DS;
wire WREADY_DS;
// B channel
wire BREADY_DS;
wire BVALID_DS;
wire [1:0] BRESP_DS;
wire BVALID_DS_Reg;
wire [1:0] BRESP_DS_Reg;
wire [7:0] RID_DS;
wire [7:0] RID_DS_Reg;
wire [7:0] BID_DS;
wire [7:0] BID_DS_Reg;
assign ARREADY_DS = 1'd1;
assign AWREADY_DS = 1'd1;
assign WREADY_DS = 1'd1;
/*----------------------*/
/*----- FSM state ------*/
//*---------------------*/
wire [1:0] Rstate;
wire [1:0] Wstate;
/*----------------------*/
/*----CROSS CHANNELS----*/
/*----------------------*/
DefaultSlave DefaultSlave(
  .ACLK(ACLK),
  .ARESETn(ARESETn),
  .ARID_DS(ARID_DS),
  .RID_DS(RID_DS),
  // AR channel
  .ARVALID_DS(ARVALID_DS),
  .ARREADY_DS(),
  // R channel
  .RREADY_DS(RREADY_DS),
  .RVALID_DS(RVALID_DS),
  .RRESP_DS(RRESP_DS),
  // AW channel
  .AWVALID_DS(AWVALID_DS),
  .AWREADY_DS(), 
  .AWID_DS(AWID_DS),
  // W channel
  .WVALID_DS(WVALID_DS),
  .WREADY_DS(),
  // B channel
  .BREADY_DS(BREADY_DS),
  .BVALID_DS(BVALID_DS),
  .BRESP_DS(BRESP_DS),
  .BID_DS(BID_DS)
);


/*------READ PART------*/
Read_FSM Read_FSM(
.ARESETn(ARESETn),
.ACLK(ACLK),
.ARVALID(ARVALID),
.ARHandShake(ARHandShake),
.RHandShake(RHandShake),
.RLAST(RLAST),
.state(Rstate)
);
/*------READ PART------*/
/*--READ ADDR CHANNEL--*/
/*---------------------*/
Arbiter_3M ARArbiter(
//input
.ACLK(ACLK),
.ARESETn(ARESETn),
.VALID_3M({ARVALID_M2,ARVALID_M1,ARVALID_M0}),
// Handshake
.HandShake(RHandShake),
// output
.grant_3M_out(ARgrant_M2toM0)
);

par_ARAW_MuxM2S #(.MasterCount(ReadMasters))
AR_MuxM2S(
// input
.ACLK(ACLK),
.ARESETn(ARESETn),
.state(Rstate),
.ARsel_Master(ARgrant_M2toM0),
// input : M2-M0
.ARID_MS({ARID_M2,ARID_M1,ARID_M0}),
.ARADDR_MS({ARADDR_M2,ARADDR_M1,ARADDR_M0}),
.ARLEN_MS({ARLEN_M2,ARLEN_M1,ARLEN_M0}), 
.ARSIZE_MS({ARSIZE_M2,ARSIZE_M1,ARSIZE_M0}),
.ARBURST_MS({ARBURST_M2,ARBURST_M1,ARBURST_M0}),
.ARVALID_MS({ARVALID_M2,ARVALID_M1,ARVALID_M0}),
// output
.ARID(ARID),
.ARADDR(ARADDR),
.ARLEN(ARLEN), 
.ARSIZE(ARSIZE),
.ARBURST(ARBURST),
.ARVALID(ARVALID)
);

// INTERCONNECT
// Slave : S0
assign ARID_S0 = ARID;
assign ARADDR_S0 = ARADDR;
assign ARLEN_S0 = ARLEN;
assign ARSIZE_S0 = ARSIZE;
assign ARBURST_S0 = ARBURST;
// Slave : S1
assign ARID_S1 = ARID;
assign ARADDR_S1 = ARADDR;
assign ARLEN_S1 = ARLEN;
assign ARSIZE_S1 = ARSIZE;
assign ARBURST_S1 = ARBURST;
// Slave : S2
assign ARID_S2 = ARID;
assign ARADDR_S2 = ARADDR;
assign ARLEN_S2 = ARLEN;
assign ARSIZE_S2 = ARSIZE;
assign ARBURST_S2 = ARBURST;
// Slave : S3
assign ARID_S3 = ARID;
assign ARADDR_S3 = ARADDR;
assign ARLEN_S3 = ARLEN;
assign ARSIZE_S3 = ARSIZE;
assign ARBURST_S3 = ARBURST;
// Slave : S4
assign ARID_S4 = ARID;
assign ARADDR_S4 = ARADDR;
assign ARLEN_S4 = ARLEN;
assign ARSIZE_S4 = ARSIZE;
assign ARBURST_S4 = ARBURST;
// Slave : S5
/*assign ARID_S5 = ARID;
assign ARADDR_S5 = ARADDR;
assign ARLEN_S5 = ARLEN;
assign ARSIZE_S5 = ARSIZE;
assign ARBURST_S5 = ARBURST;*/
// Slave : S6
assign ARID_S6 = ARID;
assign ARADDR_S6 = ARADDR;
assign ARLEN_S6 = ARLEN;
assign ARSIZE_S6 = ARSIZE;
assign ARBURST_S6 = ARBURST;
// Slave : DS
assign ARID_DS = ARID; // 8 bits

Decoder_M2S_projR AR_Decoder_M2S(
.VALID(ARVALID),
.ADDR(ARADDR),
.VALID_SS(ARVALID_DS_S6toS0_noS5)
); 

assign {ARVALID_DS,ARVALID_S6/*,ARVALID_S5*/,ARVALID_S4,ARVALID_S3,
ARVALID_S2,ARVALID_S1,ARVALID_S0} = ARVALID_DS_S6toS0_noS5;

assign ARREADY_DS_S6toS0_noS5={ARREADY_DS,ARREADY_S6/*,ARREADY_S5*/,ARREADY_S4,ARREADY_S3,
                   ARREADY_S2,ARREADY_S1,ARREADY_S0};

par_MuxS2M_Ready #(.SlaveCount(ReadSlaves))
AR_MuxS2M(
.VALID_SS(ARVALID_DS_S6toS0_noS5),
.READYs_in(ARREADY_DS_S6toS0_noS5),
.READY_out(ARREADY)
);

par_Decoder_S2M #(.MasterCount(ReadMasters))
AR_Decoder_S2M (
.ARsel_in(ARgrant_M2toM0),
.ARREADY_in(ARREADY),
.ARREADY_out(ARREADY_M2toM0)
);

assign {ARREADY_M2,ARREADY_M1,ARREADY_M0}=ARREADY_M2toM0;

par_SelSlave #(.SlaveCount(ReadSlaves),.SelSlaveCount(ReadSelSlaves))
RSelSlave(
//input
.ACLK(ACLK),
.ARESETn(ARESETn),
.VALID_Slave(ARVALID_DS_S6toS0_noS5),
.AddrHandShake(ARHandShake),
.RespHandShake(RHandShake),
//output
.sel_Slave(Rsel_Slave));


/*------READ PART------*/
/*-----READ CHANNEL----*/
/*---------------------*/
par_Register_1b RegRVALID_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(RVALID_DS),
            .data_out(RVALID_DS_Reg));

par_Register #(.WIDTH(2))
RegRRESP_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(RRESP_DS),
            .data_out(RRESP_DS_Reg));


par_Register #(.WIDTH(8))
RegRID_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(RID_DS),
            .data_out(RID_DS_Reg));            

par_R_MuxS2M #(.SlaveCount(ReadSlaves),.SelSlaveCount(ReadSelSlaves))
R_MuxS2M(
//  input 
.ACLK(ACLK),
.ARESETn(ARESETn),
.RREADY(RREADY),
.state(Rstate),
.Rsel_Slave(Rsel_Slave),

// input : S6-S0 x S5
.RID_SS({RID_S6/* ,RID_S5 */,RID_S4,RID_S3,RID_S2,RID_S1,RID_S0}),
.RDATA_SS({RDATA_S6/* ,RDATA_S5 */,RDATA_S4,RDATA_S3,RDATA_S2,RDATA_S1,RDATA_S0}),
.RRESP_SS({RRESP_S6/* ,RRESP_S5 */,RRESP_S4,RRESP_S3,RRESP_S2,RRESP_S1,RRESP_S0}),
.RLAST_SS({RLAST_S6/* ,RLAST_S5 */,RLAST_S4,RLAST_S3,RLAST_S2,RLAST_S1,RLAST_S0}),
.RVALID_SS({RVALID_S6/* ,RVALID_S5 */,RVALID_S4,RVALID_S3,RVALID_S2,RVALID_S1,RVALID_S0}),
// input : DS
.RID_DS(RID_DS_Reg),
.RRESP_DS(RRESP_DS_Reg),
.RVALID_DS(RVALID_DS_Reg),
//  output 
.RID(RID),
.RDATA(RDATA),
.RRESP(RRESP),
.RLAST(RLAST),
.RVALID(RVALID)
);

// Master M0
assign RID_M0 = RID[3:0];
assign RDATA_M0 = RDATA;
assign RRESP_M0 = RRESP;
assign RLAST_M0 = RLAST;
// Master M1
assign RID_M1 = RID[3:0];
assign RDATA_M1 = RDATA;
assign RRESP_M1 = RRESP;
assign RLAST_M1 = RLAST;           
// Master M2
assign RID_M2 = RID[3:0];
assign RDATA_M2 = RDATA;
assign RRESP_M2 = RRESP;
assign RLAST_M2 = RLAST;   

par_Decoder_S2M_ByID #(.MasterCount(ReadMasters))
RDecoder_S2M_ByID(
.ID(RID[7:4]),
.Din(RVALID),
.Dout({RVALID_M2,RVALID_M1,RVALID_M0})
);


par_MuxM2S_ByID #(.MasterCount(ReadMasters))
RMuxM2S_ByID(
.ID(RID[7:4]),
.READY_in({RREADY_M2,RREADY_M1,RREADY_M0}),
.READY_out(RREADY)
);

par_Decoder_ready #(.selNum(ReadSelSlaves),.OutCount(ReadSlaves))
RDecoderM2S(
.sel(Rsel_Slave),
.READY_in(RREADY),
.READY_out({RREADY_DS,RREADY_S6/* ,RREADY_S5 */,RREADY_S4,RREADY_S3,RREADY_S2,RREADY_S1,RREADY_S0})
);

/*--------WRITE PART---------*/
Write_FSM Write_FSM(
.ACLK(ACLK),
.ARESETn(ARESETn),
.AWVALID(AWVALID),
.AWHandShake(AWHandShake),
.WHandShake(WHandShake),
.WLAST(WLAST),
.BHandShake(BHandShake),
.state(Wstate)
);
/*--------WRITE PART---------*/
/*-----WRITE ADDR CHANNEL----*/
/*---------------------------*/
Arbiter_2M AWArbiter(
//input
.ACLK(ACLK),
.ARESETn(ARESETn),
// Handshake
.HandShake(BHandShake),
.VALID_2M({AWVALID_M2,AWVALID_M1}),
// output
.grant_2M_out(AWgrant_M3toM1)
);
 
// Test par_AR_MuxM2S = par_AW_MuxM2S
par_ARAW_MuxM2S #(.MasterCount(WriteMasters))
AW_MuxM2S(
// input
.ACLK(ACLK),
.ARESETn(ARESETn),
.state(Wstate),
.ARsel_Master(AWgrant_M3toM1),
// input : M3-M1
.ARID_MS({AWID_M2,AWID_M1}),
.ARADDR_MS({AWADDR_M2,AWADDR_M1}),
.ARLEN_MS({AWLEN_M2,AWLEN_M1}), 
.ARSIZE_MS({AWSIZE_M2,AWSIZE_M1}),
.ARBURST_MS({AWBURST_M2,AWBURST_M1}),
.ARVALID_MS({AWVALID_M2,AWVALID_M1}),
// output
.ARID(AWID),
.ARADDR(AWADDR),
.ARLEN(AWLEN), 
.ARSIZE(AWSIZE),
.ARBURST(AWBURST),
.ARVALID(AWVALID)
);

// INTERCONNECT
// Slave : S1
assign AWID_S1=AWID;
assign AWADDR_S1=AWADDR;
assign AWLEN_S1=AWLEN;
assign AWSIZE_S1=AWSIZE;
assign AWBURST_S1=AWBURST;
// Slave : S2
assign AWID_S2=AWID;
assign AWADDR_S2=AWADDR;
assign AWLEN_S2=AWLEN;
assign AWSIZE_S2=AWSIZE;
assign AWBURST_S2=AWBURST;
// Slave : S3
assign AWID_S3=AWID;
assign AWADDR_S3=AWADDR;
assign AWLEN_S3=AWLEN;
assign AWSIZE_S3=AWSIZE;
assign AWBURST_S3=AWBURST;
// Slave : S4
assign AWID_S4=AWID;
assign AWADDR_S4=AWADDR;
assign AWLEN_S4=AWLEN;
assign AWSIZE_S4=AWSIZE;
assign AWBURST_S4=AWBURST;
// Slave : S5
assign AWID_S5 = AWID;
assign AWADDR_S5 = AWADDR;
assign AWLEN_S5 = AWLEN;
assign AWSIZE_S5 = AWSIZE;
assign AWBURST_S5 = AWBURST;
// Slave : S6
assign AWID_S6 = AWID;
assign AWADDR_S6 = AWADDR;
assign AWLEN_S6 = AWLEN;
assign AWSIZE_S6 = AWSIZE;
assign AWBURST_S6 = AWBURST;
// Slave : DS
assign AWID_DS=AWID;


Decoder_M2S_projW AW_Decoder_M2S(
.VALID(AWVALID),
.ADDR(AWADDR),
.VALID_SS(AWVALID_DS_S6toS1)
); 

assign {AWVALID_DS,AWVALID_S6,AWVALID_S5,AWVALID_S4,AWVALID_S3,AWVALID_S2,AWVALID_S1}=AWVALID_DS_S6toS1;

assign AWREADY_DS_S6toS1={AWREADY_DS,AWREADY_S6,AWREADY_S5,AWREADY_S4,AWREADY_S3,
                   AWREADY_S2,AWREADY_S1};

par_MuxS2M_Ready #(.SlaveCount(WriteSlaves))
AW_MuxS2M(
.VALID_SS(AWVALID_DS_S6toS1),
.READYs_in(AWREADY_DS_S6toS1),
.READY_out(AWREADY)
);

par_Decoder_S2M #(.MasterCount(WriteMasters))
AW_Decoder_S2M (
.ARsel_in(AWgrant_M3toM1),
.ARREADY_in(AWREADY),
.ARREADY_out(AWREADY_M3toM1)
);

assign {AWREADY_M2,AWREADY_M1}=AWREADY_M3toM1;

AWADDR_Reg AWADDR_Reg(
.ACLK(ACLK),
.ARESETn(ARESETn),
.AWADDR(AWADDR),
.AWHandShake(AWHandShake),
.BHandShake(BHandShake),
 
.WADDR(WADDR)
);

par_SelSlave #(.SlaveCount(WriteSlaves),.SelSlaveCount(WriteSelSlaves))
WSelSlave(
//input
.ACLK(ACLK),
.ARESETn(ARESETn),
.VALID_Slave(AWVALID_DS_S6toS1),
.AddrHandShake(AWHandShake),
.RespHandShake(BHandShake),
//output
.sel_Slave(Wsel_Slave));

/*--------WRITE PART---------*/
/*-----WRITE DATA CHANNEL----*/
/*---------------------------*/
par_W_MuxM2S #(.MasterCount(WriteMasters))
W_MuxM2S(
.ACLK(ACLK),
.ARESETn(ARESETn),
.state(Wstate),
.sel_Master(AWgrant_M3toM1),
// input : M1
.WDATA_MS({WDATA_M2,WDATA_M1}),
.WSTRB_MS({WSTRB_M2,WSTRB_M1}),
.WLAST_MS({WLAST_M2,WLAST_M1}),
.WVALID_MS({WVALID_M2,WVALID_M1}),
// output
.WDATA(WDATA),
.WSTRB(WSTRB),
.WLAST(WLAST),
.WVALID(WVALID)
);

// INTERCONNECT
// Slave : S1
assign WDATA_S1=WDATA;
assign WSTRB_S1=WSTRB;
assign WLAST_S1=WLAST;
// Slave : S2
assign WDATA_S2=WDATA;
assign WSTRB_S2=WSTRB;
assign WLAST_S2=WLAST;
// Slave : S3
assign WDATA_S3=WDATA;
assign WSTRB_S3=WSTRB;
assign WLAST_S3=WLAST;
// Slave : S4
assign WDATA_S4=WDATA;
assign WSTRB_S4=WSTRB;
assign WLAST_S4=WLAST;
// Slave : S5
assign WDATA_S5=WDATA;
assign WSTRB_S5=WSTRB;
assign WLAST_S5=WLAST;
// Slave : S6
assign WDATA_S6=WDATA;
assign WSTRB_S6=WSTRB;
assign WLAST_S6=WLAST;

Decoder_M2S_projW W_Decoder_M2S(
.VALID(WVALID),
.ADDR(WADDR),
.VALID_SS(WVALID_DS_S6toS1)
); 

// 4 bits
assign {WVALID_DS,WVALID_S6,WVALID_S5,WVALID_S4,WVALID_S3,WVALID_S2,WVALID_S1}=WVALID_DS_S6toS1;

assign WREADY_DS_S6toS1={WREADY_DS,WREADY_S6,WREADY_S5,WREADY_S4,
        WREADY_S3,WREADY_S2,WREADY_S1};

par_MuxS2M_Ready #(.SlaveCount(WriteSlaves))
W_MuxS2M(
.VALID_SS(WVALID_DS_S6toS1),
.READYs_in(WREADY_DS_S6toS1),
.READY_out(WREADY)
);

par_Decoder_S2M #(.MasterCount(WriteMasters))
W_Decoder_S2M (
.ARsel_in(AWgrant_M3toM1),
.ARREADY_in(WREADY),
.ARREADY_out(WREADY_M3toM1)
);

assign {WREADY_M2,WREADY_M1}=WREADY_M3toM1;

// REPLACE : WDecoder_S2M
// assign WREADY_M1 = WREADY;

/*--------WRITE PART---------*/
/*-----WRITE RESP CHANNEL----*/
/*---------------------------*/
par_Register_1b RegBVALID_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(BVALID_DS),
            .data_out(BVALID_DS_Reg));

par_Register #(.WIDTH(2))
RegBRESP_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(BRESP_DS),
            .data_out(BRESP_DS_Reg));

par_Register #(.WIDTH(8))
RegBID_DS (.ACLK(ACLK),
            .ARESETn(ARESETn),
            .data_in(BID_DS),
            .data_out(BID_DS_Reg));

par_B_MuxS2M #(.SlaveCount(WriteSlaves),.SelSlaveCount(WriteSelSlaves))
B_MuxS2M(
.ACLK(ACLK),
.ARESETn(ARESETn),
.AWVALID(AWVALID),
.state(Wstate),
.Bsel_Slave(Wsel_Slave),
// input : S5-S1
.BVALID_SS({BVALID_S6,BVALID_S5,BVALID_S4,BVALID_S3,BVALID_S2,BVALID_S1}),
.BID_SS({BID_S6,BID_S5,BID_S4,BID_S3,BID_S2,BID_S1}),
.BRESP_SS({BRESP_S6,BRESP_S5,BRESP_S4,BRESP_S3,BRESP_S2,BRESP_S1}),
// input : DS
.BVALID_DS(BVALID_DS_Reg),
.BID_DS(BID_DS_Reg),
.BRESP_DS(BRESP_DS_Reg),
// output
.BVALID(BVALID),
.BID(BID),
.BRESP(BRESP));

// INTERCONNECT -----------------
// Master : M1
assign BID_M1=BID[3:0];
assign BRESP_M1=BRESP;
// Master : M2
assign BID_M2=BID[3:0];
assign BRESP_M2=BRESP;


par_Decoder_S2M_ByID #(.MasterCount(WriteMasters))
BDecoder_S2M_ByID(
.ID(BID[7:4]),
.Din(BVALID),
.Dout({BVALID_M2,BVALID_M1})
);
// REPLACE: W_Decoder_S2M_ByID
// assign BVALID_M1=BVALID;

par_MuxM2S_ByID #(.MasterCount(WriteMasters))
BMuxM2S_ByID(
.ID(BID[7:4]),
.READY_in({BREADY_M2,BREADY_M1}),
.READY_out(BREADY)
);
//REPLACE: W_MuxM2S_ByID
// assign BREADY=BREADY_M1;

par_Decoder_ready #(.selNum(WriteSelSlaves),.OutCount(WriteSlaves))
BDecoderS2M(
.sel(Wsel_Slave),
.READY_in(BREADY),
.READY_out({BREADY_DS,BREADY_S6,BREADY_S5,BREADY_S4,BREADY_S3,BREADY_S2,BREADY_S1})
);
endmodule
