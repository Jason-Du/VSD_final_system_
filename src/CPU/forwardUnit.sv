module forwardUnit(EX_RegWrite,MEM_RegWrite,WB_RegWrite,WB_MemRead,ID_RegRs,ID_RegRt,
				EX_RegRd,MEM_RegRd,WB_RegRd,ForwardA,ForwardB);
	input EX_RegWrite,MEM_RegWrite,WB_RegWrite;
	input WB_MemRead;
					
	input [4:0] ID_RegRs,ID_RegRt,
				EX_RegRd,MEM_RegRd,WB_RegRd;
		
	output logic [1:0] ForwardA,ForwardB;
	
    wire RegRs_nonzero = (ID_RegRs != 5'b0);
    wire RegRt_nonzero = (ID_RegRt != 5'b0);
    
	always@(*)
	begin		
		//ForwardA:Rs
		if(EX_RegWrite&&(ID_RegRs==EX_RegRd)&&RegRs_nonzero)
			ForwardA=2'b01;
		else if(MEM_RegWrite&&(ID_RegRs==MEM_RegRd)&&RegRs_nonzero)
			ForwardA=2'b10;
        else if(WB_MemRead&&(ID_RegRs==WB_RegRd)&&RegRs_nonzero)
			ForwardA=2'b11;
		else if(WB_RegWrite&&(ID_RegRs==WB_RegRd)&&RegRs_nonzero)
			ForwardA=2'b11;
		else ForwardA=2'b00;	

		//ForwardB:Rt
		if(EX_RegWrite&&(ID_RegRt==EX_RegRd)&&RegRt_nonzero)
			ForwardB=2'b01;
		else if(MEM_RegWrite&&(ID_RegRt==MEM_RegRd)&&RegRt_nonzero)
			ForwardB=2'b10;
		else if(WB_MemRead&&(ID_RegRt==WB_RegRd)&&RegRt_nonzero)
			ForwardB=2'b11;
        else if(WB_RegWrite&&(ID_RegRt==WB_RegRd)&&RegRt_nonzero)
			ForwardB=2'b11;
		else ForwardB=2'b00;	
	end
	endmodule
	