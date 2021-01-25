//`timescale 1ns / 1ps

module regfile(resetn,ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, ReadData1, ReadData2);
//RegWrite:control
    input resetn;
	input bit [4:0] ReadRegister1,ReadRegister2,WriteRegister;
	input [31:0] WriteData;
	input RegWrite,clk;
	
	output reg [31:0] ReadData1,ReadData2;
	integer i;
	reg [31:0] Registers [0:31];

	always @(*)
	begin			
		ReadData1 = Registers[ReadRegister1];
		ReadData2 = Registers[ReadRegister2];
	end	
	always @(posedge clk or negedge resetn)
	begin
		if(!resetn)
			for(i=0;i<32;i=i+1)
				Registers[i]<=32'h00000000;		
		else
			if (RegWrite == 1'b1) 
                if(WriteRegister!=5'b0)
                    Registers[WriteRegister] <= WriteData;
	end

	
endmodule
