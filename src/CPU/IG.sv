module IG(ins,immI,immS,immB,immU,immJ,immCSR);//imm gen
input [31:7] ins;
output logic[31:0] immI,immS,immB,immU,immJ,immCSR;

always_comb begin
	begin
		if(ins[31]==1'b0) begin
			immI={20'h00000,ins[31:20]};
			immS={20'h00000,ins[31:25],ins[11:7]};
			immB={19'h0,ins[31],ins[7],ins[30:25],ins[11:8],1'b0};
			immJ={11'h0,ins[31],ins[19:12],ins[20],ins[30:21],1'b0};	
		end			
		else begin
			immI={20'hFFFFF,ins[31:20]};
			immS={20'hFFFFF,ins[31:25],ins[11:7]};
			immB={3'b111,16'hFFFF,ins[31],ins[7],ins[30:25],ins[11:8],1'b0};
			immJ={3'b111,8'hFF,ins[31],ins[19:12],ins[20],ins[30:21],1'b0};			
		end
		immU={ins[31:12],12'h000};
		immCSR={27'd0,ins[19:15]};
	end		
end	
endmodule		