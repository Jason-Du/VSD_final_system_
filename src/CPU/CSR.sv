module CSR( resetn, clk, interrupt, return_intr, WFI,
				ReadRegister_csr, ReadData_csr, ReadDATA_intr,
				WriteRegister_csr, WriteData_csr, RegWrite_csr, WriteData_pc_intr, pc
);
//RegWrite:control
    input resetn, clk, interrupt, return_intr;
	input [11:0] ReadRegister_csr, WriteRegister_csr;
	input [31:0] WriteData_csr, WriteData_pc_intr, pc;
	input RegWrite_csr;
	input [11:0]WFI;
	
	output logic [31:0] ReadData_csr, ReadDATA_intr;
	bit [3:0]addr_read, addr_write;
	logic [31:0] Registers [0:9];
	logic [31:0] last_pc;
	
	logic write_flag;

 //decoder address
	always_comb
	begin			
		case(ReadRegister_csr)
			12'h300:addr_read=4'h0;			
			12'h304:addr_read=4'h1;			
			12'h305:addr_read=4'h2;			
			12'h341:addr_read=4'h3;			
			12'h344:addr_read=4'h4;			
			12'hb00:addr_read=4'h5;			
			12'hb02:addr_read=4'h6;			
			12'hb80:addr_read=4'h7;		
			12'hb82:addr_read=4'h8;		
			default:addr_read=4'h9;
		endcase
		case(WriteRegister_csr)
			12'h300:addr_write=4'h0; //mststus			
			12'h304:addr_write=4'h1; //mie			
			12'h305:addr_write=4'h2; //mtvec			
			12'h341:addr_write=4'h3; //mepc			
			12'h344:addr_write=4'h4; //mip			
			12'hb00:addr_write=4'h5; //cycle			
			12'hb02:addr_write=4'h6;			
			12'hb80:addr_write=4'h7; //finished instruction number		
			12'hb82:addr_write=4'h8;		
			default:addr_write=4'h9;
		endcase
	end	

 //read CSR data	
	always_comb
	begin
		if(return_intr==1'b1)
		begin
			ReadDATA_intr = Registers[3];//mepc
		end
		else if((interrupt==1'b1)&&(Registers[1][11]==1'b1))
		begin
			ReadDATA_intr = Registers[2];//mtvec
		end
		else
		begin
			ReadDATA_intr = 32'hffffffff;
		end
		ReadData_csr = Registers[addr_read];
	end	
	
 //write CSR data	
	always_ff @(posedge clk or negedge resetn)
	begin
		if(!resetn)
		begin
			last_pc<=32'd0;
			write_flag<=1'b0;
			Registers[0]<=32'h00000000;	//?? mststus
			Registers[1]<=32'h00000000; //mie (interrupt enable)
			Registers[2]<=32'h00010000;	//mtvec (fix value)
			Registers[3]<=32'h00000000; //mepc
			Registers[4]<=32'h00000000;	//mip
			Registers[5]<=32'h00000000; //cycle
			Registers[6]<=32'h00000000;	
			Registers[7]<=32'h00000000; //finished instruction number
			Registers[8]<=32'h00000000;	
			Registers[9]<=32'h00000000;
		end
		else
		begin
			last_pc<=pc;
		//csr instruction
			if (RegWrite_csr == 1'b1)
			begin
				case(addr_write)
				4'd0:Registers[addr_write] <= {19'd0,WriteData_csr[12:11],3'd0,WriteData_csr[7],3'd0,WriteData_csr[3],3'd0};
				4'd1:Registers[addr_write] <= {20'd0,WriteData_csr[11],11'd0};
				4'd2:Registers[addr_write] <= {32'h00010000};
				4'd3:Registers[addr_write] <= {WriteData_csr[31:2],2'd0};
				4'd4:Registers[addr_write] <= 32'd0;//{20'd0,WriteData_csr[11],11'd0};
				4'd5:Registers[addr_write] <= WriteData_csr;
				4'd6:Registers[addr_write] <= WriteData_csr;
				4'd7:Registers[addr_write] <= WriteData_csr;
				4'd8:Registers[addr_write] <= WriteData_csr;
				default:Registers[addr_write] <= Registers[addr_write];
				endcase
			end
			else begin
				//save pc before interrupt (WFI->interrupt to do other functino, WFI's pc+4->next main function pc)
				if((WFI==12'h105)&&(Registers[1][11]==1'b1))
				begin
					Registers[3]<=WriteData_pc_intr+32'd4;//mepc
				end
				//interrupt is coming and finish
				else if(return_intr==1'b1)
				begin
					Registers[0][3]<=1'b0;	//mstatus MIE
					Registers[0][7]<=Registers[0][3];	//mstatus MPIE
					Registers[4][11]<=1'b0;	//mip
					write_flag<=1'b0;
					Registers[3]<=Registers[3];
				end
				else if((interrupt==1'b1)&&(Registers[1][11]==1'b1)&&(write_flag==1'b0))
				begin
					Registers[0][3]<=Registers[0][7];	//mstatus MIE
					Registers[0][7]<=1'b1;	//mstatus MPIE
					Registers[4][11]<=1'b1;	//mip
					write_flag<=1'b1;
					Registers[3]<=Registers[3];
				end
				else
				begin
					Registers[0][3]<=Registers[0][3];	//mstatus MIE
					Registers[0][7]<=Registers[0][7];	//mstatus MPIE
					Registers[4][11]<=Registers[4][11];	//mip
					write_flag<=write_flag;
					Registers[3]<=Registers[3];
				end
			end
			

		//count cycle	 
			if(Registers[5]==32'hffffffff)
			begin
				Registers[5]<=32'h00000000;
				Registers[7]<=Registers[7]+32'd1;
			end
			else
			begin
				Registers[5]<=Registers[5]+32'd1;
				Registers[7]<=Registers[7];
			end

		//count finished instruction-------------------------------------------------------------
			
			if(pc!=last_pc)
			begin
				if(Registers[6]==32'hffffffff)
				begin
					Registers[6]<=32'h00000000;
					Registers[8]<=Registers[8]+32'd1;
				end
				else
				begin
					Registers[6]<=Registers[6]+32'd1;
					Registers[8]<=Registers[8];
				end
			end
			else
			begin
				Registers[6]<=Registers[6];
				Registers[8]<=Registers[8];
			end
		end
	end

	
endmodule
