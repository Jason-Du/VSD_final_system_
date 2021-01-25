//================================================
// Filename:    DRAM_wrapper.sv                            
// Version:     1.0 
//================================================
`timescale 1ns/10ps
`include "AXI_define.svh" 
`include "counter_dram.sv"
`include "counter_delay.sv"
//`include "DRAM.sv"

module DRAM_wrapper (
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
	//DRAM port
	input [31:0] Q,
	output logic CSn,
	output logic [3:0]WEn,
	output logic RASn,
	output logic CASn,
	output logic [10:0] A,
	output logic [31:0] D,
	input VALID
);

parameter DataNumberSize=4;

/*---------------------All Parameters---------------------*/	
// For DRAM port
/*logic CSn;
logic RASn;//DRAM row access strobe
logic CASn;//DRAM column access strobe
logic VALID;//data output valid
logic [10:0] A;
logic [31:0] Q;//DRAM data output
logic [3:0] WEn;
logic [31:0] D;//DRAM data input
*/
// For FSM

logic [3:0] state;
logic [3:0] Nstate;
// wire AWHandShake;
wire WHandShake;
wire BHandShake;
// wire ARHandShake;
wire RHandShake;
//---------------------------
// To Store Data:Write-------
// For DRAM port-------------
logic [10:0]_A;
logic [31:0] _D;
logic [3:0] _WEn;

logic _RASn;
logic _CASn;


logic [3:0] _len;
logic [2:0] _size;
logic [1:0] _burst;
// For AXI port-------------
logic [7:0] _BID;
//---------------------------
// To Store Data:Read-------
// For DRAM port-------------

/*
logic [31:0] _DI;
logic [3:0] _WEn;
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

//for row hit
logic row_hit;
logic [10:0]A_r;
logic [10:0]_A_r;
//*//
logic new_row_flag;
logic _new_row_flag;
logic new_row_flag_w;
logic _new_row_flag_w;
logic [31:0]A_plus;
logic [31:0]_A_plus;

/*-----------------------counter----------------------*/
//counter_DramData
logic CtrLoad_D;
logic _CtrLoad_D;
logic CtrCarry_D;
logic stop_D;

//counter_AR
logic CtrLoad_AR;
logic _CtrLoad_AR;
logic CtrCarry_AR;
logic Ctrstop_AR;
logic [3:0]len_AR;
//counter_tRP
logic CtrLoad_tRP;
logic CtrCarry_tRP;
logic Ctrstop_tRP;
logic [3:0]tRP_count;

//counter_tRCD
logic CtrLoad_tRCD;
logic CtrCarry_tRCD;
logic Ctrstop_tRCD;
logic [3:0]tRCD_count;

//counter_CL
logic CtrLoad_CL;
logic CtrCarry_CL;
logic _CtrCarry_CL;
logic Ctrstop_CL;
logic [3:0]CL_count;

//wire [DataNumberSize-1:0]DataNumber;




//determine from DMA ARLEN/AWLEN ,Preset=1
assign len_AR=len+4'd1;//len

counter_dram counter_DramData( //for cache read 4 data
.rst(resetn), 
.clk(clk),
.stop(stop_D),
.load(CtrLoad_D),
.carry(CtrCarry_D),
.load_value(len));

/*counter_dram counter_AR( //for cache read 4 data
.rst(resetn), 
.clk(clk),
.stop(Ctrstop_AR),
.load(CtrLoad_AR),
.carry(CtrCarry_AR),
.load_value(len_AR));*/

counter_delay tRP( 
.rst(resetn), 
.clk(clk),
.stop(Ctrstop_tRP),
.load(CtrLoad_tRP),
.carry(CtrCarry_tRP),
.count(tRP_count));

counter_delay tRCD( 
.rst(resetn), 
.clk(clk),
.stop(Ctrstop_tRCD),
.load(CtrLoad_tRCD),
.carry(CtrCarry_tRCD),
.count(tRCD_count));

counter_delay CL( 
.rst(resetn), 
.clk(clk),
.stop(Ctrstop_CL),
.load(CtrLoad_CL),
.carry(CtrCarry_CL),
.count(CL_count));


/*---------------------Connection---------------------*/	
 /* DRAM DRAM (
    .CK(~clk),//Because DRAM negedge change input value ? 
    .Q(Q),
    .RST(resetn),//need invert?
    .CSn(CSn),
    .WEn(WEn),
    .RASn(RASn),
    .CASn(CASn),
    .A(A),
    .D(D),
    .VALID(VALID)
  );*/
  
/*---------------------WRITE PART------------------------*/
// assign AWHandShake = AWVALID & AWREADY;
assign WHandShake = WVALID & WREADY;
assign BHandShake = BVALID & BREADY;
/*---------------------READ PART------------------------*/
// assign ARHandShake = ARVALID & ARREADY;
assign RHandShake = RVALID & RREADY;
//*-------------------state control---------------------*/
//parameter RESET = 4'b000;//0
parameter ACT = 4'b001;//1
parameter READ = 4'b010;//2
parameter READ_DATA = 4'b011;//3
parameter WRITE = 4'b0100;//4
parameter WRITE_DATA = 4'b0101;//5
parameter WRITE_RESP = 4'b0110;//6
parameter Row_Hit_check = 4'b0111;//7
parameter Pre_Charge = 4'b1000;//8
parameter ACT_R_W = 4'b1001;//9
parameter Wait_Pre_Charge = 4'b1010;//10

always_ff@(posedge clk or posedge resetn) begin
    if(resetn) begin
        //state <= RESET;
	state <= ACT;
        _A_r <= 11'd0;
		_A <= 11'd0;
		_RASn<=1'b1;
		_CASn<=1'b1;
        _RDATA <= 32'b0;
        _RID <= 8'b0;
        _len <= 4'b0;
		_D <= 32'b0;
        _WEn <= 4'b1111;
        _BID <= 8'b0;
		_CtrLoad_AR<=1'b0;
		//_CtrLoad_D<=1'b0;
		//*//
		_new_row_flag<=1'b0;
		_new_row_flag_w<=1'b0;
		_A_plus<=32'd0;
		_CtrCarry_CL<=1'b0;
		
        end
    else begin
        state <= Nstate;
        _A_r <= A_r;
		_A <= A;
		_RASn<=RASn;
		_CASn<=CASn;
        _RDATA <= RDATA; 
        _RID <= RID;
        _len <= len;
		_D <= D;
        _WEn <= WEn;
        _BID <= BID;
		_CtrLoad_AR<=CtrLoad_AR;
		//_CtrLoad_D<=CtrLoad_D;
		//*//
		_new_row_flag<=new_row_flag;
		_new_row_flag_w<=new_row_flag_w;
		_A_plus<=A_plus;
		_CtrCarry_CL<=CtrCarry_CL;
    end
end


always_comb begin        
    case(state)
    /*RESET: //0
        Nstate = ACT;   */     
    ACT: //1
		if(ARVALID||AWVALID||_new_row_flag||_new_row_flag_w)//*//
			Nstate = ACT_R_W;
		else
			Nstate = ACT; 
	ACT_R_W: //9
		if(tRCD_count>4'd4)begin //>=5 
			if(_new_row_flag)//*//
				Nstate = READ;
			else if(_new_row_flag_w)//*//
				Nstate = WRITE_DATA;
			else if(ARVALID) // =AWHandShake
				Nstate = READ;
			else if(AWVALID) // =AWHandShake
				Nstate = WRITE;
			else
				Nstate = ACT_R_W;
		end
		else begin
			Nstate = ACT_R_W;
		end
    READ: //set control signal state
		if(row_hit)//*//
			Nstate = READ_DATA; 
		else //*//
			Nstate = Pre_Charge; //*//
	READ_DATA: //3
		if(RHandShake && VALID&&!RLAST) //cache read 4 data
            Nstate = READ; 
		else if(RHandShake && RLAST)
			Nstate = Row_Hit_check;
        else
            Nstate = READ_DATA;
	WRITE: //set control signal state
		if(WHandShake & !WLAST) 
            Nstate = WRITE_DATA;
		else if(WHandShake & WLAST)begin
			Nstate = WRITE_RESP;
		end
		else begin
			Nstate = WRITE;
		end
	WRITE_DATA: //5
		if(!row_hit)//*//
			Nstate = Pre_Charge; //*//
        else if(WHandShake & WLAST) 
            Nstate = WRITE_RESP; 
        else
            Nstate = WRITE_DATA;
	WRITE_RESP: //6
		if(BHandShake)
            Nstate = Row_Hit_check;
        else
            Nstate = WRITE_RESP;
	Row_Hit_check: //7
		if((ARVALID||AWVALID)&&(CL_count>4'd3))begin//>=4 -> CL_count+ WRITE state >=5 cycle
			if(row_hit)begin
				if(ARVALID) // =AWHandShake
					Nstate = READ;
				else if(AWVALID) // =AWHandShake
					Nstate = WRITE;
				else
					Nstate = Row_Hit_check;
			end
			else begin
				Nstate = Pre_Charge;   
			end
		end
		else begin
			Nstate = Row_Hit_check;//<5 cycle need to wait
		end
	Pre_Charge: //8
            Nstate = Wait_Pre_Charge;
    Wait_Pre_Charge: //10
        if(tRP_count==4'd5)
            Nstate = ACT;
        else
            Nstate = Wait_Pre_Charge;
    default:
        Nstate = ACT;
    endcase
end   


always_comb begin
    //CtrLoad = 1'b0;
    stop_D=1'b0;
    Ctrstop_CL=1'b0;
    Ctrstop_tRP=1'b0;
    Ctrstop_tRCD=1'b0;
    case(state)
   /* RESET: begin
		row_hit=1'b0;
        // For DRAM input port-------------
        CSn = 1'b1;//active low
        A = 11'b0; //ARADDR
	  A_r=11'b0;
		RASn =1'b1;//active low
		CASn =1'b1;//active low
		D =32'd0;
        WEn = 4'b1111;
		
		////
		new_row_flag=1'b0;
		new_row_flag_w=1'b0;
		A_plus=32'd0;

        
        // set input output-----------
        len = 4'b0; //ARLEN
        // size = 3'b0; //ARSIZE
        // burst = 2'b0; //ARBURST
		//Read signal-----------------------
        RID = 8'b0;
        RDATA = 32'b0; //Q
        RRESP = 2'b0;
        RLAST = 1'b0; 
        // handshake signals
        ARREADY=1'b0;
        RVALID=1'b0;
		//Write signal-----------------------
		BID = 8'd0;
        BRESP = 2'b00;  
        // handshake signals
        AWREADY=1'b0;
        WREADY=1'b0;
        BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
        end*/
    ACT:begin
		row_hit=1'b0;
        if(ARVALID||_new_row_flag) begin//*//
            // For DRAM port-------------
            CSn = 1'b0;
            A =(_new_row_flag)?_A_plus[22:12]: ARADDR[22:12]; //row ARADDR//*//
			A_r=(_new_row_flag)?_A_plus[22:12]: ARADDR[22:12];//*//
			RASn=1'b0;
			CASn=1'b1;
			D =32'd0;
			WEn = 4'b1111;
			
			//*//
			new_row_flag=_new_row_flag;
			new_row_flag_w=_new_row_flag_w;
			A_plus=_A_plus;

            // set input output-----------
            len = ARLEN; //ARLEN
            // size = ARSIZE; //ARSIZE
            // burst = ARBURST; //ARBURST
			
            //Read signal-----------------------
			RID = ARID;
			RDATA = _RDATA; //Q
			RRESP = 2'b00;
			RLAST = 1'b0; 
			// handshake signals
			ARREADY=1'b0;
			RVALID=1'b0;
			//Write signal-----------------------
			BID = 8'd0;
			BRESP = 2'b00;  
			// handshake signals
			AWREADY=1'b0;
			WREADY=1'b0;
			BVALID=1'b0;
			//for counter----------------------
			//DATA
			CtrLoad_D=1'b0;
			//AR
			CtrLoad_AR=1'b0;
			//Ctrstop_AR=1'd0;
			//tRP
			CtrLoad_tRP=1'b0;
			Ctrstop_tRP=1'b0;
			//tRCD
			CtrLoad_tRCD=1'b1;
			Ctrstop_tRCD=1'b0;
			//CL
			CtrLoad_CL=1'b0;
			Ctrstop_CL=1'b0;
        end
		else if(AWVALID||_new_row_flag_w) begin
            // For DRAM port-------------
            CSn = 1'b0;
            // A = AWADDR[22:12]; //row ARADDR
			// A_r=AWADDR[22:12];
			A =(_new_row_flag_w)?_A_plus[22:12]: AWADDR[22:12]; //row ARADDR//*//
			A_r=(_new_row_flag_w)?_A_plus[22:12]: AWADDR[22:12];//*//
			RASn=1'b0;
			CASn=1'b1;
			WEn = 4'b1111;
            D = (WVALID)? WDATA:32'b0;
			
			//*//
			new_row_flag=_new_row_flag;
			new_row_flag_w=_new_row_flag_w;
			A_plus=_A_plus;
			
            // set input output-----------
            len = ARLEN; //ARLEN
            // size = ARSIZE; //ARSIZE
            // burst = ARBURST; //ARBURST
			
            //Read signal-----------------------
			RID = 8'd0;
			RDATA = 32'd0; //Q
			RRESP = 2'b00;
			RLAST = 1'b0; 
			// handshake signals
			ARREADY=1'b0;
			RVALID=1'b0;
			//Write signal-----------------------
			BID = AWID;
			BRESP = 2'b00;  
			// handshake signals
			AWREADY=1'b0;
			WREADY=1'b0;
			BVALID=1'b0;
			//for counter----------------------
			//DATA
			CtrLoad_D=1'b0;
			//AR
			CtrLoad_AR=1'b0;
			//Ctrstop_AR=1'd0;
			//tRP
			CtrLoad_tRP=1'b0;
			Ctrstop_tRP=1'b0;
			//tRCD
			CtrLoad_tRCD=1'b1;
			Ctrstop_tRCD=1'b0;
			//CL
			CtrLoad_CL=1'b0;
			Ctrstop_CL=1'b0;
        end
        else begin
            // For DRAM input port-------------
			CSn = 1'b1;//active low
			A = 11'b0; //ARADDR
			A_r=11'b0;
			RASn =1'b1;//active low
			CASn =1'b1;//active low
			D =32'd0;
			WEn = 4'b1111;
			
			//*//
			new_row_flag=_new_row_flag;
			new_row_flag_w=_new_row_flag_w;
			A_plus=_A_plus;
			
			// set input output-----------
			len = 4'b0; //ARLEN
			// size = 3'b0; //ARSIZE
			// burst = 2'b0; //ARBURST
			//Read signal-----------------------
			RID = 8'd0;
			RDATA = 32'b0; //Q
			RRESP = 2'b0;
			RLAST = 1'b0; 
			// handshake signals
			ARREADY=1'b0;
			RVALID=1'b0;
			//Write signal-----------------------
			BID = 8'd0;
			BRESP = 2'b00;  
			// handshake signals
			AWREADY=1'b0;
			WREADY=1'b0;
			BVALID=1'b0;
			//for counter----------------------
			//DATA
			CtrLoad_D=1'b0;
			//AR
			CtrLoad_AR=1'b0;
			//Ctrstop_AR=1'd0;
			//tRP
			CtrLoad_tRP=1'b0;
			Ctrstop_tRP=1'b0;
			//tRCD
			CtrLoad_tRCD=1'b0;
			Ctrstop_tRCD=1'b0;
			//CL
			CtrLoad_CL=1'b0;
			Ctrstop_CL=1'b0;
        end
    end
	ACT_R_W:begin
		row_hit=1'b0;
		// For DRAM port-------------
		CSn = 1'b0;
		A = _A; //row ARADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=1'b1;
		D =_D;
		WEn = _WEn;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;
		
		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = 32'd0; //Q
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;//_ARREADY?
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;//_AWREADY;
		WREADY=1'b0;//_WREADY;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b1;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
    READ: begin
        
		// For DRAM port-------------
		CSn = 1'b0;
		A_plus=(_new_row_flag)?_A_plus:((_CtrLoad_AR)?(_A_plus+32'd4):ARADDR);//*//
		row_hit=((_A_r==A_plus[22:12]))?1'b1:1'b0;//*//
		A ={1'b0,A_plus[11:2]}; //column ARADDR//*//
		A_r=(row_hit)?A_plus[22:12]:_A_r;//*//
		RASn=1'b1;
		CASn=(row_hit)?1'b0:1'b1;//*//
		D =_D;
		WEn = 4'b1111;
		
		
		new_row_flag=(row_hit)?1'b0:1'b1;//*//
		new_row_flag_w=_new_row_flag_w;//*//

		// set input output-----------
		len = ARLEN; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = ARID;
		RDATA = Q; //Q
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'b1;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
    READ_DATA: begin
        row_hit=1'b0;
		// For DRAM port-------------
		CSn = 1'b0;
		A = _A; //row ARADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=1'b1;
		D =_D;
		WEn = 4'b1111;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = ARID;
		RDATA = Q; //Q
		RRESP = 2'b00;
		RLAST = (VALID&&CtrCarry_D)?1'b1:1'b0;  
		// handshake signals
		ARREADY=1'd0;
		RVALID=(VALID)?1'b1:1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		if(VALID&&CtrCarry_D)begin
			CtrLoad_D=1'b0;
			stop_D=1'b1;//count return 0 signal
		end
		else if(VALID) begin
			CtrLoad_D=1'b1;
			stop_D=1'b0;
		end
		else begin
			CtrLoad_D=1'b0;
			stop_D=1'b0;
		end
		//AR
		CtrLoad_AR=(VALID&&CtrCarry_D)?1'b0:1'b1;
		//Ctrstop_AR=(CtrCarry_AR)?1'b1:1'b0;
		
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b1;
		Ctrstop_CL=1'b0;
    end
    WRITE:  begin
        row_hit=1'b0;
		// For DRAM port-------------
		CSn =1'b0;
		A = {1'b0,AWADDR[11:2]}; //column AWADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=(WVALID) ?1'b0:1'b1;
		D =(WVALID)?WDATA:_D;
		WEn = WSTRB;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=AWADDR;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b1;
		WREADY=1'b1;//need to wait addr so impo?
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
	WRITE_DATA: begin
        //row_hit=1'b0;
		// For DRAM port-------------
		CSn = 1'b0;
		
		//*//
		// A = _A; //column AWADDR
		A_plus=(_new_row_flag_w)?_A_plus:((_CtrLoad_AR)?(_A_plus+32'd4):_A_plus);//*//
		row_hit=((_A_r==A_plus[22:12]))?1'b1:1'b0;//*//
		A ={1'b0,A_plus[11:2]}; //column AWADDR//*//
		A_r=(row_hit)?A_plus[22:12]:_A_r;//*//
		RASn=1'b1;
		CASn=(_CtrLoad_AR&&row_hit)?1'b0:1'b1;//*//
		D =(_CtrLoad_AR&&WVALID)?WDATA:_D;
		WEn = (_CtrLoad_AR&&row_hit)?4'h0:4'hf;
		
		new_row_flag_w=(row_hit)?1'b0:1'b1;//*//
		
		//*//
		new_row_flag=_new_row_flag;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		// WREADY=1'b1;
		WREADY=(_CtrLoad_AR)?1'b1:1'b0;//*//
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=(CtrCarry_CL)?1'b1:1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		//CtrLoad_CL=1'b1;
		CtrLoad_CL=(CtrCarry_CL)?1'b0:1'b1;//*//
		Ctrstop_CL=1'b0;
    end
	WRITE_RESP: begin
		row_hit=1'b0;
        // For DRAM port-------------
		CSn = 1'b0;
		A = _A; //column AWADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=1'b1;
		D =_D;
		WEn = _WEn;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = AWID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b1;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b1;
		Ctrstop_CL=1'b0;
    end
	Row_Hit_check: begin
		row_hit=(((_A_r==ARADDR[22:12])&&ARVALID)||((_A_r==AWADDR[22:12])&&AWVALID))?1'b1:1'b0;
        // For DRAM port-------------
		CSn = 1'b0;
		A = _A; //column AWADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=1'b1;
		D =_D;
		WEn = _WEn;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b1;
		Ctrstop_CL=1'b0;
    end
	Pre_Charge: begin
		row_hit=1'b0;
        // For DRAM port-------------
		CSn = 1'b0;
		A = _A_r; //row adddr
		A_r=_A_r;
		RASn=1'b0;
		CASn=1'b1;
		D =_D;
		WEn = 4'b0000;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b1;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
	Wait_Pre_Charge: begin
		row_hit=1'b0;
        // For DRAM port-------------
		CSn = 1'b0;
		A = _A_r; //column AWADDR
		A_r=_A_r;
		RASn=1'b1;
		CASn=1'b1;
		D =_D;
		WEn = 4'b1111;
		
		//*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;

		// set input output-----------
		len = _len; //ARLEN
		// size = ARSIZE; //ARSIZE
		// burst = ARBURST; //ARBURST
		
		//Read signal-----------------------
		RID = _RID;
		RDATA = _RDATA; 
		RRESP = 2'b00;
		RLAST = 1'b0; 
		// handshake signals
		ARREADY=1'd0;
		RVALID=1'b0;
		//Write signal-----------------------
		BID = _BID;
		BRESP = 2'b00;  
		// handshake signals
		AWREADY=1'b0;
		WREADY=1'b0;
		BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b1;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
    default: begin
        row_hit=1'b0;
        // For DRAM input port-------------
        CSn = 1'b1;//active low
        A = 11'd0; //ARADDR
		A_r=11'd0;
		RASn =1'b1;//active low
		CASn =1'b1;//active low
		D =32'd0;
        WEn = 4'b1111;

        //*//
		new_row_flag=_new_row_flag;
		new_row_flag_w=_new_row_flag_w;
		A_plus=_A_plus;
		
        // set input output-----------
        len = 4'b0; //ARLEN
        // size = 3'b0; //ARSIZE
        // burst = 2'b0; //ARBURST
		//Read signal-----------------------
        RID = 8'b0;
        RDATA = 32'b0; //Q
        RRESP = 2'b0;
        RLAST = 1'b0; 
        // handshake signals
        ARREADY=1'b0;
        RVALID=1'b0;
		//Write signal-----------------------
		BID = 8'd0;
        BRESP = 2'b00;  
        // handshake signals
        AWREADY=1'b0;
        WREADY=1'b0;
        BVALID=1'b0;
		//for counter----------------------
		//DATA
		CtrLoad_D=1'b0;
		//AR
		CtrLoad_AR=1'b0;
		//Ctrstop_AR=1'd0;
		//tRP
		CtrLoad_tRP=1'b0;
		Ctrstop_tRP=1'b0;
		//tRCD
		CtrLoad_tRCD=1'b0;
		Ctrstop_tRCD=1'b0;
		//CL
		CtrLoad_CL=1'b0;
		Ctrstop_CL=1'b0;
    end
    endcase
end



endmodule
