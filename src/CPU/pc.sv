module pc(resetn,pc_enable,pcin,clk,pcout,IM_Read);
	input resetn;
  input pc_enable;
	input [31:0] pcin;
	input clk;
	output reg [31:0] pcout;
  output reg IM_Read;
	
  logic resetn_Last;
	always@(posedge clk or negedge resetn)
    begin    
		if(!resetn) begin
      resetn_Last <= 1'b0;
      pcout<=32'h00000000;
      IM_Read<=1'b0;
      end
		else if(!resetn_Last)begin
      resetn_Last <= resetn;
      pcout <= 32'h00000000;
      IM_Read <= 1'b1;            
      end
    else begin
      resetn_Last <= resetn;
			if(pc_enable) begin
				pcout<=pcin;
        IM_Read<=1'b1;	
        end
			else begin
				pcout<=pcout; //preserve 
        IM_Read<=1'b0;
        end
		end	
	end	
endmodule		
	
