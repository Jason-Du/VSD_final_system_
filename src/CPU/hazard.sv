module hazard(	hazardctrl,EX_MemRead,bra,ID_RegRs,
				EX_RegRd,MEM_RegRd,MEM_MemRead,//branch
				ID_RegRt,EX_RegWrite,
				IF_ID_enable,pc_enable,selMuxNop);
	input [1:0] hazardctrl;
	input EX_MemRead,bra;
	input [4:0] ID_RegRs,
				ID_RegRt;
							
	input [4:0] EX_RegRd,MEM_RegRd;				
	input MEM_MemRead,EX_RegWrite;			
	output reg IF_ID_enable,pc_enable,selMuxNop; 
	
	wire lwInEX1; //dis.=1,lw-any
	wire lwInMEM1; //dis.=1,lw-any
	wire lwInEX2; //dis.=1,lw-any
	wire lwInMEM2; //dis.=1,lw-any
	wire LWstall_com; //dis.=1,lw-any
	//wire BRAstallA; //dis.=1,add-branch
	//wire BRAstallB; //dis.=2,lw-X-branch
	//wire BRAstallC; //dis.=1,lw-branch
	
	assign lwInEX1=(EX_MemRead)&&(hazardctrl==2'b01)&&((EX_RegRd==ID_RegRs)||(EX_RegRd==ID_RegRt));
	assign lwInMEM1=(MEM_MemRead)&&(hazardctrl==2'b01)&&((MEM_RegRd==ID_RegRs)||(MEM_RegRd==ID_RegRt));
	assign lwInEX2=(EX_MemRead)&&(hazardctrl==2'b10)&&(EX_RegRd==ID_RegRs);
	assign lwInMEM2=(MEM_MemRead)&&(hazardctrl==2'b10)&&(MEM_RegRd==ID_RegRs);
	assign LWstall_com=lwInEX1|lwInMEM1|lwInEX2|lwInMEM2;
    
	//LW + data hazardctrl(addr. are the same)
	//assign BRAstallA=((bra)&&EX_RegWrite&&((EX_RegRd==ID_RegRs)||(EX_RegRd==ID_RegRt)));
	//assign BRAstallB=((bra)&&MEM_MemRead&&((MEM_RegRd==ID_RegRs)||(MEM_RegRd==ID_RegRt)));
	
	always@(*)
		if (LWstall_com)
			//stall one cycle
			begin
			IF_ID_enable=1'b0;//ins. preserve
			pc_enable=1'b0;//pc preserve
			selMuxNop=1'b1;//control = 0
			end		
		else
			begin
			IF_ID_enable=1'b1;
			pc_enable=1'b1;
			selMuxNop=1'b0;
			end		
			
	endmodule	