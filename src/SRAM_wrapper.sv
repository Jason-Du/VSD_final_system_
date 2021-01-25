//================================================
// Filename:    SRAM_wrapper.sv                            
// Version:     2.0 
// ------- 20201115 -------
// AWHandShake and WHandShake together
// ------- 20201116 -------
// use AXI and change len to get data // reduce cycles
//================================================
`include "AXI_define.svh" 
`include "counter_sram.sv"

module SRAM_wrapper (
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
	input RREADY
);
/*---------------------All Parameters---------------------*/	
// For SRAM port
logic CS;
logic [13:0] A;
logic OE; 
logic [31:0] DO;
logic [3:0] WEB;
logic [31:0] DI;
// For FSM
logic [2:0] Wstate;
logic [2:0] NWstate;
logic [2:0] Rstate;
logic [2:0] NRstate;
// wire AWHandShake;
wire WHandShake;
wire BHandShake;
// wire ARHandShake;
wire RHandShake;
logic CS_R;
logic CS_W;
logic [13:0] AR;
logic [13:0] AW;
//---------------------------
// To Store Data:Write-------
// For SRAM port-------------
logic [13:0] _AR;
logic [31:0] _DI;
logic [3:0] _WEB;

logic [3:0] _len;
logic [2:0] _size;
logic [1:0] _burst;
// For AXI port-------------
logic [7:0] _BID;
//---------------------------
// To Store Data:Read-------
// For SRAM port-------------
logic [13:0] _AW;
/*
logic [31:0] _DI;
logic [3:0] _WEB;
logic [3:0] _len;
logic [2:0] _size;
logic [1:0] _burst;
*/
// For AXI port-------------
logic [7:0] _RID;
logic [31:0] _RDATA;

// For wrapper
logic [`AXI_LEN_BITS-1:0] len; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] size; // 0b010 == (Bytes in transfer=4)
logic [1:0] burst;// = INCR = 0b01

logic busy_R;
logic busy_W; 


logic CtrLoad;
logic CtrCarry;

counter_sram counter_sram(
.rst(~resetn), 
.clk(clk),
.stop(!RHandShake),
.load(CtrLoad),
.carry(CtrCarry),
.load_value(len));
/*---------------------Connection---------------------*/	
  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (clk    ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

 
/*---------------------WRITE PART------------------------*/
parameter Write_RESET = 3'b000;	
parameter Write_IDLE = 3'b001;
parameter Write_ADDR = 3'b010;
parameter Write_DATA = 3'b011;
parameter Write_RESP = 3'b100;
parameter Write_BUSY = 3'b101;
parameter Write_BUSY2 = 3'b110;

// assign AWHandShake = AWVALID & AWREADY;
assign WHandShake = WVALID & WREADY;
assign BHandShake = BVALID & BREADY;

logic seperate_AW_W;
always_ff@(posedge clk or negedge resetn) begin
    if(!resetn) begin
	seperate_AW_W<=1'd0;
        end
    else begin
	if((AWVALID)&&(!WVALID))
		seperate_AW_W<=1'd1;
	else
		seperate_AW_W<=1'd0;
        end
end

always_ff@(posedge clk or negedge resetn) begin
    if(!resetn) begin
        //Wstate <= Write_RESET;
        Wstate <= Write_IDLE;
        // For SRAM port-------------
        _AW <= 14'b0;
        _DI <= 32'b0;
        _WEB <= 4'b1111;
        
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
        _DI <= DI;
        _WEB <= WEB;
        
        // _len <= len;
        // _size <= size;
        // _burst <= burst;
        // For AXI port-------------
        _BID <= BID;
        end
end

always_comb begin        
    case(Wstate)
    //Write_RESET: 
    //    NWstate = Write_IDLE;        
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
    /*Write_RESET: begin
        // For SRAM port-------------
        CS_W = 1'b0;
        AW = 14'b0;
        // OE = 1'b0; 
        // Data = DO;
        WEB = 4'b1111;
        DI = 32'b0;
        
        // set input output-----------
        // len = 4'b0; //AWLEN
        // size = 3'b0; //AWSIZE
        // burst = 2'b0; //AWBURST
        
        BID = 8'b0;
        BRESP = 2'b00;  
        // handshake signals
        AWREADY=1'b0;
        WREADY=1'b0;
        BVALID=1'b0;
        busy_W=1'b0;
    end       */
    Write_IDLE: begin
        if(AWVALID) begin
            // For SRAM port-------------
            CS_W = 1'b1;
            AW = AWADDR[15:2];
            // OE = 1'b0; 
            // Data = DO;
            WEB = (WVALID)? WSTRB:4'b1111;
            DI = (WVALID)? WDATA:32'b0;
            
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
            // Think : WVALID_M1 could rise 
            BVALID=1'b0;
            busy_W=1'b1;
            end     
        else begin
        begin
            // For SRAM port-------------
            CS_W = 1'b0;
            AW = 14'b0;
            // OE = 1'b0; 
            // Data = DO;
            WEB = 4'b1111;
            DI = 32'b0;
            
            // set input output-----------
            // len = 4'b0; //AWLEN
            // size = 3'b0; //AWSIZE
            // burst = 2'b0; //AWBURST
            
            BID = 8'b0;
            BRESP = 2'b00;  
            // handshake signals
            AWREADY=1'b0;
            WREADY=1'b0;
            BVALID=1'b0;
            busy_W=1'b0;
            end
        end
    end  
    Write_BUSY: begin
        // For SRAM port-------------
        CS_W = 1'b1;
        AW = _AW;
        // OE = 1'b0; 
        // Data = DO;
        WEB = 4'b1111;
        DI = WDATA;
        
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
        // For SRAM port-------------
        CS_W = 1'b1;
        AW = (seperate_AW_W==1'b1)?_AW:_AW + 14'd1;
        // OE = 1'b0; 
        // Data = DO;
        WEB = WSTRB;
        DI = WDATA;
        
        // set input output-----------
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
        // For SRAM port-------------
        CS_W = 1'b1;
        AW = _AW;
        // OE = 1'b0; 
        // Data = DO;
        WEB = 4'hf;
        DI = _DI;
        
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
        // For SRAM port-------------
        CS_W = 1'b1;
        AW = _AW;
        // OE = 1'b0; 
        // Data = DO;
        WEB = _WEB;
        DI = _DI;
        
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
parameter Read_RESET = 3'b000;
parameter Read_IDLE = 3'b001;
parameter Read_ADDR = 3'b010;
parameter Read_DATA = 3'b011;
parameter Read_DATA_t = 3'b100;
parameter Read_BUSY = 3'b101;

// assign ARHandShake = ARVALID & ARREADY;
assign RHandShake = RVALID & RREADY;

always_ff@(posedge clk or negedge resetn) begin
    if(!resetn) begin
        //Rstate <= Read_RESET;
        Rstate <= Read_IDLE;
        _AR <= 14'd0;
        _RDATA <= 32'b0;
        _RID <= 8'b0;
        _len <= 4'b0;
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
    /*Read_RESET:
        NRstate = Read_IDLE;*/
    Read_IDLE: //1
        if(ARVALID)
            if(busy_W)
                NRstate = Read_BUSY;
            else
                NRstate = Read_DATA_t;
        else
            NRstate = Read_IDLE;
     Read_BUSY:
       if(busy_W)
            NRstate = Read_BUSY;
        else
            NRstate = Read_DATA_t;      
    Read_DATA_t: //4
        if(CtrCarry)
            NRstate = Read_IDLE;
        else
            NRstate = Read_DATA_t;
    /*Read_DATA:
        if(RHandShake & RLAST)
            NRstate = Read_IDLE;
        else
            NRstate = Read_DATA;*/
    default:
        NRstate = Read_IDLE;
    endcase
end

always_comb begin
    CtrLoad = 1'b0;
    case(Rstate)
    /*Read_RESET: begin
        // For SRAM port-------------
        CS_R = 1'b0;
        AR = 14'b0; //ARADDR
        OE = 1'b0; 
        // WEB = 4'b1111;
        // DI = 32'b0;
        
        // set input output-----------
        len = 4'b0; //ARLEN
        // size = 3'b0; //ARSIZE
        // burst = 2'b0; //ARBURST
        
        RID = 8'b0;
        RDATA = 32'b0; //DO
        RRESP = 2'b0;
        RLAST = 1'b0; 
        // handshake signals
        ARREADY=1'b0;
        RVALID=1'b0;
        busy_R=1'b0;
        end*/
    Read_IDLE:begin
        if(ARVALID) begin
            // For SRAM port-------------
            CS_R = 1'b1;
            AR = ARADDR[15:2]; //ARADDR
            OE = 1'b0; 
            // WEB = 4'b1111;
            // DI = 32'b0;
            
            // set input output-----------
            len = ARLEN; //ARLEN
            // size = ARSIZE; //ARSIZE
            // burst = ARBURST; //ARBURST
            
            RID = ARID;
            RDATA = _RDATA; //DO
            RRESP = 2'b0;
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
            // For SRAM port-------------
            CS_R = 1'b0;
            AR = 14'b0; //ARADDR
            OE = 1'b0; 
            // WEB = 4'b1111;
            // DI = 32'b0;

            // set input output-----------
            len = _len; //ARLEN
            // size = _size; //ARSIZE
            // burst = _burst; //ARBURST

            RID = _RID;
            RDATA = _RDATA; //DO
            RRESP = 2'b0;
            RLAST = 1'b0; 
            // handshake signals
            ARREADY=1'b0;
            RVALID=1'b0;
            busy_R=1'b0;
            end
        end
    Read_BUSY: begin
        // For SRAM port-------------
        CS_R = 1'b1;
        AR = ARADDR[15:2]; //ARADDR
        OE = 1'b0; 
        // WEB = 4'b1111;
        // DI = 32'b0;
        
        // set input output-----------
        len = ARLEN; //ARLEN
        // size = ARSIZE; //ARSIZE
        // burst = ARBURST; //ARBURST
        
        RID = ARID;
        RDATA = 32'b0; //DO
        RRESP = 2'b0;
        RLAST = 1'b0; 
        // handshake signals 
        if(busy_W)
            ARREADY=1'b0;
        else
            ARREADY=1'b1;
        RVALID=1'b0;
        busy_R=1'b1;
        end
    Read_DATA_t: begin
        // For SRAM port-------------
        CS_R = 1'b1;
        AR = _AR + 14'd1; //ARADDR
       
        OE = 1'b1; 
        // WEB = 4'b1111;
        // DI = 32'b0;
        
        // set input output-----------
        len = _len; //ARLEN
        // size = _size; //ARSIZE
        // burst = _burst; //ARBURST
        
        RID = _RID;

        RDATA = DO;
        RRESP = 2'b00;
        RLAST = (CtrCarry)?1'b1:1'b0; 
        // handshake signals
        ARREADY=1'b0;
        RVALID=1'b1;
        busy_R=1'b1;
        
        CtrLoad = 1'b1;
        end
    /*Read_DATA: begin
        // For SRAM port-------------
        CS_R = 1'b1;
        AR = _AR; //ARADDR
        OE = 1'b1; 
        // WEB = 4'b1111;
        // DI = 32'b0;
        
        // set input output-----------
        len = _len; //ARLEN
        // size = _size; //ARSIZE
        // burst = _burst; //ARBURST
        
        RID = _RID;

        RDATA = _RDATA;
        RRESP = 2'b00;
        RLAST = 1'b1; 
        // handshake signals
        ARREADY=1'b0;
        RVALID=1'b1;
        busy_R=1'b1;
        end*/
    default: begin
        // For SRAM port-------------
        CS_R = 1'b0;
        AR = 14'b0; //ARADDR
        OE = 1'b0; 
        // WEB = 4'b1111;
        // DI = 32'b0;
        
        // set input output-----------
        len = 4'b0; //ARLEN
        // size = 3'b0; //ARSIZE
        // burst = 2'b0; //ARBURST
        
        RID = _RID;
        RDATA = 32'b0; //DO
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
always_comb begin
    if(!resetn) begin
        CS = 1'b0;
        A = 14'b0;
        end
    else if((Wstate==Write_IDLE) && (AWVALID==1'b1)) begin
        CS = CS_W;
        A = AW;
        end
    else if(Wstate==Write_DATA) begin
        CS = CS_W;
        A = AW;
        end
    else if((Rstate==Read_IDLE) && (ARVALID==1'b1)) begin
        CS = CS_R;
        A = AR;
        end
    else begin
        CS = CS_R;
        A = AR;
        end
end

endmodule
