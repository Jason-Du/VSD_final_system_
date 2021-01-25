module flush(bratrue,
			EX_bra,
			EX_jalr,
			EX_jal,
			selMuxPC,
			flush);
input bratrue;
input EX_bra,EX_jalr,EX_jal;

output [1:0]selMuxPC;
output flush;
//wire bflush;

	//assign bflush=bratrue&EX_bra;
	assign selMuxPC[1]=EX_jal|EX_jalr;
	assign selMuxPC[0]=(bratrue&EX_bra)|EX_jalr;
	
	assign flush=(bratrue&EX_bra)|EX_jal|EX_jalr;
	endmodule