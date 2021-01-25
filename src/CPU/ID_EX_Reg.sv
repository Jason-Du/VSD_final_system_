//================================================
// ------- 20210106 ------
// change EX_ins 32bits to EX_rs1 5bits
//================================================

module ID_EX_Reg(resetn,clk,flush,
				//signal:
				RegRd_in,
				imm_in,
				pc_in,
				ReadData1_in,ReadData2_in,
				pcbra_in,
				
				//add csr_signal and write back data and rs1 info using on alu
				rs1_in,		
				rs1_out,
				csr_data,
				csr_addr,
				regwrite_csr,
				out_csr_data,
				out_csr_addr,
				out_regwrite_csr,
				
				//control:
				jalr_in,
				MemRead_in,
				MemWrite_in,
				selMuxWB_in,
				RegWrite_in,
				bra_in,
				jal_in,
				//signal:
				RegRd_out,
				imm_out,
				pc_out,
				ReadData1_out,ReadData2_out,
				pcbra_out,			

				//control:
				jalr_out,
				MemRead_out,
				MemWrite_out,
				selMuxWB_out,
				RegWrite_out,
				bra_out,
				jal_out,
				control_alu_in,
				control_alu_out,
				MemWD_in,
				MemWD_out,
				selMuxNop,
                selMuxExe_in,
                selMuxExe_out,                
                selSWHB_in,
                selSWHB_out,
				NOP,
                funct3_in,
                funct3_out

				);
    input [2:0] funct3_in;
    output logic [2:0] funct3_out;
    
	input NOP;
    input [1:0] selSWHB_in;
    output logic [1:0] selSWHB_out;
	input resetn,clk,flush,selMuxNop;
//signal:
	input [4:0] RegRd_in; 
	input [31:0] imm_in;	
	input [31:0] pc_in;
	input [4:0] rs1_in;
	input [31:0] ReadData1_in,ReadData2_in;
	input [31:0] pcbra_in;
	input [31:0] MemWD_in;
//control:
	input jalr_in;
	input MemRead_in;
	input [3:0] MemWrite_in;
	input selMuxWB_in;
	input RegWrite_in;
	input bra_in;
	input jal_in;
	input [4:0]control_alu_in;
//signal:	
	output logic [4:0] RegRd_out;
	output logic [31:0] imm_out;	
	output logic [31:0] pc_out;
	output logic [4:0] rs1_out;
	output logic [31:0] ReadData1_out,ReadData2_out;
	output logic [31:0] pcbra_out;
	output logic [31:0] MemWD_out;

//control:
	output logic jalr_out;
	output logic MemRead_out;
	output logic [3:0] MemWrite_out;
	output logic selMuxWB_out;
	output logic RegWrite_out;
	output logic bra_out;
	output logic jal_out;
	output logic[4:0]control_alu_out;
    
    logic [3:0] MemWrite_temp;
    input [1:0] selMuxExe_in;
    output logic [1:0] selMuxExe_out;    

//csr:
	input [31:0]csr_data;
	input [11:0]csr_addr;
	input regwrite_csr;
	output logic [31:0]out_csr_data;
	output logic [11:0]out_csr_addr;
	output logic out_regwrite_csr;

	wire jalr_temp=(!flush)&(!selMuxNop)&jalr_in;
	wire jal_temp=(!flush)&(!selMuxNop)&jal_in;
	wire bra_temp=(!flush)&(!selMuxNop)&bra_in;
	wire MemRead_temp=(!flush)&(!selMuxNop)&MemRead_in;
	wire RegWrite_temp=(!flush)&(!selMuxNop)&RegWrite_in;
	
	always_comb begin
        if((!flush)&(!selMuxNop))
            MemWrite_temp = MemWrite_in;
        else
            MemWrite_temp = 4'b1111;
    end
    
	always@(posedge clk or negedge resetn)
	if(!resetn)
		begin
		funct3_out<=3'b000;
		pc_out<=32'h00000000;
		ReadData1_out<=32'h00000000;
		ReadData2_out<=32'h00000000;
		imm_out<=32'h00000000;
		RegRd_out<=5'b00000;
		//csr
		rs1_out<=5'h0;
		out_csr_data<=32'h00000000;
		out_csr_addr<=12'h000;
		out_regwrite_csr<=1'b0;
		//control:EX
		jalr_out<=1'b0;
		bra_out<=1'b0;
		jal_out<=1'b0;
		//control:MEM
		MemRead_out<=1'b0;
		MemWrite_out<=4'b1111;
		//control:WB
		selMuxWB_out<=1'b0;
		RegWrite_out<=1'b0;
		//for forward
		pcbra_out<=32'h00000000;
		control_alu_out<=5'b00000;	
		MemWD_out<=32'h00000000;
        selSWHB_out<=2'b0;
        selMuxExe_out<=2'b00;
		end 
	else if(NOP) begin
        funct3_out<=funct3_out;
		pc_out<=pc_out;
		ReadData1_out<=ReadData1_out;
		ReadData2_out<=ReadData2_out;
		imm_out<=imm_out;
		RegRd_out<=RegRd_out;
		//csr:
		rs1_out<=rs1_out;
		out_csr_data<=out_csr_data;
		out_csr_addr<=out_csr_addr;
		out_regwrite_csr<=out_regwrite_csr;
		//control:EX
		bra_out<=bra_out;
		jal_out<=jal_out;
		jalr_out<=jalr_out;
        control_alu_out<=control_alu_out;
        selMuxExe_out<=selMuxExe_out;	
		//control:MEM
		MemRead_out<=MemRead_out;
		MemWrite_out<=MemWrite_out;
        selSWHB_out<=selSWHB_out;
		//control:WB
		selMuxWB_out<=selMuxWB_out;
		RegWrite_out<=RegWrite_out;
		MemWD_out<=MemWD_out;        

		pcbra_out<=pcbra_out;	
	end
    else begin
		funct3_out<=funct3_in;
		pc_out<=pc_in;
		ReadData1_out<=ReadData1_in;
		ReadData2_out<=ReadData2_in;
		imm_out<=imm_in;
		RegRd_out<=RegRd_in;
		//csr:
		rs1_out<=rs1_in;
		out_csr_data<=csr_data;
		out_csr_addr<=csr_addr;
		out_regwrite_csr<=regwrite_csr;
		//control:EX
		bra_out<=bra_temp;
		jal_out<=jal_temp;
		jalr_out<=jalr_temp;
    selMuxExe_out<=selMuxExe_in;
    control_alu_out<=control_alu_in;
		//control:MEM
		MemRead_out<=MemRead_temp;
		MemWrite_out<=MemWrite_temp;
		//control:WB
		selMuxWB_out<=selMuxWB_in;
		RegWrite_out<=RegWrite_temp;
		//for forward		
		pcbra_out<=pcbra_in;
			
		MemWD_out<=MemWD_in;
    selSWHB_out<=selSWHB_in;
        
		end
		
	endmodule	
