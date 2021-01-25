module Mux3to1(in0,in1,in2,select,out);
	input [31:0] in0,in1,in2;
	input [1:0] select;
	output reg[31:0] out;
	
	always@(*)
		case(select)
		2'b00:
			out=in0;
		2'b01:
			out=in1;
		2'b10:
			out=in2;
		default:
			out=in0;	
		endcase
	
//	assign out=(select==2'b00)?in0:((select==2'b01)?in1:in2);
	
	endmodule