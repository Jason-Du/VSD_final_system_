//================================================
// Filename:    CPU.sv                            
// Version:     2.2 
// ------- 20201112 -------
// change sb_unit to "store_unit"
// "control" selSWHB to WB phase
// change sign_extend to "load_unit"
// pass signal"funct3" to WB phase
// signal "selMuxWB" 2 bits to 1 bit
// add output signal "D_type"
// ------- 20201113 -------
// modify "load_unit", all data is on the right hand side
// modify "store_unit", halfword is depending on Addr[1] 
// ------- 20201210 -------
// add interrupt signal on CPU's 
// add CSR.sv for interrupt
//================================================
`include "def.svh"

`define CPU
 `include "../include/risc.svh"
 `include "Mux2to1_32bit.sv"
 `include "Mux3to1.sv"
 `include "Mux4to1.sv"
 `include "Mux5to1.sv"
 `include "Mux4to1_csr.sv"

 `include "pc.sv"
 `include "CSR.sv"
 `include "IF_ID_Reg.sv"
 `include "IG.sv"
 `include "control.sv"
 `include "regfile.sv"
 `include "ID_EX_Reg.sv"
 `include "alu.sv"
 `include "EX_MEM_Reg.sv"
 `include "MEM_WB_Reg.sv"
 `include "forwardUnit.sv"
 `include "forwardUnit_csr.sv"
 `include "hazard.sv"
 `include "flush.sv"
 `include "store_unit.sv"
 `include "load_unit.sv"

module CPU(resetn,clk,interrupt,
				//InsMem:
				pc,ins,I_Read,
				//DataMem:
				D_Addr,D_WrtieData,D_Write,D_Read,D_ReadData,D_type,
                NOP);
	input resetn;
	input interrupt;
	input clk;
	//InsMem
	output [31:0] pc;
    output I_Read;
	input [31:0] ins;
	//DataMem
    output [2:0] D_type;
	output [31:0] D_Addr;
    output [3:0] D_Write;
	output [31:0] D_WrtieData;
    output D_Read;
	input [31:0] D_ReadData;	 
    //CPU communicate with wrapper
	input NOP;

//----------------------------------
	//IF stage
	wire [31:0] IF_pc_add4,pc_bra;//,pc_jal,pc_jalr
	wire [31:0] pc_next,pc_now,pc_next_tmp;
	wire pc_enable;	
	wire [1:0] selMuxPC;

	//ID stage
	wire [31:0] ID_ins;
	wire [31:0] ID_pc;
	wire [31:0] immB,immJ,immI,immS,immU,imm,immCSR;
    
	//EX stage
	wire [31:0] EX_imm;
        wire [4:0] EX_rs1;
	wire [31:0] EX_pc,EX_pc_add4,EX_pc_bra;
	
	wire IF_ID_enable;
	wire flush;
    wire flush_second;
	wire [4:0] EX_RegRd,
			   MEM_RegRd,
			   WB_RegRd;
	wire [31:0] WriteData;
	//control-ID
	wire [2:0]ID_selMuxImm;
	wire [1:0]ID_selMuxRPC;
	wire [1:0]ID_selMuxRI;  
    
	//control-EX
	wire ID_bra,
		 EX_bra;	
	wire ID_jal,
		 EX_jal;
	wire ID_jalr,
		 EX_jalr;
	//control-MEM	 
	wire ID_MemRead;
	wire EX_MemRead;
    wire MEM_MemRead;
    wire WB_MemRead;
    wire [31:0]MEM_pc;
	wire [3:0] ID_MemWrite,
	     EX_MemWrite,
         MEM_MemWrite_tmp,
		 MEM_MemWrite;

	//control-WB	 		 
	wire ID_selMuxWB,
          EX_selMuxWB,
          MEM_selMuxWB,
          WB_selMuxWB;
	wire ID_RegWrite,
		 EX_RegWrite,
		 MEM_RegWrite,
		 WB_RegWrite;
    wire [31:0]WB_pc;     
    wire [2:0] EX_funct3;
    wire [2:0] MEM_funct3;
    wire [2:0] WB_funct3;

//-----------------------------------		
	wire [31:0] ReadData1,ReadData2;
	wire [6:0] opcode;
	//data hazard
	wire [4:0] ID_RegRs,
			   ID_RegRt,
			   ID_RegRd;
	
	wire selMuxNop;
	//forwardUnit
	wire [1:0] ForwardA,ForwardB;
	//ALU
	wire [31:0] aluresult;
	
	//MEM
	wire [31:0] WB_MemRD;
	wire [31:0] EX_MemWD;
	wire [31:0] D_WrtieData_tmp;
    wire [31:0] WB_MemRD_tmp;
	
	wire [4:0] ID_control_alu,
               EX_control_alu;
               
	wire bratrue;	
	wire [31:0] ID_src1,ID_src2,ID_src1_temp,ID_src2_temp,EX_src1,EX_src2;

	wire [1:0] hazardctrl;
    
    wire [1:0] ID_selSWHB,EX_selSWHB,MEM_selSWHB;
    
    wire [1:0] selMuxExe;
    wire [1:0] EX_selMuxExe;
    wire [31:0] EX_WriteData;
    wire [31:0] MEM_WriteData;
    wire [31:0] WB_WriteData;
//add csr signal and data wire
wire [31:0] csr_data;
wire return_intr, WFI_stall, RegWrite_csr;
wire selMuxPC_csr;
wire [31:0]ReadData_csr, pc_intr, WriteData_csr, EX_WriteData_csr, MEM_WriteData_csr;
wire [11:0]WB_RegRd_csr, EX_RegRd_csr, MEM_RegRd_csr;
wire WB_RegWrite_csr, MEM_RegWrite_csr, EX_RegWrite_csr;
wire [1:0]Forward_csr;
    //-----------------------------------------------------//
	assign opcode=ID_ins[6:0];
	assign ID_RegRs=ID_ins[19:15];
	assign ID_RegRt=ID_ins[24:20];
	assign ID_RegRd=ID_ins[11:7];
	assign IF_pc_add4=pc_now+32'd4;//AdderIFPC
    //DM--------------------------------    
    assign D_Read = MEM_MemRead;
    assign D_Write = MEM_MemWrite;
    assign D_Addr = MEM_WriteData;
    assign D_type = MEM_funct3;
    
	Mux4to1 MuxPC(.in0(IF_pc_add4),
				  .in1(EX_pc_bra),
				  .in2(aluresult),//pc_jal,EX_pc_jal
				  .in3({aluresult[31:1],1'b0}),//pc_jalr{aluresult[31:1],1'b0}
				  .select(selMuxPC),
				  .out(pc_next_tmp));
	
	Mux2to1_32bit MuxPC_csr(.in0(pc_next_tmp),
							.in1(pc_intr),
							.sel(selMuxPC_csr),
							.out(pc_next));
	
  wire pc_enable_v2 = pc_enable&(~NOP)&(~WFI_stall);
	//Fetch Stage
	pc pc1( .resetn(resetn),
			.pc_enable(pc_enable_v2), 
			.pcin(pc_next),
			.clk(clk),
			.pcout(pc_now),
			.IM_Read(I_Read));
    
	assign pc =  pc_now;

	flush flushUnit(.bratrue(bratrue),
					.EX_bra(EX_bra),
					.EX_jalr(EX_jalr),
					.EX_jal(EX_jal),
					.selMuxPC(selMuxPC),
					.flush(flush));
	
	IF_ID_Reg IF_ID_Reg(.resetn(resetn),
						.IF_ID_enable(IF_ID_enable),
						.flush(flush|flush_second),
						.clk(clk),
						.pc_in(pc_now),
						.WFI_stall(WFI_stall),
						.return_intr(return_intr),
            .NOP(NOP),
						.ins_in(ins),
						.pc_out(ID_pc),
						.ins_out(ID_ins)
                        );
    
	//ID Stage			
    assign pc_bra = ID_pc + immB;

	control control(.opcode(opcode),
                    .funct3(ID_ins[14:12]),
                    .funct7(ID_ins[30]),
					.selMuxImm(ID_selMuxImm),
					.bra(ID_bra),
					.jal(ID_jal),
					.jalr(ID_jalr),
					// .aluop(ID_aluop),
					.selMuxRPC(ID_selMuxRPC),
					.selMuxRI(ID_selMuxRI),
                    // .selMuxImmPC(selMuxImmPC),
                    .selMuxExe(selMuxExe),
					.MemRead(ID_MemRead),
					.MemWrite(ID_MemWrite),
					.selMuxWB(ID_selMuxWB),
					.RegWrite(ID_RegWrite),
					.hazardctrl(hazardctrl),
                    .selSWHB(ID_selSWHB),
                    .control_alu(ID_control_alu),
					//CSR
					.interrupt(interrupt),        //for interrupt
					.mret_wfi(ID_ins[31:20]),
					
					.return_intr(return_intr),
					.WFI_stall(WFI_stall),
					.selMuxPC_csr(selMuxPC_csr),
					.RegWrite_csr(RegWrite_csr));

	IG ImmGen(.ins(ID_ins[31:7]),
				.immI(immI),
				.immS(immS),
				.immB(immB),
				.immU(immU),
				.immCSR(immCSR),
				.immJ(immJ));
	
	Mux5to1 MuxImm(.sel(ID_selMuxImm),
				   .in0(immI),
				   .in1(immS),
				   .in2(immU),
				   .in3(immJ),
				   .in4(immCSR),
				   .out(imm));	
	
	regfile regfile(.resetn(resetn),
					.ReadRegister1(ID_RegRs),
					.ReadRegister2(ID_RegRt),
					.WriteRegister(WB_RegRd),
					.WriteData(WriteData),
					.RegWrite(WB_RegWrite),
					.clk(clk),
					.ReadData1(ReadData1),
					.ReadData2(ReadData2));
//////-------------------------------------CSR----------------------------------------------/////////						
	CSR CSR(.resetn(resetn), 
			.clk(clk), 
			.interrupt(interrupt), 
			.return_intr(return_intr), 
			.pc(WB_pc),
			.WFI(ID_ins[31:20]),
			.ReadRegister_csr(ID_ins[31:20]), 
			.ReadData_csr(ReadData_csr), 
			.ReadDATA_intr(pc_intr),
			.WriteRegister_csr(WB_RegRd_csr), 
			.WriteData_csr(WriteData_csr),
			.RegWrite_csr(WB_RegWrite_csr), 
			.WriteData_pc_intr(ID_pc));
    
	forwardUnit_csr forwardUnit_csr(.EX_RegWrite(EX_RegWrite_csr),
									.MEM_RegWrite(MEM_RegWrite_csr),
									.WB_RegWrite(WB_RegWrite_csr),
									.ID_RegRs(ID_ins[31:20]),
									.EX_RegRd(EX_RegRd_csr),
									.MEM_RegRd(MEM_RegRd_csr),
									.WB_RegRd(WB_RegRd_csr),
									.Forward(Forward_csr));
	
	Mux4to1_csr MuxIDcsr( .select(Forward_csr),
					  .EX_RegRd(EX_RegRd_csr),
					  .MEM_RegRd(MEM_RegRd_csr),
					  .WB_RegRd(WB_RegRd_csr),
					  .in0(ReadData_csr),
					  .in1(aluresult),
					  .in2(MEM_WriteData_csr),
					  .in3(WriteData_csr),
					  .out(csr_data));
//////////////////////////////////////////////////////////////////////////////////////////////////	
	Mux4to1 MuxIDSrc1(.select(ForwardA),
					  .in0(ReadData1),
					  .in1(EX_WriteData),
					  .in2(MEM_WriteData),
					  .in3(WriteData),
					  .out(ID_src1_temp));
	
	Mux4to1 MuxIDSrc2(.select(ForwardB),
					  .in0(ReadData2),
					  .in1(EX_WriteData),
					  .in2(MEM_WriteData),
					  .in3(WriteData),
					  .out(ID_src2_temp));

	Mux3to1 MuxRPC( .select(ID_selMuxRPC),
					.in0(ID_src1_temp),
					.in1(ID_pc),
					.in2(csr_data),
					.out(ID_src1));						
						
	Mux3to1 MuxRI(  .select(ID_selMuxRI),
					.in0(ID_src2_temp),
					.in1(imm),
					.in2(csr_data),
					.out(ID_src2));

	
	hazard hazard(.EX_MemRead(EX_MemRead),
				  .bra(ID_bra),
				  .ID_RegRs(ID_RegRs),
				  .EX_RegRd(EX_RegRd),
				  .MEM_RegRd(MEM_RegRd),
				  .MEM_MemRead(MEM_MemRead),
				  .ID_RegRt(ID_RegRt),
				  .IF_ID_enable(IF_ID_enable),
				  .pc_enable(pc_enable),
				  .selMuxNop(selMuxNop),
				  .EX_RegWrite(EX_RegWrite),
				  .hazardctrl(hazardctrl));
		
	ID_EX_Reg ID_EX_Reg(.resetn(resetn),
						.clk(clk),
						.flush(flush|flush_second),//ID_flush
						.RegRd_in(ID_RegRd),
						.imm_in(imm),
						.pc_in(ID_pc),
						.ReadData1_in(ID_src1),//ReadData1
						.ReadData2_in(ID_src2),//ReadData2
						.pcbra_in(pc_bra),						
						//csr
						.rs1_in(ID_ins[19:15]),
						.rs1_out(EX_rs1),
						.csr_data(csr_data),
						.csr_addr(ID_ins[31:20]),
						.regwrite_csr(RegWrite_csr),
						.out_csr_data(EX_WriteData_csr),
						.out_csr_addr(EX_RegRd_csr),
						.out_regwrite_csr(EX_RegWrite_csr),						
						//control
						.jalr_in(ID_jalr),
						.MemRead_in(ID_MemRead),
						.MemWrite_in(ID_MemWrite),
						.selMuxWB_in(ID_selMuxWB),
						.RegWrite_in(ID_RegWrite),						
						//out
						.RegRd_out(EX_RegRd),
						.imm_out(EX_imm),
						.pc_out(EX_pc),
						.ReadData1_out(EX_src1),
						.ReadData2_out(EX_src2),
						//control		
						.jalr_out(EX_jalr),
						.MemRead_out(EX_MemRead),
						.MemWrite_out(EX_MemWrite),
						.selMuxWB_out(EX_selMuxWB),
						.RegWrite_out(EX_RegWrite),
						.pcbra_out(EX_pc_bra),
						.bra_in(ID_bra),
						.jal_in(ID_jal),
						.bra_out(EX_bra),
						.jal_out(EX_jal),	
						.control_alu_in(ID_control_alu),
						.control_alu_out(EX_control_alu),
						.MemWD_in(ID_src2_temp),
						.MemWD_out(EX_MemWD),
						.selMuxNop(selMuxNop),
                        .selMuxExe_in(selMuxExe),
                        .selMuxExe_out(EX_selMuxExe),
						.selSWHB_in(ID_selSWHB),
                        .selSWHB_out(EX_selSWHB), 
                        .funct3_in(ID_ins[14:12]),
                        .funct3_out(EX_funct3),
						.NOP(NOP)
    );
	
	//Ex Stage
	assign EX_pc_add4=EX_pc+32'd4;//AdderWBPC			  	

	alu alu(.src1(EX_src1),
			.src2(EX_src2),
			.rs1(EX_rs1),//add from instruction
			.control_alu(EX_control_alu),//5 bits
			.aluresult(aluresult),
			.bratrue(bratrue));	
	
    Mux4to1 MuxExe(.select(EX_selMuxExe),
                   .in0(aluresult),
                   .in1(EX_imm),
                   .in2(EX_pc_add4),
				   .in3(EX_WriteData_csr),
                   .out(EX_WriteData));
                           
	forwardUnit forwardUnit(.EX_RegWrite(EX_RegWrite),
							.MEM_RegWrite(MEM_RegWrite),
							.WB_RegWrite(WB_RegWrite),
							.WB_MemRead(WB_MemRead),
							.ID_RegRs(ID_RegRs),
							.ID_RegRt(ID_RegRt),
							.EX_RegRd(EX_RegRd),
							.MEM_RegRd(MEM_RegRd),
							.WB_RegRd(WB_RegRd),
							.ForwardA(ForwardA),
							.ForwardB(ForwardB));
			
	EX_MEM_Reg EX_MEM_Reg  (.resetn(resetn),
							.clk(clk),
							.MemWD_in(EX_MemWD),
							.WriteAddr_in(EX_RegRd),
							//control
							.MemRead_in(EX_MemRead),
							.MemWrite_in(EX_MemWrite),
							.selMuxWB_in(EX_selMuxWB),
							.RegWrite_in(EX_RegWrite),
							.MemWD_out(D_WrtieData_tmp),//MEMdata
							.WriteAddr_out(MEM_RegRd),
							//control
							.MemRead_out(MEM_MemRead),
							.MemWrite_out(MEM_MemWrite_tmp),
							.selMuxWB_out(MEM_selMuxWB),
							.RegWrite_out(MEM_RegWrite),
                            .flush_in(flush),
                            .flush_out(flush_second),
                            .selSWHB_in(EX_selSWHB),
                            .selSWHB_out(MEM_selSWHB),
                            .WriteData_in(EX_WriteData),
                            .WriteData_out(MEM_WriteData),
                            .funct3_in(EX_funct3),
                            .funct3_out(MEM_funct3),
							.NOP(NOP),
							//csr
							.csr_data(aluresult),
							.csr_addr(EX_RegRd_csr),
							.regwrite_csr(EX_RegWrite_csr),
							.out_csr_data(MEM_WriteData_csr),
							.out_csr_addr(MEM_RegRd_csr),
							.out_regwrite_csr(MEM_RegWrite_csr),
							.pc_in(EX_pc),
							.pc_out(MEM_pc)
    );	
                      
    //Think : Use MEM_funct3 3bits to replace MEM_selSWHB 2bits
    store_unit store_unit(  .MEM_selSWHB(MEM_selSWHB),
							.MEM_WritAddr_in(MEM_WriteData[1:0]), //aluresult
							.MEM_MemWrite_in(MEM_MemWrite_tmp),
							.MEM_MemWrite_out(MEM_MemWrite),
							.MEM_MemWD_in(D_WrtieData_tmp),
							.MEM_MemWD_out(D_WrtieData)
    );

	MEM_WB_Reg MEM_WB_Reg(.resetn(resetn),
						  .clk(clk),
                          //input
						  .WriteData_in(MEM_WriteData),
						  .WriteAddr_in(MEM_RegRd),
						  .selMuxWB_in(MEM_selMuxWB),
						  .RegWrite_in(MEM_RegWrite),
                          .MemRead_in(MEM_MemRead),
                          //out
						  .WriteData_out(WB_WriteData),
						  .WriteAddr_out(WB_RegRd),
						  .selMuxWB_out(WB_selMuxWB),
						  .RegWrite_out(WB_RegWrite),
                          .MemRead_out(WB_MemRead),
                          .MemRD_in(D_ReadData),
                          .MemRD_out(WB_MemRD),
                          .funct3_in(MEM_funct3),
                          .funct3_out(WB_funct3),
                          .NOP(NOP),
						  //csr
						  .csr_data(MEM_WriteData_csr),
						  .csr_addr(MEM_RegRd_csr),
						  .regwrite_csr(MEM_RegWrite_csr),
						  .out_csr_data(WriteData_csr),
						  .out_csr_addr(WB_RegRd_csr),
						  .out_regwrite_csr(WB_RegWrite_csr),
						  .pc_in(MEM_pc),
						  .pc_out(WB_pc)
);
	         
	//WB stage					  
    load_unit load_unit(
						.Addr(WB_WriteData[1:0]),
						.selLWHB(WB_funct3),
						.MemRD_in(WB_MemRD),
						.MemRD_out(WB_MemRD_tmp)
    );
	
	Mux2to1_32bit MuxWB(.in0(WB_WriteData),
				  .in1(WB_MemRD_tmp),
				  .sel(WB_selMuxWB),
				  .out(WriteData));	
			
	endmodule			
				
