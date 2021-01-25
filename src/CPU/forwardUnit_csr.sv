module forwardUnit_csr( EX_RegWrite,
										MEM_RegWrite,
										WB_RegWrite,
										ID_RegRs,
										EX_RegRd,
										MEM_RegRd,
										WB_RegRd,
										Forward
);
	input EX_RegWrite, MEM_RegWrite, WB_RegWrite;
	
	input [11:0] ID_RegRs, EX_RegRd, MEM_RegRd, WB_RegRd;
		
	output logic [1:0] Forward;
	
    wire RegRs_nonzero = (ID_RegRs != 12'b0);
    
	always@(*)
	begin		
		//ForwardA:Rs
		if(EX_RegWrite&&(ID_RegRs==EX_RegRd)&&RegRs_nonzero)
			Forward=2'b01;
		else if(MEM_RegWrite&&(ID_RegRs==MEM_RegRd)&&RegRs_nonzero)
			Forward=2'b10;
		else if(WB_RegWrite&&(ID_RegRs==WB_RegRd)&&RegRs_nonzero)
			Forward=2'b11;
		else Forward=2'b00;		
	end
	endmodule
	
