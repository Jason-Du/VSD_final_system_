`timescale 1ns / 10ps
`include "AXI_define.svh"
`include "DMA.sv"
module DMA_wrapper(
  input ACLK,
  input ARESETn,
  output ACK, //response
  input load,						// CPU signal
  output interrupt,
  /*---------------------MASTER-------------------------------*/	
  /*---------------------WRITE PART------------------------*/
  //WRITE ADDRESS
  output logic [`AXI_ID_BITS-1:0] AWID_M1,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
  output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
  output logic [1:0] AWBURST_M1,
  output logic AWVALID_M1,
  input AWREADY_M1,
  //WRITE DATA
  output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
  output logic WLAST_M1,
  output logic WVALID_M1,
  input WREADY_M1,
  //WRITE RESPONSE
  input [`AXI_ID_BITS-1:0] BID_M1,
  input [1:0] BRESP_M1,
  input BVALID_M1,
  output logic BREADY_M1,
  /*---------------------READ PART------------------------*/
  //READ ADDRESS1
  output logic [`AXI_ID_BITS-1:0] ARID_M1,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
  output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
  output logic [1:0] ARBURST_M1,
  output logic ARVALID_M1,
  input ARREADY_M1,
  //READ DATA1
  input [`AXI_ID_BITS-1:0] RID_M1,
  input [`AXI_DATA_BITS-1:0] RDATA_M1,
  input [1:0] RRESP_M1,
  input RLAST_M1,
  input RVALID_M1,
  output logic RREADY_M1,
  
  
  /*---------------------SLAVE--------------------------------*/	
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
	input BREADY

);


/*---------------------DMA  PORT------------------------*/
logic DM_Read;
logic DM_Write;
logic [3:0]DM_WEB;
logic [31:0] DM_Addr;
logic [31:0] DM_WriteData;
logic [31:0] DM_ReadData;
logic [31:0] DM_ReadData_last;
logic [31:0]DM_write_len;
/*---------------------WRITE PART------------------------*/
logic AWHandShake_M1;
logic WHandShake_M1;
logic BHandShake_M1;

logic [2:0] state_write;
logic [2:0] Nstate_write;

// To let data stable
logic [`AXI_ID_BITS-1:0] AWID_M1_last;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1_last;
logic [`AXI_LEN_BITS-1:0] AWLEN_M1_last;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1_last;
logic [1:0] AWBURST_M1_last;

logic [`AXI_DATA_BITS-1:0] WDATA_M1_last;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1_last;
logic WLAST_M1_last;
/*--------------------- READ PART ------------------------*/

logic         ARHandShake_M1;
logic         RHandShake_M1;

logic  [2:0]  state_read_M1,
              Nstate_read_M1; 
logic [`AXI_ID_BITS-1:0] ARID_M1_last;
logic [`AXI_LEN_BITS-1:0] ARLEN_M1_last;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_last;
logic [1:0] ARBURST_M1_last;
logic [31:0]  ARADDR_M1_last;

assign AWHandShake_M1 = AWVALID_M1 & AWREADY_M1;
assign WHandShake_M1 = WVALID_M1 & WREADY_M1;
assign BHandShake_M1 = BVALID_M1 & BREADY_M1;
assign ARHandShake_M1 = ARVALID_M1 & ARREADY_M1;
assign RHandShake_M1 = RVALID_M1 & RREADY_M1;




/*---------------------SLAVE  parameter---------------------*/	
// For SRAM port
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

logic CS_W;
logic [31:0] AW;
//---------------------------
// To Store Data:Write-------
// For SRAM port-------------
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
logic [31:0] _AW;



// For wrapper
logic [`AXI_LEN_BITS-1:0] len; // 0 == (len=1)
logic [`AXI_SIZE_BITS-1:0] size; // 0b010 == (Bytes in transfer=4)
logic [1:0] burst;// = INCR = 0b01


logic busy_W; 


/*---------------------WRITE LENGTH counter--------------*/

logic stay;
logic carry;
logic counter_active;
logic [3:0] count;




logic [11:0] DM_write_len_new;
logic [3:0] DM_write_len_count;
logic len_flag;
//W len
always_ff @(posedge ACLK or posedge ARESETn)
begin
    if(ARESETn)
        begin
		DM_write_len_new <= 12'd0;
    len_flag<=1'd0;
		end
    else
		if(DM_Write==1'd0)
			begin
      DM_write_len_new <=  DM_write_len[11:0];		
      len_flag<=1'd0;
      end
		else
			begin
				if(AWVALID_M1&&(!len_flag)) //only load len for once.				
					begin 
          DM_write_len_new <= DM_write_len[11:0];		
          len_flag<=1'd1;
          end   
				else if(BHandShake_M1&&(DM_write_len_new>12'd15))	
          begin
					DM_write_len_new <= DM_write_len_new-12'd16;
          len_flag<=1'd1;					
          end
				else
          begin
					DM_write_len_new <= DM_write_len_new;
          len_flag<=1'd1;
          end
			end
end
logic [11:0] DM_read_len_new;
logic [3:0] DM_read_len_count;
logic len_flag_read;
//R len
always_ff @(posedge ACLK or posedge ARESETn)
begin
    if(ARESETn)
        begin
		DM_read_len_new <= 12'd0;
    len_flag_read<=1'd0;
		end
    else
		if(DM_Read==1'd0)
			begin
      DM_read_len_new <=  DM_write_len[11:0];		
      len_flag_read<=1'd0;
      end
		else
			begin
				if(ARVALID_M1&&(!len_flag_read)) //only load len for once.				
					begin 
          DM_read_len_new <= DM_write_len[11:0];		
          len_flag_read<=1'd1;
          end   
				else if(RHandShake_M1&&RLAST_M1&&(DM_read_len_new>12'd15))	
          begin
					DM_read_len_new <= DM_read_len_new-12'd16;
          len_flag_read<=1'd1;					
          end
				else
          begin
					DM_read_len_new <= DM_read_len_new;
          len_flag_read<=1'd1;
          end
			end
end

assign DM_read_len_count=(DM_read_len_new>12'd15)?4'd15:DM_read_len_new[3:0];
assign DM_write_len_count=(DM_write_len_new>12'd15)?4'd15:DM_write_len_new[3:0];

assign carry = (count==DM_write_len_count);

always_ff @(posedge ACLK or posedge ARESETn)
begin
    if(ARESETn)
        count <= 4'd0;
    else
		if(counter_active)
            count <= count + 4'd1;
        else if(stay)
            count <= count;
		else
			count <= 4'd0;
end

/*---------------------WRITE PART------------------------*/
localparam RESET_WRITE = 3'b000;
localparam IDLE_WRITE = 3'b001;
localparam ADDR_WRITE = 3'b010;
localparam DATA_WRITE = 3'b011;
localparam RESP_WRITE = 3'b100;

always_ff @(posedge ACLK or posedge ARESETn) begin
    if(ARESETn) begin
        state_write <= RESET_WRITE;
        AWID_M1_last <= 4'b0001;
        AWLEN_M1_last <= 4'b0000;
        AWSIZE_M1_last <= 3'b000;
        AWBURST_M1_last <= 2'b00;

        AWADDR_M1_last <= 32'd0;
        WDATA_M1_last <= 32'd0;  
        WSTRB_M1_last <= 4'd0;
        end
    else begin
        state_write <= Nstate_write;
        AWID_M1_last <= AWID_M1;
        AWLEN_M1_last <= AWLEN_M1;
        AWSIZE_M1_last <= AWSIZE_M1;
        AWBURST_M1_last <= AWBURST_M1;

        AWADDR_M1_last <= AWADDR_M1;
        WDATA_M1_last <= WDATA_M1;  
        WSTRB_M1_last <= WSTRB_M1;
        end
end


always_comb begin
    case(state_write)
	RESET_WRITE: begin //0
        Nstate_write = IDLE_WRITE;
        end
    IDLE_WRITE: begin //1
        if(DM_Write)
            if(AWHandShake_M1)
                if(WHandShake_M1 & WLAST_M1)
                    Nstate_write = RESP_WRITE;
                else
                    Nstate_write = DATA_WRITE;
            else
                Nstate_write = ADDR_WRITE;
        else
            Nstate_write = IDLE_WRITE;
        end
    ADDR_WRITE: begin //2
        if(AWHandShake_M1)
            Nstate_write = DATA_WRITE;
        else
            Nstate_write = ADDR_WRITE;
        end
    DATA_WRITE: begin //3
        if(WHandShake_M1 & WLAST_M1)
            Nstate_write = RESP_WRITE;
        else
            Nstate_write = DATA_WRITE;
        end
    RESP_WRITE: begin
        if(BHandShake_M1)
           Nstate_write = IDLE_WRITE;
        else
           Nstate_write = RESP_WRITE;
        end
    default: begin
        Nstate_write = IDLE_WRITE;
        end
    endcase
end

always_comb begin
	stay = 1'b0;
	counter_active = 1'b0;
    case(state_write)
    RESET_WRITE: begin
        AWID_M1    = 4'b0010;
        AWADDR_M1  = 32'd0;
        AWLEN_M1   = 4'b0000;
        AWSIZE_M1  = 3'b000;
        AWBURST_M1 = 2'b00;
        WDATA_M1   = 32'd0;
        WSTRB_M1   = 4'b0000;
        WLAST_M1   = 1'd0; 
        
        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd0;
        BREADY_M1  = 1'd0;            
        end
    IDLE_WRITE: begin
        if(DM_Write) begin
            AWID_M1    = 4'b0010;
            AWADDR_M1  = DM_Addr;
            AWLEN_M1   = DM_write_len_count; //dma_length
            AWSIZE_M1  = 3'b010;  
            AWBURST_M1 = 2'b01;  
            WDATA_M1   = DM_WriteData;  
            WSTRB_M1   = DM_WEB;
            WLAST_M1   = (AWREADY_M1&&carry)?1'b1:1'b0;
            //busy_W_M1 = 1'b1;

            AWVALID_M1 = 1'd1;
            WVALID_M1  = (AWREADY_M1)? 1'b1:1'b0;
            // Think : WVALID_M1 could rise 
            BREADY_M1  = 1'd0;
			counter_active = WHandShake_M1;
        end
        else begin
            AWID_M1    = AWID_M1_last;
            AWADDR_M1  = AWADDR_M1_last;
            AWLEN_M1   = AWLEN_M1_last; 
            AWSIZE_M1  = AWSIZE_M1_last;  
            AWBURST_M1 = AWBURST_M1_last;  
            WDATA_M1   = WDATA_M1_last;  
            WSTRB_M1   = DM_WEB;
            WLAST_M1   = 1'd0;
            //busy_W_M1 = 1'b0;
            
            AWVALID_M1 = 1'd0;
            WVALID_M1  = 1'd0;
            BREADY_M1  = 1'd0;
        end
    end
    ADDR_WRITE: begin//2
        AWID_M1    = AWID_M1_last;
        AWADDR_M1  = AWADDR_M1_last;
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
        WDATA_M1   = WDATA_M1_last;  
        WSTRB_M1   = WSTRB_M1_last;
        WLAST_M1   = 1'd0;
        //busy_W_M1 = 1'b1;
    
        AWVALID_M1 = 1'd1;
        WVALID_M1  = 1'd0;
        BREADY_M1  = 1'd0;
    end
    DATA_WRITE: begin //3
        AWID_M1    = AWID_M1_last;
       
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
		AWADDR_M1  = AWADDR_M1_last;
		if(DM_Write)
			begin
			WDATA_M1   = DM_WriteData;  
			end
		else
			begin
			WDATA_M1=WDATA_M1_last;
			
			end
        WSTRB_M1   = DM_WEB;
		
        WLAST_M1   = (carry)? 1'b1:1'b0;
        //busy_W_M1 = 1'b1;
        
        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd1;
        BREADY_M1  = 1'd0;
		stay = 1'b1;
		counter_active = WHandShake_M1;
    end
    RESP_WRITE: begin
        AWID_M1    = AWID_M1_last;
        AWADDR_M1  = AWADDR_M1_last;
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
        WDATA_M1   = WDATA_M1_last;  
        WSTRB_M1   = 4'hf; //for AWLEN>0. respon shuold turn because slave may stuck at READ_DATA state
        WLAST_M1   = 1'd0;
        //busy_W_M1 = 1'b1;
            
        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd0;

        BREADY_M1  = 1'd1;
    end
    default: begin
        AWID_M1    = AWID_M1_last;
        AWADDR_M1  = AWADDR_M1_last;
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
        WDATA_M1   = WDATA_M1_last;  
        WSTRB_M1   = WSTRB_M1_last;
        WLAST_M1   = 1'd0;
        //busy_W_M1 = 1'b0;

        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd0;
        BREADY_M1  = 1'd1; 
    end
    endcase
end

/*--------------------- READ PART ------------------------*/
localparam RESET_READ = 3'b000;
localparam IDLE_READ = 3'b001;
localparam ADDR_READ = 3'b010;
localparam DATA_READ = 3'b011;
/*--------------------- FSM read M1 ------------------------*/
always_ff@(posedge ACLK or posedge ARESETn)begin
    if(ARESETn) begin
        state_read_M1 <= RESET_READ;
        ARADDR_M1_last <= 32'd0;
        ARID_M1_last <= 4'b0000;
        ARLEN_M1_last <= 4'b0000;
        ARSIZE_M1_last <= 3'b000;
        ARBURST_M1_last <= 2'b00;  
        DM_ReadData_last <= 32'd0;
    end
    else begin
        state_read_M1 <= Nstate_read_M1;
        ARADDR_M1_last <= ARADDR_M1; 
        ARID_M1_last <= ARID_M1;
        ARLEN_M1_last <= ARLEN_M1;
        ARSIZE_M1_last <= ARSIZE_M1;
        ARBURST_M1_last <= ARBURST_M1; 
        DM_ReadData_last <= DM_ReadData;
    end 
end

always_comb begin
    case(state_read_M1)
	RESET_READ: begin
        Nstate_read_M1 = IDLE_READ;
    end
    IDLE_READ: begin
        if(DM_Read)
            if(ARHandShake_M1)
                Nstate_read_M1 = DATA_READ;
            else               
                Nstate_read_M1 = ADDR_READ;
        else
            Nstate_read_M1 = IDLE_READ;
    end
    ADDR_READ: begin
        if(ARHandShake_M1)
            Nstate_read_M1 = DATA_READ;
        else
            Nstate_read_M1 = ADDR_READ;
    end
    DATA_READ: begin
        if(RHandShake_M1 && RLAST_M1)
            Nstate_read_M1 = IDLE_READ;
        else
            Nstate_read_M1 = DATA_READ;
    end
    default: begin
        Nstate_read_M1 = IDLE_READ;
    end
    endcase
end

always_comb begin
    case(state_read_M1)
	RESET_READ: begin
        ARID_M1     = 4'b0000;
        ARADDR_M1   = 32'd0;
        ARLEN_M1    = 4'b0000;
        ARSIZE_M1   = 3'b000;
        ARBURST_M1  = 2'b00;
        DM_ReadData  = 32'd0;
        
        ARVALID_M1 = 1'd0;
        RREADY_M1  = 1'd0;
    end
    IDLE_READ: begin
        if (DM_Read) begin
            ARID_M1     = 4'b0000;
            ARADDR_M1   = DM_Addr;
            ARLEN_M1    = DM_read_len_count;
            ARSIZE_M1   = 3'b010;
            ARBURST_M1  = 2'b01;
            DM_ReadData  = DM_ReadData_last;
            
            ARVALID_M1 = 1'd1;
            RREADY_M1  = 1'd0;
            end
        else begin
            ARID_M1     = ARID_M1_last;
            ARADDR_M1   = ARADDR_M1_last;
            ARLEN_M1    = ARLEN_M1_last;
            ARSIZE_M1   = ARSIZE_M1_last;
            ARBURST_M1  = ARBURST_M1_last;
            DM_ReadData  = DM_ReadData_last;
            
            ARVALID_M1 = 1'd0;
            RREADY_M1  = 1'd0;
            end
    end
    ADDR_READ: begin
        ARID_M1     = ARID_M1_last;
        ARADDR_M1   = ARADDR_M1_last;
        ARLEN_M1    = ARLEN_M1_last;
        ARSIZE_M1   = ARSIZE_M1_last;
        ARBURST_M1  = ARBURST_M1_last;
        DM_ReadData  = DM_ReadData_last;

        ARVALID_M1 = 1'd1;
        RREADY_M1  = 1'd0;
    end
    DATA_READ: begin
        ARID_M1     = ARID_M1_last;
        ARADDR_M1   = ARADDR_M1_last;
        ARLEN_M1    = ARLEN_M1_last;
        ARSIZE_M1   = ARSIZE_M1_last;
        ARBURST_M1  = ARBURST_M1_last;
        DM_ReadData  = RDATA_M1;
        ARVALID_M1 = 1'd0;
        RREADY_M1  = 1'd1;
    end
    default: begin
        ARID_M1     = ARID_M1_last;
        ARADDR_M1   = ARADDR_M1_last;
        ARLEN_M1    = ARLEN_M1_last;
        ARSIZE_M1   = ARSIZE_M1_last;
        ARBURST_M1  = ARBURST_M1_last;
        DM_ReadData  = DM_ReadData_last;

        
        ARVALID_M1 = 1'd0;
        RREADY_M1  = 1'd0;
    end
    endcase
end



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

always_ff@(posedge ACLK or posedge ARESETn) begin
    if(ARESETn) begin
        Wstate <= Write_RESET;
        // For SRAM port-------------
        _AW <= 32'b0;
        _DI <= 32'b0;
        _WEB <= 4'b1111;
        _BID <= 8'b0;
        end
    else begin
        Wstate <= NWstate;
        // For SRAM port-------------
        _AW <= AW;
        _DI <= DI;
        _WEB <= WEB;
        _BID <= BID;
        end
end

always_comb begin        
    case(Wstate)
    Write_RESET: 
        NWstate = Write_IDLE;        
    Write_IDLE:
        if(AWVALID) // =AWHandShake

	    if(WHandShake & WLAST)
                NWstate = Write_RESP;
            else
                NWstate = Write_DATA;
        else
            NWstate = Write_IDLE;
 
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
    Write_RESET: begin
        // For SRAM port-------------
        CS_W = 1'b0;
        AW = 32'b0;
        WEB = 4'b1111;
        DI = 32'b0;      
        BID = 8'b0;
        BRESP = 2'b00;  
        // handshake signals
        AWREADY=1'b0;
        WREADY=1'b0;
        BVALID=1'b0;
        busy_W=1'b0;
    end       
    Write_IDLE: begin
        if(AWVALID) begin
            // For SRAM port-------------
            CS_W = 1'b1;
            AW = AWADDR;
            WEB = (WVALID)? WSTRB:4'b1111;
            DI = (WVALID)? WDATA:32'b0;
            BID = AWID;
            BRESP = 2'b00;  
            // handshake signals

	    AWREADY=1'b1; 
            WREADY=1'b1;
		             
            // WREADY=1'b0;
            // Think : WVALID_M1 could rise 
            BVALID=1'b0;
            busy_W=1'b1;
            end     
        else begin
        begin
            // For SRAM port-------------
            CS_W = 1'b0;
            AW = 32'b0;
            WEB = 4'b1111;
            DI = 32'b0;
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
        WEB = WSTRB;
        DI = WDATA;
        BID = _BID;
        BRESP = 2'b00;  
        // handshake signals

        AWREADY=1'b1;  
        WREADY=1'b1;

        // WREADY=1'b0;
        BVALID=1'b0;
        busy_W=1'b0;    
    end   
    Write_DATA: begin
        // For SRAM port-------------
		
        CS_W = 1'b1;
        AW = _AW;
        WEB = WSTRB;
        DI = WDATA;
        
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
        WEB = _WEB;
        DI = _DI;
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
        WEB = _WEB;
        DI = _DI;
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











DMA DMA(
		.clk(ACLK),
		.rst(ARESETn),
		.WHandShake_M1(WHandShake_M1),
		// DMA <-> CPU 
		.interrupt(interrupt),
		.word_count(DM_write_len),
		.load(load),
		// MASTER PORT
		.write(DM_Write),
		.read(DM_Read),
		.ReadData(DM_ReadData),
		.WriteData(DM_WriteData),
		.Address(DM_Addr),
		.WEB(DM_WEB),
		// SLAVE PORT
		.CPU_DATA(DI),
    .DMA_RLAST(RLAST_M1),
		.DMA_RVALID(RVALID_M1),
		.DMA_BVALID(BVALID_M1), // input
		.CPU_DATA_LAST(BHandShake),// handshake BVALID
		.CPU_ADDR(AW),
		// response port
		.ACK(ACK)
		);

endmodule
