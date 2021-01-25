module EX_MEM_Reg(resetn,clk,
                MemWD_in,
                WriteAddr_in,				
				MemRead_in,
				MemWrite_in,
				selMuxWB_in,
				RegWrite_in,
                MemWD_out,
                WriteAddr_out,
				MemRead_out,
				MemWrite_out,
				selMuxWB_out,
				RegWrite_out,
                flush_in,
                flush_out,
                selSWHB_in,
                selSWHB_out,
                WriteData_in,
                WriteData_out,
                funct3_in,
                funct3_out,
				NOP,
				csr_data,
				csr_addr,
				regwrite_csr,
				out_csr_data,
				out_csr_addr,
				out_regwrite_csr,
				pc_in,
				pc_out
				);
                
	input [31:0]pc_in;
	output logic[31:0]pc_out;			
				
	input resetn,clk;
	input NOP;
    input [2:0] funct3_in;
    output logic [2:0] funct3_out;    
    input [1:0] selSWHB_in;
    output logic [1:0] selSWHB_out;

	input [31:0] MemWD_in;//for MEM
	input [4:0] WriteAddr_in;//for regfile
	input MemRead_in;
	input [3:0] MemWrite_in;
	input selMuxWB_in;
	input RegWrite_in;

	output reg [31:0] MemWD_out;
	output reg [4:0] WriteAddr_out;

	output reg MemRead_out;
	output reg [3:0] MemWrite_out;
	output reg selMuxWB_out;
	output reg RegWrite_out;	
    
	input flush_in;
	output reg flush_out;	
	input [31:0] WriteData_in;
	output reg [31:0] WriteData_out;	
	
	//csr
	input [31:0]csr_data;
	input [11:0]csr_addr;
	input regwrite_csr;
	output logic [31:0]out_csr_data;
	output logic [11:0]out_csr_addr;
	output logic out_regwrite_csr;
	
	always@(posedge clk or negedge resetn)
		if(!resetn)
			begin
            funct3_out<=3'b000;
			MemWD_out<=32'h00000000;
			WriteAddr_out<=5'b00000;
			//control:MEM
			MemRead_out<=1'b0;
			MemWrite_out<=4'b1111;
			//control:WB
			selMuxWB_out<=1'b0;
			RegWrite_out<=1'b0;	
            flush_out<=1'b0;
            selSWHB_out<=2'b0;
            WriteData_out<=32'h0000_0000;
			//csr
			out_csr_data<=32'h00000000;
			out_csr_addr<=12'h000;
			out_regwrite_csr<=1'b0;
			pc_out<=32'd0;
			end
		else if(NOP)
			begin
            funct3_out<=funct3_out;
			MemWD_out<=MemWD_out;
			WriteAddr_out<=WriteAddr_out;
			//control:MEM
			MemRead_out<=MemRead_out;
			MemWrite_out<=MemWrite_out;
			//control:WB
			selMuxWB_out<=selMuxWB_out;
			RegWrite_out<=RegWrite_out;		
            flush_out<=flush_out;
            selSWHB_out<=selSWHB_out;
            WriteData_out<=WriteData_out;
			//csr
			out_csr_data<=out_csr_data;
			out_csr_addr<=out_csr_addr;
			out_regwrite_csr<=out_regwrite_csr;
			pc_out<=pc_out;
			end			
		else
			begin
            funct3_out<=funct3_in;
			MemWD_out<=MemWD_in;
			WriteAddr_out<=WriteAddr_in;
			//control:MEM
			MemRead_out<=MemRead_in;
			MemWrite_out<=MemWrite_in;
			//control:WB
			selMuxWB_out<=selMuxWB_in;
			RegWrite_out<=RegWrite_in;		
            flush_out<=flush_in;
            selSWHB_out<=selSWHB_in;
            WriteData_out<=WriteData_in;
			//csr
			out_csr_data<=csr_data;
			out_csr_addr<=csr_addr;
			out_regwrite_csr<=regwrite_csr;
			pc_out<=pc_in;
			end
	endmodule
	
