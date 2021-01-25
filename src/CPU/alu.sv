`include "../include/risc.svh"
//add csr function in alu，default state
//control_alu->5 bits
//add decision signal rs1->5 bits
module alu(rs1,control_alu,src1,src2,aluresult,bratrue);
input [4:0] control_alu,rs1;
input [31:0] src1,src2;
output reg [31:0] aluresult;
output reg bratrue;
wire slt,sltu;
	
assign slt=($signed(src1)<$signed(src2))?1'b1:1'b0;	
assign sltu=(src1<src2)?1'b1:1'b0;	
	
always@(*)
	begin
	aluresult=32'b0;
	bratrue=1'b0;
	case(control_alu)
	`ADD:aluresult=src1+src2;
	`SUB:aluresult=src1-src2;
	`SLU:aluresult=src1<<src2[4:0];
	`SLTS:aluresult={31'b0,slt};
	`SLTU:aluresult={31'b0,sltu};
	`XOR:aluresult=src1^src2;
	`SRU:aluresult=src1>>src2[4:0];
	`SRS:aluresult=$signed(src1)>>>src2[4:0];
	`OR:aluresult=src1|src2;
	`AND:aluresult=src1&src2;	
	`BEQ:bratrue=(src1==src2)?1'b1:1'b0;
	`BNE:bratrue=(src1!=src2)?1'b1:1'b0;	
	`BLT:bratrue=slt;	
	`BGE:bratrue=~slt;
	`BLTU:bratrue=sltu;	
	`BGEU:bratrue=~sltu;
	`CSRRW:aluresult=src1;
	`CSRRS:aluresult=(rs1==5'd0)?src2:(src2|src1);
	`CSRRC:aluresult=(rs1==5'd0)?src2:(src2&(~src1));
	`CSRRWI:aluresult=src2;
	`CSRRSI:aluresult=(rs1==5'd0)?src1:(src1|src2);
	`CSRRCI:aluresult=(rs1==5'd0)?src1:(src1&(~src2));
	default:
	begin
		aluresult=32'b0;
		bratrue=1'b0;
	end
	endcase
	end
endmodule	