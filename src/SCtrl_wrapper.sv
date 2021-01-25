//================================================
// Filename:    SCtrl_wrapper.sv                            
// Version:     1.0 
//================================================
`include "AXI_define.svh" 
`include "sensor_ctrl.sv"
`include "par_sensor_counter.sv"

module SCtrl_wrapper (
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
	//for sensor(top_tb)
	output logic sensor_en,
	input sensor_ready,
	input [31:0]sensor_out,//data from sensor
	//for cpu
	output logic sctrl_interrupt
	
);
/*---------------------All Parameters---------------------*/	
// For Sensor CTRL port
//active high
// Core inputs
logic sctrl_en;
logic sctrl_clear; 
logic [5:0] sctrl_addr;
// Sensor inputs
//logic sensor_ready;
//logic [31:0] sensor_out;//data from sensor
// Core outputs
//logic sctrl_interrupt;
logic [31:0] sctrl_out;//sensor ctrl data output
// Sensor outputs
//logic sensor_en;

// For FSM
logic [2:0] Rstate;
logic [2:0] NRstate;
logic [2:0] Wstate;
logic [2:0] NWstate;
//wire ARHandShake;
wire RHandShake;
//logic CS_R;
//logic [13:0] AR;
logic [31:0] AW;
//---------------------------
// To Store Data:Write-------
// For SCtrl port-------------

logic _sctrl_clear;
logic _sctrl_en;
logic [31:0] _AW;


logic [3:0] _len;
//logic [2:0] _size;
//logic [1:0] _burst;

// For AXI port-------------
logic [7:0] _BID;
//---------------------------
// To Store Data:Read-------
// For SCtrl port-------------
// logic [5:0] _sctrl_addr;


logic [2:0] _size;
logic [1:0] _burst;

// For AXI port-------------
logic [7:0] _RID;
logic [31:0] _RDATA;
logic [3:0] count;

// For wrapper
logic [`AXI_LEN_BITS-1:0] len; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] size; // 0b010 == (Bytes in transfer=4)
logic [1:0] burst;// = INCR = 0b01

logic busy_R;
logic busy_W; 

logic flag_sensor_en;
/*-----------------------counter----------------------*/
logic CtrLoad;
logic CtrCarry;
logic CtrStop;
logic sensor_ready_;



par_sensor_counter #(.NUM(4))
counter(
.rst(resetn), 
.clk(clk),
.stop(CtrStop),
.load(CtrLoad),
.carry(CtrCarry),
.count(count),
.load_value(len));

/*---------------------Connection---------------------*/	
assign sensor_ready_=(!flag_sensor_en)?1'b0:sensor_ready;

  sensor_ctrl SensorControl(
  .clk(clk),
  .rst(resetn),
  // Core inputs
  .sctrl_en(sctrl_en),
  .sctrl_clear(sctrl_clear),
  .sctrl_addr(sctrl_addr),//from cpu through AXI
  // Sensor inputs
  .sensor_ready(sensor_ready_),//from top_tb(sensor)
  .sensor_out(sensor_out),//from top_tb(sensor)
  // Core outputs
  .sctrl_interrupt(sctrl_interrupt),
  .sctrl_out(sctrl_out),//go to cpu through AXI
  // Sensor outputs
  .sensor_en(sensor_en)//go to top_tb(sensor)
);

 
/*---------------------WRITE PART------------------------*/
//for mem mapping(sctrl_en/sctrl_clear)
parameter Write_RESET = 3'b000;	
parameter Write_IDLE = 3'b001;
parameter Write_ADDR = 3'b010;
parameter Write_DATA = 3'b011;
parameter Write_RESP = 3'b100;
parameter Write_BUSY = 3'b101;
parameter Write_BUSY2 = 3'b110;

wire WHandShake;
wire BHandShake;
// assign AWHandShake = AWVALID & AWREADY;
assign WHandShake = WVALID & WREADY;
assign BHandShake = BVALID & BREADY;

always_ff@(posedge clk or posedge resetn) begin
  if(resetn) begin
    Wstate <= Write_RESET;
    // For SRAM port-------------
    _AW <= 32'd0;
    _sctrl_en<=1'b0;
    _sctrl_clear<=1'b0;
      
    // _len <= 4'b0;
    // _size <= 3'b0;
    // _burst <= 2'b0;
    // For AXI port-------------
    _BID <= 8'b0;
    flag_sensor_en <= 1'b0;
    end
  else begin
    Wstate <= NWstate;
    // For SRAM port-------------
    _AW <= AW;
    _sctrl_en<=sctrl_en;
    _sctrl_clear<=sctrl_clear;
    
    // _len <= len;
    // _size <= size;
    // _burst <= burst;
    // For AXI port-------------
    _BID <= BID;
    flag_sensor_en <= sensor_en;
    end
end

always_comb begin        
  case(Wstate)
  Write_RESET: 
    NWstate = Write_IDLE;        
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
  CtrStop=1'b0;
  case(Wstate)
  Write_RESET: begin
    // For SRAM port-------------
    AW = 32'd0;
    sctrl_en=1'b0;
		sctrl_clear=1'b0;
    
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
    CtrStop=1'b1;
    end       
  Write_IDLE: begin
    if(AWVALID) begin
      // For SCtrl port-------------
      AW = AWADDR;
	if(WVALID)begin
		if(AWADDR==32'h1000_0100)begin
			if(WDATA!=32'd0)begin
				sctrl_en=1'b1;
				sctrl_clear=_sctrl_clear;
			end
			else begin
				sctrl_en=1'b0;
				sctrl_clear=_sctrl_clear;			
			end
		end
		else if(AWADDR==32'h1000_0200)begin
			if(WDATA!=32'd0)begin
				sctrl_clear=1'b1;
				sctrl_en=_sctrl_en;
			end
			else begin
				sctrl_clear=1'b0;
				sctrl_en=_sctrl_en;
			end
		end
		else begin
			sctrl_en=_sctrl_en;
			sctrl_clear=_sctrl_clear;
		end
	end
	else begin
		sctrl_en=_sctrl_en;
		sctrl_clear=_sctrl_clear;
	end
 
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
      sctrl_en=_sctrl_en;
      sctrl_clear=_sctrl_clear;
        
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
		sctrl_en=_sctrl_en;
		sctrl_clear=_sctrl_clear;
        
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
    sctrl_en=_sctrl_en;
    sctrl_clear=_sctrl_clear;
    if(WVALID)begin
		if(AWADDR==32'h1000_0100)begin
			if(WDATA!=32'd0)begin
				sctrl_en=1'b1;
				sctrl_clear=_sctrl_clear;
			end
			else begin
				sctrl_en=1'b0;
				sctrl_clear=_sctrl_clear;			
			end
		end
		else if(AWADDR==32'h1000_0200)begin
			if(WDATA!=32'd0)begin
				sctrl_clear=1'b1;
				sctrl_en=_sctrl_en;
			end
			else begin
				sctrl_clear=1'b0;
				sctrl_en=_sctrl_en;
			end
		end
		else begin
			sctrl_en=_sctrl_en;
			sctrl_clear=_sctrl_clear;
		end
	end
	else begin
		sctrl_en=_sctrl_en;
		sctrl_clear=_sctrl_clear;
	end
		
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
    sctrl_en=_sctrl_en;
    sctrl_clear=_sctrl_clear;
    
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
      sctrl_en=_sctrl_en;
      sctrl_clear=_sctrl_clear;
      
      // set input output-----------
      //len = _len; //AWLEN
      //size = _size; //AWSIZE
      //burst = _burst; //AWBURST
      
      BID = _BID;
      BRESP = 2'b00;  
      // handshake signals
      AWREADY=1'b0;
      WREADY=1'b0;
      BVALID=1'b0;
      busy_W=1'b0;
  end
  endcase   
end
/*---------------------READ PART------------------------*/
parameter Read_RESET = 3'b000;
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
    // _sctrl_addr <= 6'd0;
    _RDATA <= 32'd0;
    _RID <= 8'd0;
    _len <= 4'd0;
    end
  else begin
    Rstate <= NRstate;
    // _sctrl_addr <= sctrl_addr;
    _RDATA <= RDATA; 
    _RID <= RID;
    _len <= len;
  end
end

always_comb begin

  case(Rstate)
  /*Read_RESET:
  NRstate = Read_IDLE;*/
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
  CtrLoad = 1'b0;
  case(Rstate)
  /*Read_RESET: begin
    // For SCtrl port-------------
    //CS_R = 1'b0;
    sctrl_addr = 6'd0; //ARADDR

    
    // set input output-----------
    len = 4'd0; //ARLEN
    // size = 3'b0; //ARSIZE
    // burst = 2'b0; //ARBURST
    
    RID = 8'd0;
    RDATA = 32'd0; //sctrl_out
    RRESP = 2'd0;
    RLAST = 1'd0; 
    // handshake signals
    ARREADY=1'b0;
    RVALID=1'b0;
    busy_R=1'b0;
    end*/
  Read_IDLE:begin
    if(ARVALID) begin
      // For SCtrl port-------------
      //CS_R = 1'b1;
      sctrl_addr = ARADDR[7:2]; //ARADDR [7:2]?

      
      // set input output-----------
      len = ARLEN; //ARLEN
      // size = ARSIZE; //ARSIZE
      // burst = ARBURST; //ARBURST
      
      RID = ARID;
      RDATA = _RDATA; //sctrl_out
      RRESP = 2'b00;
      RLAST = 1'b0; 
      // handshake signals
      if(busy_W)
        ARREADY=1'b0;
      else
        ARREADY=1'b1;
      RVALID=1'b0;
      busy_R=1'b1;
      end
    else begin
      // For SCtrl port-------------
      //CS_R = 1'b0;
      sctrl_addr = 6'd0; //ARADDR



      // set input output-----------
      len = _len; //ARLEN
      // size = _size; //ARSIZE
      // burst = _burst; //ARBURST

      RID = _RID;
      RDATA = _RDATA; //sctrl_out
      RRESP = 2'b00;
      RLAST = 1'b0; 
      // handshake signals
      ARREADY=1'b0;
      RVALID=1'b0;
      busy_R=1'b0;
      end
  end
  Read_BUSY: begin
    // For SCtrl port-------------
    //CS_R = 1'b1;
    sctrl_addr = ARADDR[7:2]; //ARADDR

    
    // set input output-----------
    len = _len; //ARLEN
    // size = ARSIZE; //ARSIZE
    // burst = ARBURST; //ARBURST
    
    RID = ARID;
    RDATA = 32'd0; //sctrl_out
    RRESP = 2'b00;
    RLAST = 1'b0; 
    // handshake signals 
    if(busy_W)
      ARREADY=1'b0;
    else
      ARREADY=1'b1;
    RVALID=1'b0;
    busy_R=1'b1;
  end
  Read_DATA: begin
    // For SCtrl port-------------
    //CS_R = 1'b1;
	sctrl_addr=ARADDR[7:2]+{2'b00,count};
    CtrLoad=1'b1;
    //sctrl_addr = (CtrCarry)?_sctrl_addr:(_sctrl_addr+1); //ARADDR
    //sctrl_addr = _sctrl_addr+6'd1; //ARADDR


    
    // set input output-----------
    len = _len; //ARLEN
    // size = _size; //ARSIZE
    // burst = _burst; //ARBURST
    
    RID = _RID;

    RDATA = sctrl_out;
    RRESP = 2'b00;
    RLAST = (CtrCarry)?1'b1:1'b0; 
    // handshake signals
    ARREADY=1'b0;
    RVALID=1'b1;
    busy_R=1'b1;
  end
  default: begin
    // For SCtrl port-------------
    //CS_R = 1'b0;
    sctrl_addr = 6'd0; //ARADDR


    
    // set input output-----------
    len = 4'd0; //ARLEN
    // size = 3'b0; //ARSIZE
    // burst = 2'b0; //ARBURST
    
    RID = _RID;
    RDATA = 32'd0; //sctrl_out
    RRESP = 2'b0;
    RLAST = 1'b0; 
    // handshake signals
    ARREADY=1'b0;
    RVALID=1'b0;
    busy_R=1'b0;
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
