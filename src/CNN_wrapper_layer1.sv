//================================================
// Filename:    CNN_wrapper.sv                            
// Version:     1.0 
//================================================
`include "../include/AXI_define.svh" 
`include "./CNN1/cnn_rtl.sv"
`include "par_sensor_counter.sv"

module CNN_wrapper_layer1 (
	input clk,
	input resetn,
  /*---------------------WRITE PART------------------------*/	
	//WRITE ADDRESS1
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN, // 0 == (len=1)
	input [`AXI_SIZE_BITS-1:0] AWSIZE, // 0b010 == (Bytes in transfer=4)
	input [1:0] AWBURST,// = INCR = 0b01
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA1
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE1
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
  /*---------------------READ PART------------------------*/
	//READ ADDRESS1
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN, // 0 == (len=1)
	input [`AXI_SIZE_BITS-1:0] ARSIZE, // 0b010 == (Bytes in transfer=4)
	input [1:0] ARBURST,// = INCR = 0b01
	input ARVALID,
	output logic ARREADY,
	//READ DATA1
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,
	//for cpu
	output logic cnn_interrupt
);
/*---------------------All Parameters---------------------*/	
// For CNN_top port
logic [127:0] cnn_result;//cnn result data output
logic [31:0]rdata;


// For FSM
logic [2:0] Rstate;
logic [2:0] NRstate;
logic [2:0] Wstate;
logic [2:0] NWstate;
//wire ARHandShake;
wire RHandShake;
//logic CS_R;
logic [31:0] AR;
logic [31:0] AW;
//---------------------------
// To Store Data:Write-------

logic [31:0] _AW;
logic [3:0] _len;
//logic [2:0] _size;
//logic [1:0] _burst;

// For AXI port-------------
logic [7:0] _BID;
//---------------------------
// To Store Data:Read-------
// For SCtrl port-------------
logic [31:0] _AR;

logic [2:0] _size;
logic [1:0] _burst;

// For AXI port-------------
logic [7:0] _RID;
logic [31:0] _RDATA;

// For wrapper
logic [`AXI_LEN_BITS-1:0] len; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] size; // 0b010 == (Bytes in transfer=4)
logic [1:0] burst;// = INCR = 0b01

logic busy_R;
logic busy_W; 

/*-----------------------counter----------------------*/
/*logic CtrLoad;
logic CtrCarry;

counter_sram counter_sram(
.rst(~resetn), 
.clk(clk),
.stop(!RHandShake),
.load(CtrLoad),
.carry(CtrCarry),
.load_value(len));*/
logic CtrLoad;
logic CtrCarry;
logic CtrStop;
logic [2:0] count;



par_sensor_counter #(.NUM(3))
CNN_counter(
.rst(resetn), 
.clk(clk),
.stop(CtrStop),
.load(CtrLoad),
.carry(CtrCarry),
.count(count),
.load_value(3'd4));
/*---------------------Connection---------------------*/	
 cnn CNN_top(
	.clk(clk),
	.rst(resetn),
	.araddr(AR),
	.arvalid(ARVALID),
	.wdata(WDATA),
	.wvalid(WVALID),	
	.awaddr(AW),
	.awvalid(AWVALID),
	//in out port
	.rdata(rdata),
	.cnn_128(cnn_result),
	.interrupt_signal(cnn_interrupt)
);

 
/*---------------------WRITE PART------------------------*/
//for mem mapping(sctrl_en/sctrl_clear)
//parameter Write_RESET = 3'b000;	
parameter Write_IDLE = 3'b001;
parameter Write_ADDR = 3'b010;
parameter Write_DATA = 3'b011;
parameter Write_RESP = 3'b100;
parameter Write_BUSY = 3'b101;
//parameter Write_BUSY2 = 3'b110;

wire WHandShake;
wire BHandShake;
// assign AWHandShake = AWVALID & AWREADY;
assign WHandShake = WVALID & WREADY;
assign BHandShake = BVALID & BREADY;

always_ff@(posedge clk or posedge resetn) begin
  if(resetn) begin
    Wstate <= Write_IDLE;
    // For SRAM port-------------
    _AW <= 32'd0;
    
    // _len <= 4'b0;
    // _size <= 3'b0;
    // _burst <= 2'b0;
    // For AXI port-------------
    _BID <= 8'b0;
    end
  else begin
    Wstate <= NWstate;
    // For SRAM port-------------
    _AW <= AW;
    
    // _len <= len;
    // _size <= size;
    // _burst <= burst;
    // For AXI port-------------
    _BID <= BID;
    end
end

always_comb begin        
  case(Wstate)     
  Write_IDLE:
    if(AWVALID) // =AWHandShake
      if(busy_R)
        NWstate = Write_BUSY;
      else if(WHandShake & WLAST)
        NWstate = Write_RESP;
      else
        NWstate = Write_DATA;
    else
      NWstate = Write_IDLE;
  Write_BUSY:
    if(busy_R)
      NWstate = Write_BUSY; 
    else
      NWstate = Write_DATA;  
  Write_DATA:
    if(WHandShake & WLAST)
      NWstate = Write_RESP;
    else
      NWstate = Write_DATA;     
  Write_RESP:
    if(BHandShake)
      NWstate = Write_IDLE;
    else
      NWstate = Write_RESP;
  default:
    NWstate = Write_IDLE;
  endcase
end    
 
always_comb begin
  case(Wstate)      
  Write_IDLE: begin
    if(AWVALID) begin
      // For SCtrl port-------------
      AW = AWADDR;
		
      // set input output-----------
      // len = AWLEN; //AWLEN
      // size = AWSIZE; //AWSIZE
      // burst = AWBURST; //AWBURST
        
      BID = AWID;
      BRESP = 2'b00;  
      // handshake signals
      if(busy_R) begin
        AWREADY=1'b0;
        WREADY=1'b0;
        end
      else begin
        AWREADY=1'b1; 
        WREADY=1'b1;
        end                
      // WREADY=1'b0;
      BVALID=1'b0;
      busy_W=1'b1;   
    end
    else begin
      // For SCtrl port-------------
      AW = 32'd0;
        
      // set input output-----------
      // len = 4'b0; //AWLEN
      // size = 3'b0; //AWSIZE
      // burst = 2'b0; //AWBURST
      
      BID = 8'd0;
      BRESP = 2'b00;  
      // handshake signals
      AWREADY=1'b0;
      WREADY=1'b0;
      BVALID=1'b0;
      busy_W=1'b0;
    end
  end
  Write_BUSY: begin
    // For SCtrl port-------------
    AW = _AW;

        
    // set input output-----------
    // len = _len; //AWLEN
    // size = _size; //AWSIZE
    // burst = _burst; //AWBURST
    
    BID = _BID;
    BRESP = 2'b00;  
    // handshake signals
    if(busy_R) begin
        AWREADY=1'b0;
        WREADY=1'b0;
        end
    else begin
        AWREADY=1'b1;  
        WREADY=1'b1;
        end
    // WREADY=1'b0;
    BVALID=1'b0;
    busy_W=1'b0;    
  end   
  Write_DATA: begin
    // For SCtrl port-------------
    AW = _AW;
    // len = _len; //AWLEN
    // size = _size; //AWSIZE
    // burst = _burst; //AWBURST
    
    BID = _BID;
    BRESP = 2'b00;  
    // handshake signals
    AWREADY=1'b0;
    WREADY=1'b1;
    BVALID=1'b0;
    busy_W=1'b1;
  end
  Write_RESP: begin
    // For SCtrl port-------------
    AW = _AW;

    
    // set input output-----------
    // len = _len; //AWLEN
    // size = _size; //AWSIZE
    // burst = _burst; //AWBURST
    
    BID = _BID;
    BRESP = 2'b00;  
    // handshake signals
    AWREADY=1'b0;
    WREADY=1'b0;
    BVALID=1'b1;
    busy_W=1'b1;
    end
  default: begin
      // For SCtrl port-------------
      AW = _AW;
      
      // set input output-----------
      //len = _len; //AWLEN
      //size = _size; //AWSIZE
      //burst = _burst; //AWBURST
      
      BID = _BID;
      BRESP = 2'b00;  
      // handshake signals
      AWREADY=1'b0;
      WREADY=1'b0;
      BVALID=1'b1;
      busy_W=1'b0;
  end
  endcase   
end
/*---------------------READ PART------------------------*/
//parameter Read_RESET = 3'b000;
parameter Read_IDLE = 3'b001;
parameter Read_ADDR = 3'b010;
parameter Read_DATA = 3'b011;
parameter Read_DATA_t = 3'b100;
parameter Read_BUSY = 3'b101;

// assign ARHandShake = ARVALID & ARREADY;
assign RHandShake = RVALID & RREADY;

always_ff@(posedge clk or posedge resetn) begin
  if(resetn) begin
    Rstate <= Read_IDLE;
    _AR <= 32'd0;
    _RDATA <= 32'd0;
    _RID <= 8'd0;
    _len <= 4'd0;
    end
  else begin
    Rstate <= NRstate;
    _AR <= AR;
    _RDATA <= RDATA; 
    _RID <= RID;
    _len <= len;
  end
end

always_comb begin
  case(Rstate)
  Read_IDLE: //1
    if(ARVALID)
      if(busy_W)
        NRstate = Read_BUSY;
      else
        NRstate = Read_DATA;
    else
      NRstate = Read_IDLE;
  Read_BUSY:
    if(busy_W)
      NRstate = Read_BUSY;
    else
      NRstate = Read_DATA;      
  Read_DATA:
    if(RHandShake & RLAST)
      NRstate = Read_IDLE;
    else
      NRstate = Read_DATA;
  default:
    NRstate = Read_IDLE;
  endcase
end

always_comb begin
  //CtrLoad = 1'b0;
  case(Rstate)
  Read_IDLE:begin
    if(ARVALID) begin
      // For SCtrl port-------------
      //CS_R = 1'b1;
      AR =ARADDR; //ARADDR

      
      // set input output-----------
      len = ARLEN; //ARLEN
      // size = ARSIZE; //ARSIZE
      // burst = ARBURST; //ARBURST
      
      RID = ARID;
      RDATA = _RDATA; //cnn_result
      RRESP = 2'b00;
      RLAST = 1'b0; 
      // handshake signals
      if(busy_W)begin
        ARREADY=1'b0;
		//counter
		CtrLoad=1'b0;
      end
	  else begin
        ARREADY=1'b1;
		//counter
		CtrLoad=1'b1;
	  end
      RVALID=1'b0;
      busy_R=1'b1;
	  
	  
      end
    else begin
      // For SCtrl port-------------
      //CS_R = 1'b0;
      AR = 32'd0; //ARADDR



      // set input output-----------
      len = _len; //ARLEN
      // size = _size; //ARSIZE
      // burst = _burst; //ARBURST

      RID = _RID;
      RDATA = _RDATA; //cnn_result
      RRESP = 2'b00;
      RLAST = 1'b0; 
      // handshake signals
      ARREADY=1'b0;
      RVALID=1'b0;
      busy_R=1'b0;
	  //counter
	  CtrLoad=1'b0;
      end
  end
  Read_BUSY: begin
    // For SCtrl port-------------
    //CS_R = 1'b1;
    AR = ARADDR; //ARADDR

    
    // set input output-----------
    len = ARLEN; //ARLEN
    // size = ARSIZE; //ARSIZE
    // burst = ARBURST; //ARBURST
    
    RID = ARID;
    RDATA = 32'd0; //cnn_result
    RRESP = 2'b00;
    RLAST = 1'b0; 
    // handshake signals 
    if(busy_W)begin
        ARREADY=1'b0;
		//counter
		CtrLoad=1'b0;
      end
	  else begin
        ARREADY=1'b1;
		//counter
		CtrLoad=1'b1;
	  end
    RVALID=1'b0;
    busy_R=1'b1;
  end
  Read_DATA: begin
    // For SCtrl port-------------
    //CS_R = 1'b1;
    AR = _AR; //ARADDR


    
    // set input output-----------
    len = _len; //ARLEN
    // size = _size; //ARSIZE
    // burst = _burst; //ARBURST
    
    RID = _RID;

    //RDATA = cnn_result;
    RRESP = 2'b00;
    RLAST = (CtrCarry)?1'b1:1'b0; 
    // handshake signals
    ARREADY=1'b0;
    RVALID=1'b1;
    busy_R=1'b1;
	//counter
		CtrLoad=1'b1;
	case(count)
		3'd1:RDATA = cnn_result[31:0];
		3'd2:RDATA = cnn_result[63:32];
		3'd3:RDATA = cnn_result[95:64];
		3'd4:RDATA = cnn_result[127:96];
		default:RDATA = 32'd0;
	endcase
  end
  default: begin
    // For SCtrl port-------------
    //CS_R = 1'b0;
    AR = 32'd0; //ARADDR


    
    // set input output-----------
    len = 4'd0; //ARLEN
    // size = 3'b0; //ARSIZE
    // burst = 2'b0; //ARBURST
    
    RID = _RID;
    RDATA = 32'd0; //cnn_result
    RRESP = 2'b0;
    RLAST = 1'b0; 
    // handshake signals
    ARREADY=1'b0;
    RVALID=1'b0;
    busy_R=1'b0;
	//counter
		CtrLoad=1'b0;
  end
  endcase
end

/*-------------------Select One PART---------------------*/  
/*always_comb begin
    if(!resetn) begin
        //CS = 1'b0;
        sctrl_addr = 6'd0;
    end
    else begin
        //CS = CS_R;
        sctrl_addr = AR;
    end
end*/

endmodule
