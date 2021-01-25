`ifndef ALU_H
    `include "../include/risc.svh"
    `define ALU_H
`endif

module control(opcode,funct3,funct7,
				selMuxImm,
				selMuxRPC,
				selMuxRI,	
                selMuxExe,				
				bra,
				jal,
				jalr,
				MemRead,
				MemWrite,
                selSWHB,
				selMuxWB,
				RegWrite,
				hazardctrl,
                control_alu,
				//for interrupt
				interrupt,
				mret_wfi,	
				return_intr,
				WFI_stall,
				selMuxPC_csr,
				RegWrite_csr);
input [6:0] opcode;
input [2:0] funct3;
input funct7;
//csr
input interrupt;
input [11:0]mret_wfi;				
output logic return_intr;
output logic WFI_stall;
output logic selMuxPC_csr;
output logic RegWrite_csr;

output logic [2:0] selMuxImm;
output logic bra;
output logic jal;
output logic jalr;
output logic [1:0]selMuxRPC;//->2 bits
output logic [1:0]selMuxRI;//->2 bits
output logic MemRead;
output logic [3:0] MemWrite;
output logic [1:0] selSWHB;
output logic selMuxWB;
output logic RegWrite;
output logic [1:0] hazardctrl;
output logic [4:0] control_alu;//->5 bits
output logic [1:0] selMuxExe;

always@(*)
begin
    selMuxImm=3'b000;
    bra=1'b0;
    jal=1'b0;
    jalr=1'b0;
    selMuxRPC=2'b00;
    selMuxRI=2'b00;
    MemRead=1'b0;
    MemWrite=4'b1111;
    selSWHB=2'b00;
    selMuxWB=1'b0;
    RegWrite=1'b0;
    hazardctrl=2'b00;
    control_alu=`ADD;
    selMuxExe=2'b00; 
    return_intr=1'b0;
	WFI_stall=1'b0;
	selMuxPC_csr=1'b0;
	RegWrite_csr=1'b0;

	case(opcode)
	`NOP:
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b0;
		hazardctrl=2'b00;  
		end	
	`R:
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b01;
        case(funct3)
        3'b000: control_alu=(funct7)?`SUB:`ADD;
		3'b001: control_alu=`SLU;
		3'b010: control_alu=`SLTS;
		3'b011: control_alu=`SLTU;
		3'b100: control_alu=`XOR;
		3'b101: control_alu=(funct7)?`SRS:`SRU;
		3'b110: control_alu=`OR;
		3'b111: control_alu=`AND;
		endcase	
		end
	`I_lwlb:
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b01;
		MemRead=1'b1;
		MemWrite=4'b1111;
        selMuxWB=1'b1;
		RegWrite=1'b1;
		hazardctrl=2'b10;        
		end
	`I_other:
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b10;
        case(funct3)
        3'b000: control_alu=`ADD;
		3'b001: control_alu=`SLU;
		3'b010: control_alu=`SLTS;
		3'b011: control_alu=`SLTU;
		3'b100: control_alu=`XOR;
		3'b101: control_alu=(funct7)?`SRS:`SRU;
		3'b110: control_alu=`OR;
		3'b111: control_alu=`AND;
		endcase	
		end
	`I_jalr:
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b1;
		selMuxRPC=2'b00;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b10;
		selMuxExe=2'b10; //select PC+4
		end
	`S_swsb:
		begin
		selMuxImm=3'b001;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b0000;
		RegWrite=1'b0;
		hazardctrl=2'b01;
        if(funct3[1]==1'b1) //SW
            selSWHB=2'd0;
        else if(funct3[0]==1'b1) //SH
            selSWHB=2'd1;
        else
            selSWHB=2'd2; //SB
		end
	`B:
		begin
		selMuxImm=3'b000;
		bra=1'b1;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b0;
		hazardctrl=2'b01;
        case(funct3)
        3'b000: control_alu=`BEQ;
		3'b001: control_alu=`BNE;
		3'b010: control_alu=5'b00000;
		3'b011: control_alu=5'b00000;
		3'b100: control_alu=`BLT;
		3'b101: control_alu=`BGE;
		3'b110: control_alu=`BLTU;
		3'b111: control_alu=`BGEU;
		endcase	
		end
	`U_auipc:
		begin
		selMuxImm=3'b010;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b01;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b00;
		
		end
	`U_lui:
		begin
		selMuxImm=3'b010;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b00;
        selMuxExe=2'b01;//select IMM
		end	
	`J_jal:
		begin
		selMuxImm=3'b011;
		bra=1'b0;
		jal=1'b1;
		jalr=1'b0;
		selMuxRPC=2'b01;
		selMuxRI=2'b01;
		MemRead=1'b0;
		MemWrite=4'b1111;
		RegWrite=1'b1;
		hazardctrl=2'b00;
		selMuxExe=2'b10; //select PC+4
		end
	`CSR:
		begin
		if(mret_wfi==12'h302)//MRET
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		selSWHB=2'b00;
		selMuxWB=1'b0;
		RegWrite=1'b0;
		hazardctrl=2'b00;
		control_alu=`ADD;
		selMuxExe=2'b00; 
		return_intr=1'b1;//<-----
		WFI_stall=1'b0;
		selMuxPC_csr=1'b1;//<-----
		RegWrite_csr=1'b0;
		end
		else if(mret_wfi==12'h105)//WFI
		begin
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		selSWHB=2'b00;
		selMuxWB=1'b0;
		RegWrite=1'b0;
		hazardctrl=2'b00;
		control_alu=`ADD;
		selMuxExe=2'b00; 
		return_intr=1'b0;
		WFI_stall=(interrupt==1'b1)?1'b0:1'b1;//<-----
		selMuxPC_csr=1'b1;//<-----
		RegWrite_csr=1'b0;
		end
		else
		begin
		selMuxImm=3'b100;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;	
		MemRead=1'b0;
		MemWrite=4'b1111;
		selSWHB=2'b00;
		selMuxWB=1'b0;
		RegWrite=1'b1;
		return_intr=1'b0;
		WFI_stall=1'b0;
		selMuxPC_csr=1'b0;
		RegWrite_csr=1'b1;
		case(funct3)
		3'b001:
			begin
			selMuxRPC=2'b00;
			selMuxRI=2'b00;
			hazardctrl=2'b10;
			control_alu=`CSRRW;
			selMuxExe=2'b11;
			end
		3'b010:
			begin
			selMuxRPC=2'b00;
			selMuxRI=2'b10;
			hazardctrl=2'b10;
			control_alu=`CSRRS;
			selMuxExe=2'b11;
			end
		3'b011:
			begin
			selMuxRPC=2'b00;
			selMuxRI=2'b10;
			hazardctrl=2'b10;
			control_alu=`CSRRC;
			selMuxExe=2'b11;
			end
		3'b101:
			begin
			selMuxRPC=2'b00;
			selMuxRI=2'b01;
			hazardctrl=2'b00;
			control_alu=`CSRRWI;
			selMuxExe=2'b11;
			end
		3'b110:
			begin
			selMuxRPC=2'b10;
			selMuxRI=2'b01;
			hazardctrl=2'b00;
			control_alu=`CSRRSI;
			selMuxExe=2'b11;
			end
		3'b111:
			begin
			selMuxRPC=2'b10;
			selMuxRI=2'b01;
			hazardctrl=2'b00;
			control_alu=`CSRRCI;
			selMuxExe=2'b11;
			end
		default:
			begin
			selMuxImm=3'b000;
			bra=1'b0;
			jal=1'b0;
			jalr=1'b0;
			selMuxRPC=2'b00;
			selMuxRI=2'b00;
			MemRead=1'b0;
			MemWrite=4'b1111;
			selSWHB=2'b00;
			selMuxWB=1'b0;
			RegWrite=1'b0;
			hazardctrl=2'b00;
			control_alu=`ADD;
			selMuxExe=2'b00; 
			return_intr=1'b0;
			WFI_stall=1'b0;
			selMuxPC_csr=1'b0;
			RegWrite_csr=1'b0;
			end
		endcase
		end
		end
	default:
		begin	
		selMuxImm=3'b000;
		bra=1'b0;
		jal=1'b0;
		jalr=1'b0;
		selMuxRPC=2'b00;
		selMuxRI=2'b00;
		MemRead=1'b0;
		MemWrite=4'b1111;
		selSWHB=2'b00;
		selMuxWB=1'b0;
		RegWrite=1'b0;
		hazardctrl=2'b00;
		control_alu=`ADD;
		selMuxExe=2'b00; 
		return_intr=1'b0;
		WFI_stall=1'b0;
		selMuxPC_csr=1'b0;
		RegWrite_csr=1'b0;
		end	
    endcase	
end	
endmodule
