//================================================
// Filename:    top.sv                            
// Version:     1.0 
// Description: Connect AXI and all wrappers
// 3 MASTER
// Master0 3'd0 //CPU IM
// Master1 3'd1 //CPU DM
// Master2 3'd2 //DMA
// DefaultMaster 3'd3
// 8 SLAVE
// Slave0 3'd0 //ROM
// Slave1 3'd1 //CPU IM
// Slave2 3'd2 //CPU DM
// Slave3 3'd3 //sensor
// Slave4 3'd4 //DRAM
// Slave5 3'd5 //DMA xREAD
// Slave6 3'd6 //CNN
// DefaultSlave 3'd7
//================================================
`timescale 1ns/10ps
`include "../../include/AXI_define.svh"

`include "AXI/AXI.sv"
`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "ROM_wrapper.sv"
`include "SCtrl_wrapper.sv"
`include "DMA_wrapper.sv"
`include "CNN_wrapper_layer1.sv"

module top_layer1(rst,clk,DRAM_D,DRAM_A,DRAM_CASn,DRAM_RASn,DRAM_WEn,DRAM_CSn,ROM_address,ROM_read,ROM_enable,sensor_en,sensor_ready,sensor_out,ROM_out,DRAM_Q,DRAM_valid);
    // user defined AXI parameters
    localparam DATA_WIDTH              = 32;
    localparam ADDR_WIDTH              = 32;
    localparam ID_WIDTH                = 4;
    localparam IDS_WIDTH               = 8;
    localparam LEN_WIDTH               = 4;
    localparam MAXLEN                  = 1;
    // fixed AXI parameters
    localparam STRB_WIDTH              = DATA_WIDTH/8;
    localparam SIZE_WIDTH              = 3;
    localparam BURST_WIDTH             = 2;  
    localparam BRESP_WIDTH             = 2; 
    localparam RRESP_WIDTH             = 2;      
    
    // Clock and reset  
    input rst;
    input clk;
    
    input[31:0] sensor_out;
    input sensor_ready;
    output sensor_en;
      //HW4
	input [31:0] ROM_out;
	output ROM_enable;
	output ROM_read;
	output [31:0] ROM_address;

	input [31:0] DRAM_Q;
	output DRAM_CSn;
	output [3:0]DRAM_WEn;
	output DRAM_RASn;
	output DRAM_CASn;
	output [10:0] DRAM_A;
	output [31:0] DRAM_D;
	input DRAM_valid;

	wire DMA_interrupt;
    wire sensor_interrupt;
	wire cnn_interrupt;
    // ----------slave 0---------- //
    // Write address channel signals
    /*wire    [IDS_WIDTH-1:0]     awid_s0;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s0;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s0;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s0;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s0;   // Write address burst type

    wire                        awvalid_s0;   // Write address valid
    wire                        awready_s0;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s0;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s0;     // Write strobe
    wire                        wlast_s0;     // Write last
    wire                        wvalid_s0;    // Write valid
    wire                        wready_s0;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s0;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s0;     // Write response
    wire                        bvalid_s0;    // Write response valid
    wire                        bready_s0;    // Write response ready
    */
    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s0;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s0;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s0;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s0;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s0;   // Read address burst type

    wire                        arvalid_s0;   // Read address valid
    wire                        arready_s0;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s0;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s0;     // Read data
    wire                        rlast_s0;     // Read last
    wire                        rvalid_s0;    // Read valid
    wire                        rready_s0;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s0;     // Read response
    
    // ----------slave1---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s1;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s1;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s1;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s1;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s1;   // Write address burst type

    wire                        awvalid_s1;   // Write address valid
    wire                        awready_s1;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s1;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s1;     // Write strobe
    wire                        wlast_s1;     // Write last
    wire                        wvalid_s1;    // Write valid
    wire                        wready_s1;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s1;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s1;     // Write response
    wire                        bvalid_s1;    // Write response valid
    wire                        bready_s1;    // Write response ready

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s1;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s1;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s1;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s1;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s1;   // Read address burst type

    wire                        arvalid_s1;   // Read address valid
    wire                        arready_s1;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s1;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s1;     // Read data
    wire                        rlast_s1;     // Read last
    wire                        rvalid_s1;    // Read valid
    wire                        rready_s1;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s1;     // Read response

    // ----------slave2---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s2;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s2;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s2;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s2;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s2;   // Write address burst type

    wire                        awvalid_s2;   // Write address valid
    wire                        awready_s2;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s2;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s2;     // Write strobe
    wire                        wlast_s2;     // Write last
    wire                        wvalid_s2;    // Write valid
    wire                        wready_s2;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s2;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s2;     // Write response
    wire                        bvalid_s2;    // Write response valid
    wire                        bready_s2;    // Write response ready

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s2;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s2;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s2;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s2;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s2;   // Read address burst type

    wire                        arvalid_s2;   // Read address valid
    wire                        arready_s2;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s2;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s2;     // Read data
    wire                        rlast_s2;     // Read last
    wire                        rvalid_s2;    // Read valid
    wire                        rready_s2;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s2;     // Read response

    // ----------slave3---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s3;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s3;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s3;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s3;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s3;   // Write address burst type

    wire                        awvalid_s3;   // Write address valid
    wire                        awready_s3;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s3;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s3;     // Write strobe
    wire                        wlast_s3;     // Write last
    wire                        wvalid_s3;    // Write valid
    wire                        wready_s3;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s3;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s3;     // Write response
    wire                        bvalid_s3;    // Write response valid
    wire                        bready_s3;    // Write response ready

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s3;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s3;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s3;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s3;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s3;   // Read address burst type

    wire                        arvalid_s3;   // Read address valid
    wire                        arready_s3;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s3;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s3;     // Read data
    wire                        rlast_s3;     // Read last
    wire                        rvalid_s3;    // Read valid
    wire                        rready_s3;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s3;     // Read response

    // ----------slave4---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s4;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s4;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s4;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s4;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s4;   // Write address burst type

    wire                        awvalid_s4;   // Write address valid
    wire                        awready_s4;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s4;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s4;     // Write strobe
    wire                        wlast_s4;     // Write last
    wire                        wvalid_s4;    // Write valid
    wire                        wready_s4;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s4;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s4;     // Write response
    wire                        bvalid_s4;    // Write response valid
    wire                        bready_s4;    // Write response ready

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s4;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s4;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s4;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s4;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s4;   // Read address burst type

    wire                        arvalid_s4;   // Read address valid
    wire                        arready_s4;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s4;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s4;     // Read data
    wire                        rlast_s4;     // Read last
    wire                        rvalid_s4;    // Read valid
    wire                        rready_s4;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s4;     // Read response

		// ----------slave5---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s5;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s5;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s5;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s5;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s5;   // Write address burst type

    wire                        awvalid_s5;   // Write address valid
    wire                        awready_s5;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s5;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s5;     // Write strobe
    wire                        wlast_s5;     // Write last
    wire                        wvalid_s5;    // Write valid
    wire                        wready_s5;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s5;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s5;     // Write response
    wire                        bvalid_s5;    // Write response valid
    wire                        bready_s5;    // Write response ready
	
	// ----------slave6---------- //
    // Write address channel signals
    wire    [IDS_WIDTH-1:0]     awid_s6;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_s6;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_s6;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_s6;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_s6;   // Write address burst type

    wire                        awvalid_s6;   // Write address valid
    wire                        awready_s6;   // Write address ready

    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_s6;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_s6;     // Write strobe
    wire                        wlast_s6;     // Write last
    wire                        wvalid_s6;    // Write valid
    wire                        wready_s6;    // Write ready

    // Write response channel signals
    wire    [IDS_WIDTH-1:0]     bid_s6;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_s6;     // Write response
    wire                        bvalid_s6;    // Write response valid
    wire                        bready_s6;    // Write response ready

    // Read address channel signals
    wire    [IDS_WIDTH-1:0]     arid_s6;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_s6;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_s6;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_s6;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_s6;   // Read address burst type

    wire                        arvalid_s6;   // Read address valid
    wire                        arready_s6;   // Read address ready

    // Read data channel signals
    wire    [IDS_WIDTH-1:0]     rid_s6;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_s6;     // Read data
    wire                        rlast_s6;     // Read last
    wire                        rvalid_s6;    // Read valid
    wire                        rready_s6;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_s6;     // Read response

    // ----------master0---------- //
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid_m0;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_m0;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_m0;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_m0;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_m0;   // Read address burst type
    wire                        arvalid_m0;   // Read address valid
    wire                        arready_m0;   // Read address ready

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid_m0;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_m0;     // Read data
    wire                        rlast_m0;     // Read last
    wire                        rvalid_m0;    // Read valid
    wire                        rready_m0;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_m0;     // Read response

    // ----------master1---------- //
    // Write address channel signals
    wire    [ID_WIDTH-1:0]      awid_m1;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_m1;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_m1;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_m1;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_m1;   // Write address burst type
    wire                        awvalid_m1;   // Write address valid
    wire                        awready_m1;   // Write address ready
    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_m1;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_m1;     // Write strobe
    wire                        wlast_m1;     // Write last
    wire                        wvalid_m1;    // Write valid
    wire                        wready_m1;    // Write ready
    // Write response channel signals
    wire    [ID_WIDTH-1:0]      bid_m1;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_m1;     // Write response
    wire                        bvalid_m1;    // Write response valid
    wire                        bready_m1;    // Write response ready
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid_m1;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_m1;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_m1;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_m1;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_m1;   // Read address burst type
    wire                        arvalid_m1;   // Read address valid
    wire                        arready_m1;   // Read address ready

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid_m1;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_m1;     // Read data
    wire                        rlast_m1;     // Read last
    wire                        rvalid_m1;    // Read valid
    wire                        rready_m1;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_m1;     // Read response


	// ----------master2---------- // DMA
	//wire load;
	
    // Write address channel signals
    wire    [ID_WIDTH-1:0]      awid_m2;      // Write address ID tag
    wire    [ADDR_WIDTH-1:0]    awaddr_m2;    // Write address
    wire    [LEN_WIDTH-1:0]     awlen_m2;     // Write address burst length
    wire    [SIZE_WIDTH-1:0]    awsize_m2;    // Write address burst size
    wire    [BURST_WIDTH-1:0]   awburst_m2;   // Write address burst type
    wire                        awvalid_m2;   // Write address valid
    wire                        awready_m2;   // Write address ready
    // Write data channel signals
    wire    [DATA_WIDTH-1:0]    wdata_m2;     // Write data
    wire    [DATA_WIDTH/8-1:0]  wstrb_m2;     // Write strobe
    wire                        wlast_m2;     // Write last
    wire                        wvalid_m2;    // Write valid
    wire                        wready_m2;    // Write ready
    // Write response channel signals
    wire    [ID_WIDTH-1:0]      bid_m2;       // Write response ID tag
    wire    [BRESP_WIDTH-1:0]   bresp_m2;     // Write response
    wire                        bvalid_m2;    // Write response valid
    wire                        bready_m2;    // Write response ready
    // Read address channel signals
    wire    [ID_WIDTH-1:0]      arid_m2;      // Read address ID tag
    wire    [ADDR_WIDTH-1:0]    araddr_m2;    // Read address
    wire    [LEN_WIDTH-1:0]     arlen_m2;     // Read address burst length
    wire    [SIZE_WIDTH-1:0]    arsize_m2;    // Read address burst size
    wire    [BURST_WIDTH-1:0]   arburst_m2;   // Read address burst type
    wire                        arvalid_m2;   // Read address valid
    wire                        arready_m2;   // Read address ready

    // Read data channel signals
    wire    [ID_WIDTH-1:0]      rid_m2;       // Read ID tag
    wire    [DATA_WIDTH-1:0]    rdata_m2;     // Read data
    wire                        rlast_m2;     // Read last
    wire                        rvalid_m2;    // Read valid
    wire                        rready_m2;    // Read ready
    wire    [RRESP_WIDTH-1:0]   rresp_m2;     // Read response

	
  // Slave S0
  ROM_wrapper ROM_wrapper(
	.clk(clk),
	.resetn(rst),
  /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s0),
	.ARADDR(araddr_s0),
	.ARLEN(arlen_s0),
	.ARSIZE(arsize_s0),
	.ARBURST(arburst_s0),
	.ARVALID(arvalid_s0),
	.ARREADY(arready_s0),
	//READ DATA1
	.RID(rid_s0),
	.RDATA(rdata_s0),
	.RRESP(rresp_s0),
	.RLAST(rlast_s0),
	.RVALID(rvalid_s0),
  .DO(ROM_out),
  .CS(ROM_enable),
  .OE(ROM_read),
  .A(ROM_address[11:0]),
	.RREADY(rready_s0));
  
  // Slave S4
  DRAM_wrapper DRAM_wrapper(
  .clk(clk),
  .resetn(rst),
    /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	.AWID(awid_s4),
	.AWADDR(awaddr_s4),
	.AWLEN(awlen_s4), 
	.AWSIZE(awsize_s4), 
	.AWBURST(awburst_s4),
	.AWVALID(awvalid_s4),
	.AWREADY(awready_s4),
	//WRITE DATA1
	.WDATA(wdata_s4),
	.WSTRB(wstrb_s4),
	.WLAST(wlast_s4),
	.WVALID(wvalid_s4),
	.WREADY(wready_s4),
	//WRITE RESPONSE1
	.BID(bid_s4),
	.BRESP(bresp_s4),
	.BVALID(bvalid_s4),
	.BREADY(bready_s4),
  /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s4),
	.ARADDR(araddr_s4),
	.ARLEN(arlen_s4), 
	.ARSIZE(arsize_s4), 
	.ARBURST(arburst_s4),
	.ARVALID(arvalid_s4),
	.ARREADY(arready_s4),
	//READ DATA1
	.RID(rid_s4),
	.RDATA(rdata_s4),
	.RRESP(rresp_s4),
	.RLAST(rlast_s4),
	.RVALID(rvalid_s4),
	.RREADY(rready_s4),
	.Q(DRAM_Q),
  .CSn(DRAM_CSn),
  .WEn(DRAM_WEn),
  .RASn(DRAM_RASn),
  .CASn(DRAM_CASn),
 .A(DRAM_A),
  .D(DRAM_D),
  .VALID(DRAM_valid)
  );
  
  // Master M0 & M1
    CPU_wrapper CPU_wrapper(
    .ACLK      (clk),
    .ARESETn   (!rst),
	.interrupt_dma(DMA_interrupt),
	.interrupt_cnn(cnn_interrupt),
	.interrupt_sensor(sensor_interrupt),
    //WRITE ADDRESS
    .AWID_M1   (awid_m1),
    .AWADDR_M1 (awaddr_m1),
    .AWLEN_M1  (awlen_m1),
    .AWSIZE_M1 (awsize_m1),
    .AWBURST_M1(awburst_m1),
    .AWVALID_M1(awvalid_m1),
    .AWREADY_M1(awready_m1),
    //WRITE DATA
    .WDATA_M1  (wdata_m1),
    .WSTRB_M1  (wstrb_m1),
    .WLAST_M1  (wlast_m1),
    .WVALID_M1 (wvalid_m1),
    .WREADY_M1 (wready_m1),
    //WRITE RESPONSE
    .BID_M1    (bid_m1),
    .BRESP_M1  (bresp_m1),
    .BVALID_M1 (bvalid_m1),
    .BREADY_M1 (bready_m1),
    //READ ADDRESS0
    .ARID_M0   (arid_m0),
    .ARADDR_M0 (araddr_m0),
    .ARLEN_M0  (arlen_m0),
    .ARSIZE_M0 (arsize_m0),
    .ARBURST_M0(arburst_m0),
    .ARVALID_M0(arvalid_m0),
    .ARREADY_M0(arready_m0),
    //READ DATA0
    .RID_M0    (rid_m0),
    .RDATA_M0  (rdata_m0),
    .RRESP_M0  (rresp_m0),
    .RLAST_M0  (rlast_m0),
    .RVALID_M0 (rvalid_m0),
    .RREADY_M0 (rready_m0),
    //READ ADDRESS1
    .ARID_M1   (arid_m1),
    .ARADDR_M1 (araddr_m1),
    .ARLEN_M1  (arlen_m1),
    .ARSIZE_M1 (arsize_m1),
    .ARBURST_M1(arburst_m1),
    .ARVALID_M1(arvalid_m1),
    .ARREADY_M1(arready_m1),
    //READ DATA01
    .RID_M1    (rid_m1),
    .RDATA_M1  (rdata_m1),
    .RRESP_M1  (rresp_m1),
    .RLAST_M1  (rlast_m1),
    .RVALID_M1 (rvalid_m1),
    .RREADY_M1 (rready_m1));
    
	AXI AXI(
	 .ACLK       (clk      ),
	 .ARESETn    (!rst   ),
   // m1
	 .AWID_M1    (awid_m1   ),
	 .AWADDR_M1  (awaddr_m1 ),
	 .AWLEN_M1   (awlen_m1  ),
	 .AWSIZE_M1  (awsize_m1 ),
	 .AWBURST_M1 (awburst_m1),
	 .AWVALID_M1 (awvalid_m1),
	 .AWREADY_M1 (awready_m1),
	 .WDATA_M1   (wdata_m1  ),
	 .WSTRB_M1   (wstrb_m1  ),
	 .WLAST_M1   (wlast_m1  ),
	 .WVALID_M1  (wvalid_m1 ),
	 .WREADY_M1  (wready_m1 ),
	 .BID_M1     (bid_m1    ),
	 .BRESP_M1   (bresp_m1  ),
	 .BVALID_M1  (bvalid_m1 ),
	 .BREADY_M1  (bready_m1 ),
   //m2
   .AWID_M2    (awid_m2   ),
	 .AWADDR_M2  (awaddr_m2 ),
	 .AWLEN_M2   (awlen_m2  ),
	 .AWSIZE_M2  (awsize_m2 ),
	 .AWBURST_M2 (awburst_m2),
	 .AWVALID_M2 (awvalid_m2),
	 .AWREADY_M2 (awready_m2),
	 .WDATA_M2   (wdata_m2  ),
	 .WSTRB_M2   (wstrb_m2  ),
	 .WLAST_M2   (wlast_m2  ),
	 .WVALID_M2  (wvalid_m2 ),
	 .WREADY_M2  (wready_m2 ),
	 .BID_M2     (bid_m2    ),
	 .BRESP_M2   (bresp_m2  ),
	 .BVALID_M2  (bvalid_m2 ),
	 .BREADY_M2  (bready_m2 ),
   //m0
	 .ARID_M0    (arid_m0   ),
	 .ARADDR_M0  (araddr_m0 ),
	 .ARLEN_M0   (arlen_m0  ),
	 .ARSIZE_M0  (arsize_m0 ),
	 .ARBURST_M0 (arburst_m0),
	 .ARVALID_M0 (arvalid_m0),
	 .ARREADY_M0 (arready_m0),
	 .RID_M0     (rid_m0    ),
	 .RDATA_M0   (rdata_m0  ),
	 .RRESP_M0   (rresp_m0  ),
	 .RLAST_M0   (rlast_m0  ),
	 .RVALID_M0  (rvalid_m0 ),
	 .RREADY_M0  (rready_m0 ),
   //m1
	 .ARID_M1    (arid_m1   ),
	 .ARADDR_M1  (araddr_m1 ),
	 .ARLEN_M1   (arlen_m1  ),
	 .ARSIZE_M1  (arsize_m1 ),
	 .ARBURST_M1 (arburst_m1),
	 .ARVALID_M1 (arvalid_m1),
	 .ARREADY_M1 (arready_m1),
	 .RID_M1     (rid_m1    ),
	 .RDATA_M1   (rdata_m1  ),
	 .RRESP_M1   (rresp_m1  ),
	 .RLAST_M1   (rlast_m1  ),
	 .RVALID_M1  (rvalid_m1 ),
	 .RREADY_M1  (rready_m1 ),
   //m2
	 .ARID_M2    (arid_m2   ),
	 .ARADDR_M2  (araddr_m2 ),
	 .ARLEN_M2   (arlen_m2  ),
	 .ARSIZE_M2  (arsize_m2 ),
	 .ARBURST_M2 (arburst_m2),
	 .ARVALID_M2 (arvalid_m2),
	 .ARREADY_M2 (arready_m2),
	 .RID_M2     (rid_m2    ),
	 .RDATA_M2   (rdata_m2  ),
	 .RRESP_M2   (rresp_m2  ),
	 .RLAST_M2   (rlast_m2  ),
	 .RVALID_M2  (rvalid_m2 ),
	 .RREADY_M2  (rready_m2 ),
	 /*.AWID_S0    (awid_s0   ),
	 .AWADDR_S0  (awaddr_s0 ),
	 .AWLEN_S0   (awlen_s0  ),
	 .AWSIZE_S0  (awsize_s0 ),
	 .AWBURST_S0 (awburst_s0),
	 .AWVALID_S0 (awvalid_s0),
	 .AWREADY_S0 (awready_s0),*/
   //s1
	 .AWID_S1    (awid_s1   ),
	 .AWADDR_S1  (awaddr_s1 ),
	 .AWLEN_S1   (awlen_s1  ),
	 .AWSIZE_S1  (awsize_s1 ),
	 .AWBURST_S1 (awburst_s1),
	 .AWVALID_S1 (awvalid_s1),
	 .AWREADY_S1 (awready_s1),
	 .WDATA_S1   (wdata_s1  ),
	 .WSTRB_S1   (wstrb_s1  ),
	 .WLAST_S1   (wlast_s1  ),
	 .WVALID_S1  (wvalid_s1 ),
	 .WREADY_S1  (wready_s1 ),
	 .BID_S1     (bid_s1    ),
	 .BRESP_S1   (bresp_s1  ),
	 .BVALID_S1  (bvalid_s1 ),
	 .BREADY_S1  (bready_s1 ),
   //s2
	 .AWID_S2    (awid_s2   ),
	 .AWADDR_S2  (awaddr_s2 ),
	 .AWLEN_S2   (awlen_s2  ),
	 .AWSIZE_S2  (awsize_s2 ),
	 .AWBURST_S2 (awburst_s2),
	 .AWVALID_S2 (awvalid_s2),
	 .AWREADY_S2 (awready_s2),
	 .WDATA_S2   (wdata_s2  ),
	 .WSTRB_S2   (wstrb_s2  ),
	 .WLAST_S2   (wlast_s2  ),
	 .WVALID_S2  (wvalid_s2 ),
	 .WREADY_S2  (wready_s2 ),
	 .BID_S2     (bid_s2    ),
	 .BRESP_S2   (bresp_s2  ),
	 .BVALID_S2  (bvalid_s2 ),
	 .BREADY_S2  (bready_s2 ),
   //s3
	 .AWID_S3    (awid_s3   ),
	 .AWADDR_S3  (awaddr_s3 ),
	 .AWLEN_S3   (awlen_s3  ),
	 .AWSIZE_S3  (awsize_s3 ),
	 .AWBURST_S3 (awburst_s3),
	 .AWVALID_S3 (awvalid_s3),
	 .AWREADY_S3 (awready_s3),
	 .WDATA_S3   (wdata_s3  ),
	 .WSTRB_S3   (wstrb_s3  ),
	 .WLAST_S3   (wlast_s3  ),
	 .WVALID_S3  (wvalid_s3 ),
	 .WREADY_S3  (wready_s3 ),
	 .BID_S3     (bid_s3    ),
	 .BRESP_S3   (bresp_s3  ),
	 .BVALID_S3  (bvalid_s3 ),
	 .BREADY_S3  (bready_s3 ),
   //s4
	 .AWID_S4    (awid_s4   ),
	 .AWADDR_S4  (awaddr_s4 ),
	 .AWLEN_S4   (awlen_s4  ),
	 .AWSIZE_S4  (awsize_s4 ),
	 .AWBURST_S4 (awburst_s4),
	 .AWVALID_S4 (awvalid_s4),
	 .AWREADY_S4 (awready_s4),
	 .WDATA_S4   (wdata_s4  ),
	 .WSTRB_S4   (wstrb_s4  ),
	 .WLAST_S4   (wlast_s4  ),
	 .WVALID_S4  (wvalid_s4 ),
	 .WREADY_S4  (wready_s4 ),
	 .BID_S4     (bid_s4    ),
	 .BRESP_S4   (bresp_s4  ),
	 .BVALID_S4  (bvalid_s4 ),
	 .BREADY_S4  (bready_s4 ),
   //s5
	 .AWID_S5    (awid_s5   ),
	 .AWADDR_S5  (awaddr_s5 ),
	 .AWLEN_S5   (awlen_s5  ),
	 .AWSIZE_S5  (awsize_s5 ),
	 .AWBURST_S5 (awburst_s5),
	 .AWVALID_S5 (awvalid_s5),
	 .AWREADY_S5 (awready_s5),
	 .WDATA_S5   (wdata_s5  ),
	 .WSTRB_S5   (wstrb_s5  ),
	 .WLAST_S5   (wlast_s5  ),
	 .WVALID_S5  (wvalid_s5 ),
	 .WREADY_S5  (wready_s5 ),
	 .BID_S5     (bid_s5    ),
	 .BRESP_S5   (bresp_s5  ),
	 .BVALID_S5  (bvalid_s5 ),
	 .BREADY_S5  (bready_s5 ),
    //s6
	  .AWID_S6    (awid_s6   ),
	 .AWADDR_S6  (awaddr_s6 ),
	 .AWLEN_S6   (awlen_s6  ),
	 .AWSIZE_S6  (awsize_s6 ),
	 .AWBURST_S6 (awburst_s6),
	 .AWVALID_S6 (awvalid_s6),
	 .AWREADY_S6 (awready_s6),
	 .WDATA_S6   (wdata_s6  ),
	 .WSTRB_S6   (wstrb_s6  ),
	 .WLAST_S6   (wlast_s6  ),
	 .WVALID_S6  (wvalid_s6 ),
	 .WREADY_S6  (wready_s6 ),
	 .BID_S6     (bid_s6    ),
	 .BRESP_S6   (bresp_s6  ),
	 .BVALID_S6  (bvalid_s6 ),
	 .BREADY_S6  (bready_s6 ),
	 
   //s0
	 .ARID_S0    (arid_s0   ),
	 .ARADDR_S0  (araddr_s0 ),
	 .ARLEN_S0   (arlen_s0  ),
	 .ARSIZE_S0  (arsize_s0 ),
	 .ARBURST_S0 (arburst_s0),
	 .ARVALID_S0 (arvalid_s0),
	 .ARREADY_S0 (arready_s0),
	 .RID_S0     (rid_s0    ),
	 .RDATA_S0   (rdata_s0  ),
	 .RRESP_S0   (rresp_s0  ),
	 .RLAST_S0   (rlast_s0  ),
	 .RVALID_S0  (rvalid_s0 ),
	 .RREADY_S0  (rready_s0 ),
   //s1
	 .ARID_S1    (arid_s1   ),
	 .ARADDR_S1  (araddr_s1 ),
	 .ARLEN_S1   (arlen_s1  ),
	 .ARSIZE_S1  (arsize_s1 ),
	 .ARBURST_S1 (arburst_s1),
	 .ARVALID_S1 (arvalid_s1),
	 .ARREADY_S1 (arready_s1),
	 .RID_S1     (rid_s1    ),
	 .RDATA_S1   (rdata_s1  ),
	 .RRESP_S1   (rresp_s1  ),
	 .RLAST_S1   (rlast_s1  ),
	 .RVALID_S1  (rvalid_s1 ),
	 .RREADY_S1  (rready_s1 ),
   //s2
	 .ARID_S2    (arid_s2   ),
	 .ARADDR_S2  (araddr_s2 ),
	 .ARLEN_S2   (arlen_s2  ),
	 .ARSIZE_S2  (arsize_s2 ),
	 .ARBURST_S2 (arburst_s2),
	 .ARVALID_S2 (arvalid_s2),
	 .ARREADY_S2 (arready_s2),
	 .RID_S2     (rid_s2    ),
	 .RDATA_S2   (rdata_s2  ),
	 .RRESP_S2   (rresp_s2  ),
	 .RLAST_S2   (rlast_s2  ),
	 .RVALID_S2  (rvalid_s2 ),
	 .RREADY_S2  (rready_s2 ),
   //s3
	 .ARID_S3    (arid_s3   ),
	 .ARADDR_S3  (araddr_s3 ),
	 .ARLEN_S3   (arlen_s3  ),
	 .ARSIZE_S3  (arsize_s3 ),
	 .ARBURST_S3 (arburst_s3),
	 .ARVALID_S3 (arvalid_s3),
	 .ARREADY_S3 (arready_s3),
	 .RID_S3     (rid_s3    ),
	 .RDATA_S3   (rdata_s3  ),
	 .RRESP_S3   (rresp_s3  ),
	 .RLAST_S3   (rlast_s3  ),
	 .RVALID_S3  (rvalid_s3 ),
	 .RREADY_S3  (rready_s3 ),
   //s4
	 .ARID_S4    (arid_s4   ),
	 .ARADDR_S4  (araddr_s4 ),
	 .ARLEN_S4   (arlen_s4  ),
	 .ARSIZE_S4  (arsize_s4 ),
	 .ARBURST_S4 (arburst_s4),
	 .ARVALID_S4 (arvalid_s4),
	 .ARREADY_S4 (arready_s4),
	 .RID_S4     (rid_s4    ),
	 .RDATA_S4   (rdata_s4  ),
	 .RRESP_S4   (rresp_s4  ),
	 .RLAST_S4   (rlast_s4  ),
	 .RVALID_S4  (rvalid_s4 ),
	 .RREADY_S4  (rready_s4 ),
    //s5
	 /*.ARID_S5    (),
	 .ARADDR_S5  (),
	 .ARLEN_S5   (),
	 .ARSIZE_S5  (),
	 .ARBURST_S5 (),
	 .ARVALID_S5 (),
	 .ARREADY_S5 (),
	 .RID_S5     (),
	 .RDATA_S5   (),
	 .RRESP_S5   (),
	 .RLAST_S5   (),
	 .RVALID_S5  (),
	 .RREADY_S5  (),*/
	 
	 //s6
	 .ARID_S6    (arid_s6   ),
	 .ARADDR_S6  (araddr_s6 ),
	 .ARLEN_S6   (arlen_s6  ),
	 .ARSIZE_S6  (arsize_s6 ),
	 .ARBURST_S6 (arburst_s6),
	 .ARVALID_S6 (arvalid_s6),
	 .ARREADY_S6 (arready_s6),
	 .RID_S6     (rid_s6    ),
	 .RDATA_S6   (rdata_s6  ),
	 .RRESP_S6   (rresp_s6  ),
	 .RLAST_S6   (rlast_s6  ),
	 .RVALID_S6  (rvalid_s6 ),
	 .RREADY_S6  (rready_s6 )
	 
	);
   //Slave 3
   SCtrl_wrapper SCtrl_wrapper(
	.clk(clk),
	.resetn(rst),
    /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	.AWID(awid_s3),
	.AWADDR(awaddr_s3),
	.AWLEN(awlen_s3), // 0 == (len=1)
	.AWSIZE(awsize_s3), // 0b010 == (Bytes in transfer=4)
	.AWBURST(awburst_s3),// = INCR = 0b01
	.AWVALID(awvalid_s3),
	.AWREADY(awready_s3),
	//WRITE DATA1
	.WDATA(wdata_s3),
	.WSTRB(wstrb_s3),
	.WLAST(wlast_s3),
	.WVALID(wvalid_s3),
    .WREADY(wready_s3),
	//WRITE RESPONSE1
	.BID(bid_s3),
	.BRESP(bresp_s3),
	.BVALID(bvalid_s3),
	.BREADY(bready_s3),
    /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s3),
	.ARADDR(araddr_s3),
	.ARLEN(arlen_s3), // 0 == (len=1)
	.ARSIZE(arsize_s3), // 0b010 == (Bytes in transfer=4)
	.ARBURST(arburst_s3),// = INCR = 0b01
	.ARVALID(arvalid_s3),
	.ARREADY(arready_s3),
	//READ DATA1
	.RID(rid_s3),
	.RDATA(rdata_s3),
	.RRESP(rresp_s3),
	.RLAST(rlast_s3),
	.RVALID(rvalid_s3),
	.RREADY(rready_s3),
	//for sensor(top_tb)
	.sensor_en(sensor_en),
	.sensor_ready(sensor_ready),
	.sensor_out(sensor_out),//data from sensor
	//for cpu
	.sctrl_interrupt(sensor_interrupt)
);
  // Slave : S1
  SRAM_wrapper IM1
  (
	.clk(clk),
	.resetn(!rst),
  /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	.AWID(awid_s1),
	.AWADDR(awaddr_s1),
	.AWLEN(awlen_s1), 
	.AWSIZE(awsize_s1), 
	.AWBURST(awburst_s1),
	.AWVALID(awvalid_s1),
	.AWREADY(awready_s1),
	//WRITE DATA1
	.WDATA(wdata_s1),
	.WSTRB(wstrb_s1),
	.WLAST(wlast_s1),
	.WVALID(wvalid_s1),
	.WREADY(wready_s1),
	//WRITE RESPONSE1
	.BID(bid_s1),
	.BRESP(bresp_s1),
	.BVALID(bvalid_s1),
	.BREADY(bready_s1),
    /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s1),
	.ARADDR(araddr_s1),
	.ARLEN(arlen_s1), 
	.ARSIZE(arsize_s1), 
	.ARBURST(arburst_s1),
	.ARVALID(arvalid_s1),
	.ARREADY(arready_s1),
	//READ DATA1
	.RID(rid_s1),
	.RDATA(rdata_s1),
	.RRESP(rresp_s1),
	.RLAST(rlast_s1),
	.RVALID(rvalid_s1),
	.RREADY(rready_s1)
    );
    
  // Slave S2
  SRAM_wrapper DM1
  (
	.clk(clk),
	.resetn(!rst),
  /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	.AWID(awid_s2),
	.AWADDR(awaddr_s2),
	.AWLEN(awlen_s2), 
	.AWSIZE(awsize_s2), 
	.AWBURST(awburst_s2),
	.AWVALID(awvalid_s2),
	.AWREADY(awready_s2),
	//WRITE DATA1
	.WDATA(wdata_s2),
	.WSTRB(wstrb_s2),
	.WLAST(wlast_s2),
	.WVALID(wvalid_s2),
	.WREADY(wready_s2),
	//WRITE RESPONSE1
	.BID(bid_s2),
	.BRESP(bresp_s2),
	.BVALID(bvalid_s2),
	.BREADY(bready_s2),
  /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s2),
	.ARADDR(araddr_s2),
	.ARLEN(arlen_s2), 
	.ARSIZE(arsize_s2), 
	.ARBURST(arburst_s2),
	.ARVALID(arvalid_s2),
	.ARREADY(arready_s2),
	//READ DATA1
	.RID(rid_s2),
	.RDATA(rdata_s2),
	.RRESP(rresp_s2),
	.RLAST(rlast_s2),
	.RVALID(rvalid_s2),
	.RREADY(rready_s2));
	
	DMA_wrapper DMA (
	/*----------------- input------------------*/
	.ACLK(clk),
	.ARESETn(rst),
	.load(1'b1),	//.load(load),			
	/*  Master input  */
	//m2
	.AWREADY_M1(awready_m2),
	.WREADY_M1(wready_m2),
	.BID_M1(bid_m2),
	.BRESP_M1(bresp_m2),
	.BVALID_M1(bvalid_m2),
	.ARREADY_M1(arready_m2),
	.RID_M1(rid_m2),
	.RDATA_M1(rdata_m2),
	.RRESP_M1(rresp_m2),
	.RLAST_M1(rlast_m2),
	.RVALID_M1(rvalid_m2),
	/*  Slave input  */
	.AWID(awid_s5),
	.AWADDR(awaddr_s5),
	.AWLEN(awlen_s5),
	.AWSIZE(awsize_s5),
	.AWBURST(awburst_s5),
	.AWVALID(awvalid_s5),
	.WDATA(wdata_s5),
	.WSTRB(wstrb_s5),
	.WLAST(wlast_s5),
	.WVALID(wvalid_s5),
	.BREADY(bready_s5),
	/*-----------------output ------------------*/
	.ACK(),
	.interrupt(DMA_interrupt),
	/*  Master output  */
	.AWID_M1(awid_m2),
	.AWADDR_M1(awaddr_m2),
	.AWLEN_M1(awlen_m2),
	.AWSIZE_M1(awsize_m2),
	.AWBURST_M1(awburst_m2),
	.AWVALID_M1(awvalid_m2),
	.WDATA_M1(wdata_m2),
	.WSTRB_M1(wstrb_m2),
	.WLAST_M1(wlast_m2),
	.WVALID_M1(wvalid_m2),
	.BREADY_M1(bready_m2),
	.ARID_M1(arid_m2),
	.ARADDR_M1(araddr_m2),
	.ARLEN_M1(arlen_m2),
	.ARSIZE_M1(arsize_m2),
	.ARBURST_M1(arburst_m2),
	.ARVALID_M1(arvalid_m2),
	.RREADY_M1(rready_m2),
	/*  Slave output  */
	.AWREADY(awready_s5),
	.WREADY(wready_s5),
	.BID(bid_s5),
	.BRESP(bresp_s5),
	.BVALID(bvalid_s5)
	);
	
	//Slave 6
   CNN_wrapper_layer1 CNN_wrapper(
	.clk(clk),
	.resetn(rst),
    /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	.AWID(awid_s6),
	.AWADDR(awaddr_s6),
	.AWLEN(awlen_s6), // 0 == (len=1)
	.AWSIZE(awsize_s6), // 0b010 == (Bytes in transfer=4)
	.AWBURST(awburst_s6),// = INCR = 0b01
	.AWVALID(awvalid_s6),
	.AWREADY(awready_s6),
	//WRITE DATA1
	.WDATA(wdata_s6),
	.WSTRB(wstrb_s6),
	.WLAST(wlast_s6),
	.WVALID(wvalid_s6),
    .WREADY(wready_s6),
	//WRITE RESPONSE1
	.BID(bid_s6),
	.BRESP(bresp_s6),
	.BVALID(bvalid_s6),
	.BREADY(bready_s6),
    /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	.ARID(arid_s6),
	.ARADDR(araddr_s6),
	.ARLEN(arlen_s6), // 0 == (len=1)
	.ARSIZE(arsize_s6), // 0b010 == (Bytes in transfer=4)
	.ARBURST(arburst_s6),// = INCR = 0b01
	.ARVALID(arvalid_s6),
	.ARREADY(arready_s6),
	//READ DATA1
	.RID(rid_s6),
	.RDATA(rdata_s6),
	.RRESP(rresp_s6),
	.RLAST(rlast_s6),
	.RVALID(rvalid_s6),
	.RREADY(rready_s6),
	//for cpu
	.cnn_interrupt(cnn_interrupt)
);
endmodule
