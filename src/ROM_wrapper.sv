//================================================
// Filename:    ROM_wrapper.sv                            
// Version:     2.0 
// This is a read-only memory
//================================================
`include "AXI_define.svh" 
`include "counter_sram.sv"

module ROM_wrapper (
	input clk,
	input resetn,
  /*---------------------READ PART------------------------*/
	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
  input RREADY,
  // For ROM port (top_tb)
	input [31:0] DO,
	output logic CS,
	output logic OE,
  output logic [11:0] A
);
/*---------------------All Parameters---------------------*/	
// For FSM
logic [2:0] Rstate;
logic [2:0] NRstate;
//wire ARHandShake;
wire RHandShake;
logic CS_R;
logic [11:0] AR;
logic [11:0] _AR;

// For AXI port-------------
logic [3:0] _len;
//logic [2:0] _size;
//logic [1:0] _burst;
logic [`AXI_LEN_BITS-1:0] len;
logic [`AXI_SIZE_BITS-1:0] size;
logic [1:0] burst;

// For AXI port-------------
logic [7:0] _RID;
logic [31:0] _RDATA;

/*---------------------counter------------------------*/
logic CtrLoad;
logic CtrCarry;

counter_sram counter_sram(
.rst(resetn), 
.clk(clk),
.stop(!RHandShake),
.load(CtrLoad),
.carry(CtrCarry),
.load_value(len));

/*---------------------READ PART------------------------*/
//parameter Read_RESET = 3'b000;
parameter Read_IDLE = 3'b001;
parameter Read_ADDR = 3'b010;
parameter Read_DATA = 3'b011;
parameter Read_DATA_t = 3'b100;

// assign ARHandShake = ARVALID & ARREADY;
assign RHandShake = RVALID & RREADY;

always_ff@(posedge clk or posedge resetn) begin
    if(resetn) begin
        Rstate <= Read_IDLE;
        _AR <= 12'd0;
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
  Read_IDLE: //1
    if(ARVALID)
      NRstate = Read_DATA_t;
    else
      NRstate = Read_IDLE;
  Read_DATA_t: //4
    if(CtrCarry)
      NRstate = Read_IDLE;
    else
      NRstate = Read_DATA_t;
  default:
    NRstate = Read_IDLE;
  endcase
end

always_comb begin
    CtrLoad = 1'b0;
    case(Rstate)
    Read_IDLE:begin
        if(ARVALID) begin
            // For ROM port-------------
            CS_R = 1'b1;
            AR = ARADDR[13:2]; //ARADDR
            OE = 1'b0; 

            
            // set input output-----------
            len = ARLEN; //ARLEN
            // size = ARSIZE; //ARSIZE
            // burst = ARBURST; //ARBURST
            
            RID = ARID;
            RDATA = _RDATA; //DO
            RRESP = 2'b0;
            RLAST = 1'b0; 
            // handshake signals

                ARREADY=1'b1;
            RVALID=1'b0;
            end
        else begin
            // For ROM port-------------
            CS_R = 1'b0;
            AR = 12'd0; //ARADDR
            OE = 1'b0; 


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
            end
        end
    Read_DATA_t: begin
        // For ROM port-------------
        CS_R = 1'b1;
        AR = _AR + 12'd1; //ARADDR
       
        OE = 1'b1; 

        
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
        
        CtrLoad = 1'b1;
        end
    default: begin
        // For ROM port-------------
        CS_R = 1'b0;
        AR = 12'b0; //ARADDR
        OE = 1'b0; 

        
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
        end
    endcase
end

/*-------------------Select One PART---------------------*/  
always_comb begin
    if(resetn) begin
        CS = 1'b0;
        A= 12'b0;
    end
    else begin
        CS = CS_R;
        A= AR;
    end
end

endmodule
