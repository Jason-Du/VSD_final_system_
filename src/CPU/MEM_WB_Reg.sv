module MEM_WB_Reg(resetn,clk,
                //input
                WriteData_in,
                WriteAddr_in,
				selMuxWB_in,
				RegWrite_in,
                //output
                WriteData_out,
                WriteAddr_out,
				selMuxWB_out,
				RegWrite_out,
                //DataMEM
                MemRead_in,
                MemRead_out,
                MemRD_in,
                MemRD_out,
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
    input MemRead_in;
    output logic MemRead_out;
    input [31:0] MemRD_in;
    output logic [31:0] MemRD_out;

	input [31:0] WriteData_in;
	input [4:0] WriteAddr_in;
	input selMuxWB_in;
	input RegWrite_in;

	output reg [31:0] WriteData_out;
	output reg [4:0] WriteAddr_out;
	output reg selMuxWB_out;
	output reg RegWrite_out;

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
		WriteData_out<=32'h00000000;
		WriteAddr_out<=5'b00000;
		//control:WB
		selMuxWB_out<=1'b0;
		RegWrite_out<=1'b0;	
        MemRead_out<=1'b0;
        MemRD_out<=32'd0;
		//csr
		out_csr_data<=32'h00000000;
		out_csr_addr<=12'h000;
		out_regwrite_csr<=1'b0;
		pc_out<=32'd0;
		end	
	else if(NOP)
		begin
        funct3_out<=funct3_out;
		WriteData_out<=WriteData_out;
		WriteAddr_out<=WriteAddr_out;
		//control:WB
		selMuxWB_out<=selMuxWB_out;
		RegWrite_out<=RegWrite_out;	
        MemRead_out<=MemRead_out;
        MemRD_out<=MemRD_out;
		//csr
		out_csr_data<=out_csr_data;
		out_csr_addr<=out_csr_addr;
		out_regwrite_csr<=out_regwrite_csr;
		pc_out<=pc_out;
		end
	else
		begin
        funct3_out<=funct3_in;
		WriteData_out<=WriteData_in;
		WriteAddr_out<=WriteAddr_in;
		//control:WB
		selMuxWB_out<=selMuxWB_in;
		RegWrite_out<=RegWrite_in;	
        MemRead_out<=MemRead_in;	
        MemRD_out<=MemRD_in;
		//csr
		out_csr_data<=csr_data;
		out_csr_addr<=csr_addr;
		out_regwrite_csr<=regwrite_csr;
		pc_out<=pc_in;
		end	
	endmodule
