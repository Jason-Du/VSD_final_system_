//================================================
// Filename:    CPU_wrapper.sv                            
// Description: There are 3 FSM. Two for read and one for write.       
// This is to transfer signals to match AXI protocol         
// Version:     3.0 
// ------- 20201112 -------
// add caches to this module
// original: CPU <-> CPU wrapper <-> AXI <-> IM and DM
// new: CPU <-> I-cache and D-cache <-> CPU wrapper <-> AXI <-> IM and DM
// ------- 20201115 -------
// AWHandShake and WHandShake together
// ------- 20201116 -------
// use AXI and change len to get data // reduce cycles
// ------- 20201210 -------
// add interrupt signal on wrapper and CPU
//================================================
`include "AXI_define.svh"
`include "def.svh"

`include "./CPU/CPU.sv"
`include "./Cache/L1C_inst.sv"
`include "./Cache/L1C_data.sv"

module CPU_wrapper(
  input ACLK,
  input ARESETn,
  ////////////add interrupt signal///////////////
  input interrupt_cnn,
  input interrupt_sensor,  
  input interrupt_dma,
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
  //READ ADDRESS0
  output logic [`AXI_ID_BITS-1:0] ARID_M0,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
  output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
  output logic [1:0] ARBURST_M0,
  output logic ARVALID_M0,
  input ARREADY_M0,
  //READ DATA0
  input [`AXI_ID_BITS-1:0] RID_M0,
  input [`AXI_DATA_BITS-1:0] RDATA_M0,
  input [1:0] RRESP_M0,
  input RLAST_M0,
  input RVALID_M0,
  output logic RREADY_M0,
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
  output logic RREADY_M1
);
/*-------------------------------------------------------*/
/*---------------------AXI signals-----------------------*/
/*-------------------------------------------------------*/
//For counter
// logic CtrLoad;
// logic CtrCarry;

//For CPU Port
logic IM_Read;
logic [31:0] IM_Addr;
logic [31:0] IM_ReadData;

logic DM_Read;
logic DM_Write;
logic [31:0] DM_Addr;
logic [31:0] DM_WriteData;
logic [31:0] DM_ReadData;

// To let data stable
logic [31:0] IM_ReadData_last;
logic [31:0] DM_ReadData_last;

logic NOP;
// To control NOP
logic NOP_ReadM0;
logic NOP_ReadM0_tmp;
logic NOP_ReadM1;
logic NOP_ReadM1_tmp;
logic NOP_WriteM1;
logic NOP_WriteM1_tmp;

/*---------------------WRITE PART------------------------*/
logic AWHandShake;
logic WHandShake;
logic BHandShake;

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
logic         ARHandShake_M0;
logic         RHandShake_M0;
logic         ARHandShake_M1;
logic         RHandShake_M1;

logic  [2:0]  state_read_M0,
              Nstate_read_M0;

logic  [2:0]  state_read_M1,
              Nstate_read_M1; 
// To let data stable
logic [`AXI_ID_BITS-1:0] ARID_M0_last;
logic [`AXI_LEN_BITS-1:0] ARLEN_M0_last;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0_last;
logic [1:0] ARBURST_M0_last;
logic [31:0]  ARADDR_M0_last; 

logic [`AXI_ID_BITS-1:0] ARID_M1_last;
logic [`AXI_LEN_BITS-1:0] ARLEN_M1_last;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1_last;
logic [1:0] ARBURST_M1_last;
logic [31:0]  ARADDR_M1_last;

assign AWHandShake = AWVALID_M1 & AWREADY_M1;
assign WHandShake = WVALID_M1 & WREADY_M1;
assign BHandShake = BVALID_M1 & BREADY_M1;
assign ARHandShake_M0 = ARVALID_M0 & ARREADY_M0;
assign RHandShake_M0 = RVALID_M0 & RREADY_M0;
assign ARHandShake_M1 = ARVALID_M1 & ARREADY_M1;
assign RHandShake_M1 = RVALID_M1 & RREADY_M1;

//For busy (RVALID & !RREADY) , (BVALID & !BREADY)
    // logic         busy_R_M0; 
    // logic         busy_R_M1;
    // logic         busy_W_M1;

/*-------------------------------------------------------*/
/*---------------------Cache Signals---------------------*/
/*-------------------------------------------------------*/
//CPU and CACHE
logic I_Read;
logic [31:0] I_Addr;
logic [31:0] Icache_ReadData;

logic D_Read;
logic [3:0] D_Write;
logic [31:0] D_Addr;
logic [31:0] Dcache_ReadData;
logic [31:0] D_WriteData;
logic [2:0] D_type;

wire core_req_DM;
wire core_write_DM;

wire Icache_core_wait;
wire Dcache_core_wait;
wire CPU_stall;


//CACHE and AXI (MEM)
wire IM_req_fromC;
wire IM_write_fromC;

wire DM_req_fromC;
wire DM_write_fromC;

wire NOP_M0;
wire NOP_M1;

wire [2:0] DM_type;
wire [3:0] DM_WEB_bar;
wire [3:0] DM_WEB; //active low

//----interruput signal----//
logic [2:0]interrupt_source;
wire interrupt;

//CPU and CACHE
assign core_req_DM = D_Read||(D_Write!=4'hf);
assign core_write_DM = (D_Write!=4'hf);
assign CPU_stall = Icache_core_wait | Dcache_core_wait;

//CACHE and AXI
assign IM_Read = (IM_req_fromC & (!IM_write_fromC));
assign DM_Read = (DM_req_fromC & (!DM_write_fromC));
assign DM_Write = (DM_req_fromC & DM_write_fromC);

assign NOP_M0 = NOP_ReadM0;
assign NOP_M1 = NOP_ReadM1|NOP_WriteM1;

assign DM_WEB_bar = (DM_type==`CACHE_BYTE)? 4'b0001 << DM_Addr[1:0]:
                    (DM_type==`CACHE_HWORD)? 4'b0011 << DM_Addr[1:0]:
                    (DM_type==`CACHE_BYTE_U)? 4'b0001 << DM_Addr[1:0]:
                    (DM_type==`CACHE_HWORD_U)? 4'b0011 << DM_Addr[1:0]: 4'b1111;
                
assign DM_WEB = ~DM_WEB_bar;
//------------------CPU------------------//
CPU CPU1 (.resetn(ARESETn),
          .clk(ACLK),
          .pc(I_Addr),
          .ins(Icache_ReadData),//IM_ReadData
          .I_Read(I_Read),
          
          .D_Addr(D_Addr),
          .D_WrtieData(D_WriteData),
          .D_Write(D_Write),
          .D_Read(D_Read),
          .D_ReadData(Dcache_ReadData),//DM_ReadData
          .D_type(D_type),
          
          .NOP(CPU_stall),//NOP
          .interrupt(interrupt));////////////add interrupt signal///////////////
//-----------------caches------------------//
L1C_inst L1CI(
.clk(ACLK),
.rst(~ARESETn),
// Core to CPU wrapper
.core_addr(I_Addr),
.core_req(I_Read),
.core_write(1'b0), // active high
.core_in(32'h0),
.core_type(`CACHE_WORD),
// Mem to CPU wrapper
.I_out(IM_ReadData),
.I_wait(NOP_M0),
// CPU wrapper to core
.core_out(Icache_ReadData),
.core_wait(Icache_core_wait),
// CPU wrapper to Mem
.I_req(IM_req_fromC),
.I_addr(IM_Addr),
.I_write(IM_write_fromC), // active high
.I_in(),
.I_type());


L1C_data L1CD(
.clk(ACLK),
.rst(~ARESETn),
// Core to CPU wrapper
.core_addr(D_Addr),
.core_req(core_req_DM),
.core_write(core_write_DM), // active high
.core_in(D_WriteData),
.core_type(D_type), //change CPU signal?
// Mem to CPU wrapper
.D_out(DM_ReadData),
.D_wait(NOP_M1),
// CPU wrapper to core
.core_out(Dcache_ReadData),
.core_wait(Dcache_core_wait),
// CPU wrapper to Mem
.D_req(DM_req_fromC),
.D_addr(DM_Addr),
.D_write(DM_write_fromC), // active high
.D_in(DM_WriteData),
.D_type(DM_type),
//----interrupt source----//
.interrupt_source(interrupt_source)
);
//------------------------------------------//
// memory mapping for interrupt (0xc000_0000)(3bit)(2:cnn , 1:sensor , 0:dma)
assign interrupt=interrupt_cnn|interrupt_dma|interrupt_sensor;
always_ff@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) begin
		interrupt_source <= 3'b000;
	end
	else begin
		interrupt_source <= {interrupt_cnn, interrupt_sensor, interrupt_dma};
	end
end
//------------------------------------------//
// To NOP CPU //
always_ff@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
        NOP_ReadM0_tmp <= 1'b0;
        NOP_ReadM1_tmp <= 1'b0;
        NOP_WriteM1_tmp <= 1'b0;
        end
    else begin
        NOP_ReadM0_tmp <= NOP_ReadM0;
        NOP_ReadM1_tmp <= NOP_ReadM1;
        NOP_WriteM1_tmp <= NOP_WriteM1;
        end
end

always_comb begin
    if(RHandShake_M0)begin
        NOP_ReadM0 = 1'b0;
    end
    else if(IM_Read) begin
        NOP_ReadM0 = 1'b1;
    end 
    else begin
        NOP_ReadM0 = NOP_ReadM0_tmp;
    end

    if(RHandShake_M1)begin
        NOP_ReadM1 = 1'b0;
    end
    else if(DM_Read) begin
        NOP_ReadM1 = 1'b1;
    end 
    else begin
        NOP_ReadM1 = NOP_ReadM1_tmp;
    end
    
    if(BHandShake) begin
        NOP_WriteM1 = 1'b0;
    end
    else if(DM_Write) begin
        NOP_WriteM1 = 1'b1;
    end 
    else begin
        NOP_WriteM1 = NOP_WriteM1_tmp;
    end
end
/*---------------------WRITE PART------------------------*/
localparam RESET_WRITE = 3'b000;
localparam IDLE_WRITE = 3'b001;
localparam ADDR_WRITE = 3'b010;
localparam DATA_WRITE = 3'b011;
localparam RESP_WRITE = 3'b100;

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
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
            if(AWHandShake)
                if(WHandShake & WLAST_M1)
                    Nstate_write = RESP_WRITE;
                else
                    Nstate_write = DATA_WRITE;
            else
                Nstate_write = ADDR_WRITE;
        else
            Nstate_write = IDLE_WRITE;
        end
    ADDR_WRITE: begin //2
        if(AWHandShake)
            Nstate_write = DATA_WRITE;
        else
            Nstate_write = ADDR_WRITE;
        end
    DATA_WRITE: begin //3
        if(WHandShake & WLAST_M1)
            Nstate_write = RESP_WRITE;
        else
            Nstate_write = DATA_WRITE;
        end
    RESP_WRITE: begin
        if(BHandShake)
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
    case(state_write)
    RESET_WRITE: begin
        AWID_M1    = 4'b0001;
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
            AWID_M1    = 4'b0001;
            AWADDR_M1  = DM_Addr;
            AWLEN_M1   = 4'b0000; 
            AWSIZE_M1  = 3'b010;  
            AWBURST_M1 = 2'b01;  
            WDATA_M1   = DM_WriteData;  
            WSTRB_M1   = DM_WEB;
            WLAST_M1   = (AWREADY_M1)?1'b1:1'b0;
            //busy_W_M1 = 1'b1;

            AWVALID_M1 = 1'd1;
            WVALID_M1  = (AWREADY_M1)? 1'b1:1'b0;
            // Think : WVALID_M1 could rise 
            BREADY_M1  = 1'd0;
        end
        else begin
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
            BREADY_M1  = 1'd0;
        end
    end
    ADDR_WRITE: begin
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
        AWADDR_M1  = AWADDR_M1_last;
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
        WDATA_M1   = WDATA_M1_last;  
        WSTRB_M1   = WSTRB_M1_last;
        WLAST_M1   = 1'd1;
        //busy_W_M1 = 1'b1;
        
        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd1;
        BREADY_M1  = 1'd0;
    end
    RESP_WRITE: begin
        AWID_M1    = AWID_M1_last;
        AWADDR_M1  = AWADDR_M1_last;
        AWLEN_M1   = AWLEN_M1_last; 
        AWSIZE_M1  = AWSIZE_M1_last;  
        AWBURST_M1 = AWBURST_M1_last;  
        WDATA_M1   = WDATA_M1_last;  
        WSTRB_M1   = WSTRB_M1_last;
        WLAST_M1   = 1'd0;
        //busy_W_M1 = 1'b1;
            
        AWVALID_M1 = 1'd0;
        WVALID_M1  = 1'd0;
        /*if(busy_R_M0|busy_R_M1)
            BREADY_M1  = 1'd0;
        else
            BREADY_M1  = 1'd1;*/
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

/*--------------------- FSM read M0 ------------------------*/
always_ff@(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
        state_read_M0 <= RESET_READ;
        ARADDR_M0_last <= 32'd0;
        ARID_M0_last <= 4'b0000;
        ARLEN_M0_last <= 4'b0000;
        ARSIZE_M0_last <= 3'b000;
        ARBURST_M0_last <= 2'b00; 
        IM_ReadData_last <= 32'b0;  
    end
    else begin
        state_read_M0 <= Nstate_read_M0;
        ARADDR_M0_last <= ARADDR_M0; 
        ARID_M0_last <= ARID_M0;
        ARLEN_M0_last <= ARLEN_M0;
        ARSIZE_M0_last <= ARSIZE_M0;
        ARBURST_M0_last <= ARBURST_M0; 
        IM_ReadData_last <= IM_ReadData;    
    end
end

always_comb begin
    case(state_read_M0)
	RESET_READ: begin
        Nstate_read_M0 = IDLE_READ;
    end
    IDLE_READ: begin
        if(IM_Read)
            if(ARHandShake_M0)
                Nstate_read_M0 = DATA_READ;
            else               
                Nstate_read_M0 = ADDR_READ;
        else
            Nstate_read_M0 = IDLE_READ;
    end
    ADDR_READ: begin
        if(ARHandShake_M0)
            Nstate_read_M0 = DATA_READ;
        else
            Nstate_read_M0 = ADDR_READ;
    end
    DATA_READ: begin
        if(RHandShake_M0 && RLAST_M0)
           Nstate_read_M0 = IDLE_READ;
        else
           Nstate_read_M0 = DATA_READ;
    end
    default: begin
        Nstate_read_M0 = IDLE_READ;
    end
    endcase
end
// Think: Change ARLEN_M0/M1 3'b011, burst=len+1
always_comb begin
    case(state_read_M0)
	RESET_READ: begin
        ARID_M0 = 4'b0000;
        ARADDR_M0 = 32'd0;
        ARLEN_M0 = 4'b0000;
        ARSIZE_M0 = 3'b000;
        ARBURST_M0 = 2'b00;
        IM_ReadData = 32'd0;
        //busy_R_M0 = 1'b0;
        
        ARVALID_M0 = 1'd0;
        RREADY_M0 = 1'd0;
    end
    IDLE_READ: begin
        if(IM_Read) begin
            ARID_M0 = 4'b0000;
            ARADDR_M0 = IM_Addr;
            ARLEN_M0 = 4'b0011; //3+1=4
            ARSIZE_M0 = 3'b010; //32 bits
            ARBURST_M0 = 2'b01; //INCR
            IM_ReadData = IM_ReadData_last;
            //busy_R_M0 = 1'b1;
            
            ARVALID_M0 = 1'd1;
            RREADY_M0 = 1'd0;
        end
        else begin
            ARID_M0     = ARID_M0_last;
            ARADDR_M0   = ARADDR_M0_last;
            ARLEN_M0    = ARLEN_M0_last;
            ARSIZE_M0   = ARSIZE_M0_last;
            ARBURST_M0  = ARBURST_M0_last;
            IM_ReadData   = IM_ReadData_last;
            //busy_R_M0 = 1'b0;

            ARVALID_M0 = 1'd0;
            RREADY_M0 = 1'd0;
        end
    end
    ADDR_READ: begin
        ARID_M0     = ARID_M0_last;
        ARADDR_M0   = ARADDR_M0_last;
        ARLEN_M0    = ARLEN_M0_last;
        ARSIZE_M0   = ARSIZE_M0_last;
        ARBURST_M0  = ARBURST_M0_last;
        IM_ReadData   = IM_ReadData_last;
        //busy_R_M0 = 1'b1;
        ARVALID_M0 = 1'd1;
        RREADY_M0  = 1'd0;
    end
    DATA_READ: begin
        ARID_M0     = ARID_M0_last;
        ARADDR_M0   = ARADDR_M0_last;
        ARLEN_M0    = ARLEN_M0_last;
        ARSIZE_M0   = ARSIZE_M0_last;
        ARBURST_M0  = ARBURST_M0_last;
        IM_ReadData   = (RVALID_M0)?RDATA_M0:IM_ReadData_last;
        //busy_R_M0 = 1'b1;
        
        ARVALID_M0 = 1'd0;
        /*if(busy_R_M1|busy_W_M1)
            RREADY_M0  = 1'd0;
        else
            RREADY_M0  = 1'd1;*/
        RREADY_M0  = 1'd1;
    end
    default: begin
        ARID_M0     = ARID_M0_last;
        ARADDR_M0   = ARADDR_M0_last;
        ARLEN_M0    = ARLEN_M0_last;
        ARSIZE_M0   = ARSIZE_M0_last;
        ARBURST_M0  = ARBURST_M0_last;
        IM_ReadData   = IM_ReadData_last;
        //busy_R_M0 = 1'b0;

        ARVALID_M0 = 1'd0;
        RREADY_M0  = 1'd0;
    end
    endcase
end

/*--------------------- FSM read M1 ------------------------*/
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn) begin
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
        //busy_R_M1 = 1'b0;
        
        ARVALID_M1 = 1'd0;
        RREADY_M1  = 1'd0;
    end
    IDLE_READ: begin
        if (DM_Read) begin
            ARID_M1     = 4'b0000;
            ARADDR_M1   = DM_Addr;
            ARLEN_M1    = 4'b0011;
            ARSIZE_M1   = 3'b010;
            ARBURST_M1  = 2'b01;
            DM_ReadData  = DM_ReadData_last;
            //busy_R_M1 = 1'b1;
            
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
            //busy_R_M1 = 1'b0;
            
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
        //busy_R_M1 = 1'b1;

        ARVALID_M1 = 1'd1;
        RREADY_M1  = 1'd0;
    end
    DATA_READ: begin
        ARID_M1     = ARID_M1_last;
        ARADDR_M1   = ARADDR_M1_last;
        ARLEN_M1    = ARLEN_M1_last;
        ARSIZE_M1   = ARSIZE_M1_last;
        ARBURST_M1  = ARBURST_M1_last;
        DM_ReadData  = (RVALID_M1)?RDATA_M1:DM_ReadData_last;
        //busy_R_M1 = 1'b1;       

        ARVALID_M1 = 1'd0;
        /*if(busy_R_M0|busy_W_M1)
            RREADY_M1  = 1'd0;
        else
            RREADY_M1  = 1'd1;*/
        RREADY_M1  = 1'd1;
    end
    default: begin
        ARID_M1     = ARID_M1_last;
        ARADDR_M1   = ARADDR_M1_last;
        ARLEN_M1    = ARLEN_M1_last;
        ARSIZE_M1   = ARSIZE_M1_last;
        ARBURST_M1  = ARBURST_M1_last;
        DM_ReadData  = DM_ReadData_last;
        //busy_R_M1 = 1'b0;
        
        ARVALID_M1 = 1'd0;
        RREADY_M1  = 1'd0;
    end
    endcase
end
endmodule
