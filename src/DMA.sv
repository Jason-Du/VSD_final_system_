`timescale 1ns/10ps


module DMA(clk,rst,CPU_DATA,DMA_RVALID,DMA_RLAST,DMA_BVALID,CPU_DATA_LAST,WHandShake_M1,
CPU_ADDR,write,read,ReadData,WriteData,Address,WEB,interrupt,load,ACK,word_count
);
`define  word_size 32     //Word Size
`define  data_length 32	  //Data length should be moved
`define  address_size 32


parameter 		DMA_IDLE=		4'd0,
			DMA_START=		4'd1,
			DMA_LOAD=		4'd2,
			DMA_READ=		4'd3,
			DMA_WRITE=		4'd4,
			DMA_LOAD_W=		4'd5,
			DMA_FINISH=		4'd6,
			DMA_MAPPING=	4'd7,
			GET_S=		4'hA,
			GET_D= 		4'hB,
			GET_C= 		4'hC;
			
parameter BUFFER_NUMBER =3944;

parameter  				word_size= 		32;     //Word Size
parameter  				data_length= 	32;	  //Data length should be moved
parameter  				address_size= 	32;

parameter 				DMA_START_ADDR=		32'hf0000000;			
parameter 				SRC_ADDR=		32'hf0000004;//4
parameter 				DST_ADDR=		32'hf0000008;//8
parameter 				CNT_ADDR=		32'hf0000010;//10

parameter				CNN_ADDR=       32'hdcccffff;// for mapping
parameter				CNN_Mapping_W=  32'hdccc0000;// for mapping
parameter				CNN_Mapping_B=  32'hdccc1111;// for mapping


parameter				CNN_image_ADDR= 32'hd5550000;
parameter				CNN_W_ADDR=     32'hd3330000;
parameter				CNN_Bias_ADDR=  32'hd4440000;

parameter 				ZERO=			32'd0;

input 					clk,rst;
input 					load; 						// CPU signal
input [word_size-1:0]	ReadData;		//read from DRAM
input           DMA_RLAST;
input 					DMA_RVALID;						// read AXI signal
input 					DMA_BVALID;						// write AXI signal
input 					WHandShake_M1;
input [word_size-1:0]	CPU_DATA;		//WDATA_slave
input [word_size-1:0]	CPU_ADDR;		//AWADDR_slave
input 					CPU_DATA_LAST;				//WLAST_slave

output logic 			write;						
output logic 			read;
output logic [word_size-1:0]Address;		//address to AXI

output logic 			[3:0]WEB;							//enable
output 					ACK;							//response for receive start
output logic 			interrupt;					//Data to CPU
output logic [word_size-1:0]WriteData;


logic 			[3:0]	DMA_state;
logic 			[3:0]	DMA_nextstate;




logic [word_size-1:0]	REG_source_addr; 	//source_addr
logic [word_size-1:0]	REG_dst_addr;		//destination addr
logic [word_size-1:0]	        REG_word_count;  //data length( value=30 meams 30-0, length=31)
logic [word_size-1:0]	REG_start_addr;

output logic [word_size-1:0]     word_count;
logic [data_length-1:0]	R_count;
logic [data_length-1:0]	W_count;
logic [3:0]				Address_count;
/*
logic	[word_size-1:0]	BUFFER[BUFFER_NUMBER-1:0];
integer i;
*/
// SRAM signal

logic [word_size-1:0]	temp_address;
logic [word_size-1:0]	temp_address_last;
logic [11:0]			SRAM_address;
logic 					sram_web;
logic [31:0]			sram_out;


//interrupt signal
always_comb 
begin  
	if((DMA_state==DMA_IDLE)&&(REG_start_addr==`address_size'd3))
		interrupt=1'd1;
	else
		interrupt=1'd0;
end

//generate read signal
always_comb 
begin
	if(DMA_state==DMA_READ)
		begin read=1'd1;write=1'd0;WEB=4'b1111;end
	else if((DMA_state==DMA_WRITE))
		begin read=1'd0;write=1'd1;WEB=4'b0000;end
	else if((DMA_state==DMA_FINISH)&&((REG_dst_addr==CNN_image_ADDR)||(REG_dst_addr==CNN_W_ADDR)||(REG_dst_addr==CNN_Bias_ADDR)))
		begin read=1'd0;write=1'd1;WEB=4'b0000;end	
	else
		begin read=1'd0;write=1'd0;WEB=4'b1111;end
end


//for SRAM write signal
logic sram_write;
always_comb 
begin
	if((DMA_state==DMA_WRITE)||(DMA_state==DMA_LOAD_W))
		begin sram_write=1'd1;end
	else
		begin sram_write=1'd0;end
end

//counter calculate
always_ff@(posedge clk or posedge rst)begin
	if(rst)
		begin
			W_count					<=`data_length'b0;
			R_count					<=`data_length'b0;
			Address					<=`address_size'b0;
			Address_count			<=4'd1;
			word_count				<=`data_length'd0;
		end
	else 
		begin
			if(DMA_nextstate==DMA_LOAD) // load Read addr and length
				begin
				W_count<=REG_word_count;
				R_count<=REG_word_count;
				Address<=REG_source_addr;
				word_count<=REG_word_count;
				Address_count			<=4'd1;
				end
			else if((DMA_state==DMA_READ)&&DMA_RVALID)
				begin
				R_count<=R_count-`data_length'd1;
				W_count<=W_count;
				Address_count<=Address_count+4'd1;
				word_count<=word_count;
				
				if(Address_count==4'd0)
					Address<=Address+`address_size'd64;
				else
					Address<=Address;
					
				end
			else if((DMA_state==DMA_LOAD_W)) //load Write addr
				begin
				R_count<=R_count;
				W_count<=W_count;
				Address<=REG_dst_addr;
				Address_count<=Address_count;
				word_count<=word_count;
				end
			else if((DMA_state==DMA_WRITE)&&WHandShake_M1)
				begin
				R_count<=R_count;
				W_count<=W_count-`data_length'd1;
				
				if(DMA_nextstate==DMA_MAPPING)
					begin
						if(REG_dst_addr==CNN_image_ADDR) 		// finish moving data
							begin
							Address<=CNN_ADDR;
							word_count<=`data_length'd0;	
							end
						else if(REG_dst_addr==CNN_W_ADDR)		// finish moving weight
							begin
							Address<=CNN_Mapping_W;
							word_count<=`data_length'd0;
							end
						else if(REG_dst_addr==CNN_Bias_ADDR)	// finish moving bias
							begin
							Address<=CNN_Mapping_B;
							word_count<=`data_length'd0;
							end
						else
							begin
							Address<=Address;
							word_count<=word_count;
							end
					end
				else
					begin
					Address<=Address+`address_size'd4;
					word_count<=word_count;
					end
				Address_count<=Address_count;
				end
			else if(DMA_state==DMA_FINISH)
				begin
				R_count<=R_count;
				W_count<=W_count;
				Address_count<=Address_count;
				end
			else if(DMA_state==DMA_IDLE)
				begin
				R_count<=`data_length'd0;
				W_count<=`data_length'd0;
				Address<=`address_size'd0;
				Address_count<=Address_count;
				end
			else	
				begin
				W_count<=W_count;
				R_count<=R_count;
				Address<=Address;
				Address_count<=Address_count;
				end
		end
end


//cpu write SRC/DST/CNT
always_ff@(posedge clk or posedge rst)begin
	if(rst)
		begin
			REG_source_addr<=`address_size'd0;
			REG_dst_addr<=`address_size'd0;
			REG_word_count<=`data_length'd0;
			REG_start_addr<=`address_size'd0;
		end
	else 
		begin
		
			if((CPU_ADDR==DMA_START_ADDR)&&CPU_DATA_LAST&&(DMA_state==DMA_IDLE))
				begin
					REG_source_addr<=REG_source_addr;
					REG_dst_addr<=REG_dst_addr;
					REG_word_count<=REG_word_count;
					REG_start_addr<=CPU_DATA;
				end
			else if((CPU_ADDR==SRC_ADDR)&&CPU_DATA_LAST&&(DMA_state==DMA_START))
				begin

					REG_source_addr<=CPU_DATA;
					REG_dst_addr<=REG_dst_addr;
					REG_word_count<=REG_word_count;
					
					if(REG_start_addr==`address_size'd2) //REG_start_addr=2，no need to interrupt CPU
						REG_start_addr<=`address_size'd0;
					else								 //need to interrupt CPU
						REG_start_addr<=`address_size'd3;
				end
			else if((CPU_ADDR==DST_ADDR)&&CPU_DATA_LAST&&(DMA_state==GET_S))
				begin

					REG_source_addr<=REG_source_addr;
					REG_dst_addr<=CPU_DATA;
					REG_word_count<=REG_word_count;
					REG_start_addr<=REG_start_addr;
				end
			else if((CPU_ADDR==CNT_ADDR)&&CPU_DATA_LAST&&(DMA_state==GET_D))
				begin

					REG_source_addr<=REG_source_addr;
					REG_dst_addr<=REG_dst_addr;
					REG_word_count<=CPU_DATA;
					REG_start_addr<=REG_start_addr;
				end
			else 
				begin
					REG_source_addr<=REG_source_addr;
					REG_dst_addr<=REG_dst_addr;
					REG_word_count<=REG_word_count;
					REG_start_addr<=REG_start_addr;
				end
	        
		end

end
//DMA_WRITE to LOCAL BUFFER

/////////////////////////////////////////////////////////////////////////////
always_ff@(posedge clk or posedge rst)
begin
if(rst)
temp_address_last<=32'd0;
else
temp_address_last<=temp_address;
end

always_comb
begin
	///control WEB signal
	if((DMA_state==DMA_READ)&&read&&DMA_RVALID)
		begin
			temp_address=REG_word_count-R_count;
			sram_web=1'b0;
		end
	else if((DMA_state==DMA_WRITE)&&write)
		begin
			if(WHandShake_M1)
				temp_address=REG_word_count-W_count+32'd1;
			else
				temp_address=temp_address_last;
			sram_web=1'b1;		
		end
	else
		begin
			temp_address=32'd0;
			sram_web=1'b1;		
		end
	///control WriteData
	if((DMA_state==DMA_WRITE)&&write)
		begin 
			WriteData=sram_out;
		end
	else if((DMA_state==DMA_FINISH)&&write)
		begin 
			WriteData=32'd1;							
		end
	else
		begin
			WriteData=`word_size'd0; 					
		end
end

assign SRAM_address=(temp_address>=32'd3071)?12'd3071:temp_address[11:0];





dma_sram DMA_SRAM(
	.A0   (SRAM_address[0]  ),
    .A1   (SRAM_address[1]  ),
    .A2   (SRAM_address[2]  ),
    .A3   (SRAM_address[3]  ),
    .A4   (SRAM_address[4]  ),
    .A5   (SRAM_address[5]  ),
    .A6   (SRAM_address[6]  ),
    .A7   (SRAM_address[7]  ),
    .A8   (SRAM_address[8]  ),
    .A9   (SRAM_address[9]  ),
    .A10  (SRAM_address[10] ),
    .A11  (SRAM_address[11] ),
	.DO0  (sram_out[0] ),
    .DO1  (sram_out[1] ),
    .DO2  (sram_out[2] ),
    .DO3  (sram_out[3] ),
    .DO4  (sram_out[4] ),
    .DO5  (sram_out[5] ),
    .DO6  (sram_out[6] ),
    .DO7  (sram_out[7] ),
    .DO8  (sram_out[8] ),
    .DO9  (sram_out[9] ),
    .DO10 (sram_out[10]),
    .DO11 (sram_out[11]),
    .DO12 (sram_out[12]),
    .DO13 (sram_out[13]),
    .DO14 (sram_out[14]),
    .DO15 (sram_out[15]),
    .DO16 (sram_out[16]),
    .DO17 (sram_out[17]),
    .DO18 (sram_out[18]),
    .DO19 (sram_out[19]),
    .DO20 (sram_out[20]),
    .DO21 (sram_out[21]),
    .DO22 (sram_out[22]),
    .DO23 (sram_out[23]),
    .DO24 (sram_out[24]),
    .DO25 (sram_out[25]),
    .DO26 (sram_out[26]),
    .DO27 (sram_out[27]),
    .DO28 (sram_out[28]),
    .DO29 (sram_out[29]),
    .DO30 (sram_out[30]),
    .DO31 (sram_out[31]),
	.DI0  (ReadData[0] ),
    .DI1  (ReadData[1] ),
    .DI2  (ReadData[2] ),
    .DI3  (ReadData[3] ),
    .DI4  (ReadData[4] ),
    .DI5  (ReadData[5] ),
    .DI6  (ReadData[6] ),
    .DI7  (ReadData[7] ),
    .DI8  (ReadData[8] ),
    .DI9  (ReadData[9] ),
    .DI10 (ReadData[10]),
    .DI11 (ReadData[11]),
    .DI12 (ReadData[12]),
    .DI13 (ReadData[13]),
    .DI14 (ReadData[14]),
    .DI15 (ReadData[15]),
    .DI16 (ReadData[16]),
    .DI17 (ReadData[17]),
    .DI18 (ReadData[18]),
    .DI19 (ReadData[19]),
    .DI20 (ReadData[20]),
    .DI21 (ReadData[21]),
    .DI22 (ReadData[22]),
    .DI23 (ReadData[23]),
    .DI24 (ReadData[24]),
    .DI25 (ReadData[25]),
    .DI26 (ReadData[26]),
    .DI27 (ReadData[27]),
    .DI28 (ReadData[28]),
    .DI29 (ReadData[29]),
    .DI30 (ReadData[30]),
    .DI31 (ReadData[31]),
	.WEB (sram_web),

	.CK(clk),
    .CS(1'b1),
    .OE(sram_write)

);   




///////////////////////////////////////////////////////////////////////////////
// DMA_FSM
always_ff@(posedge clk or posedge rst)begin
	if(rst)begin
		DMA_state<=DMA_IDLE;
	end
	else begin 
		DMA_state<= DMA_nextstate;
	end
end


always_comb begin
		case (DMA_state)
		DMA_IDLE: 	begin
					if((REG_start_addr==`address_size'd1)||(REG_start_addr==`address_size'd2))
						DMA_nextstate=DMA_START;
					else
						DMA_nextstate=DMA_IDLE;
				end
		DMA_START: 	begin
					if((CPU_ADDR==SRC_ADDR)&&CPU_DATA_LAST)
						DMA_nextstate=GET_S;
					else
						DMA_nextstate=DMA_START;
				end
		GET_S: 	begin
					if((CPU_ADDR==DST_ADDR)&&CPU_DATA_LAST)
						DMA_nextstate=GET_D;
					else
						DMA_nextstate=GET_S;
				end
		GET_D: 	begin
					if((CPU_ADDR==CNT_ADDR)&&CPU_DATA_LAST)
						DMA_nextstate=GET_C;
					else
						DMA_nextstate=GET_D;
				end
			
		GET_C: 	begin // interrupt=1 in the state and get CPU's load signal
						DMA_nextstate=DMA_LOAD;
				end
		DMA_LOAD: 	begin
					if(load)
						DMA_nextstate=DMA_READ;
					else
						DMA_nextstate=DMA_LOAD;
				end
		DMA_READ: 	begin
					if((R_count==ZERO)&&DMA_RLAST)
						DMA_nextstate=DMA_LOAD_W;
					else
						DMA_nextstate=DMA_READ;
				end
        DMA_LOAD_W: 	begin
						DMA_nextstate=DMA_WRITE;
				    end
		DMA_WRITE: 	begin
					if((W_count==ZERO)&&WHandShake_M1)
						DMA_nextstate=DMA_MAPPING;
					else
						DMA_nextstate=DMA_WRITE;
				end
		DMA_MAPPING:begin
						DMA_nextstate=DMA_FINISH;
				end
		DMA_FINISH: 	begin
					if((REG_start_addr==`address_size'd0)||(REG_start_addr==`address_size'd3))
						DMA_nextstate=DMA_IDLE;
					else
						DMA_nextstate=DMA_FINISH;
				end		
			
			default:begin DMA_nextstate =DMA_IDLE ;end
		endcase
	end


endmodule
