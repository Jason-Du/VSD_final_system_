module Mux4to1_csr(in0,in1,in2,in3,select,out,
					  EX_RegRd,
					  MEM_RegRd,
					  WB_RegRd);
					  
input [31:0] in0,in1,in2,in3;
input [1:0] select;
input [11:0] EX_RegRd,MEM_RegRd,WB_RegRd;
output [31:0] out;

logic [31:0] out,_out;
logic [11:0] _addr;
logic [3:0] addr;
always_comb begin
	case(select)
	2'b00:begin
		_out=in0;
		_addr=12'hfff;
	end	
	2'b01:
	begin
		_out=in1;
		_addr=EX_RegRd;
	end
	2'b10:
	begin
		_out=in2;
		_addr=MEM_RegRd;
	end
	2'b11:
	begin
		_out=in3;	
		_addr=WB_RegRd;
	end
	endcase
	
	case(_addr)
		12'h300:addr=4'h0; //mststus			
		12'h304:addr=4'h1; //mie			
		12'h305:addr=4'h2; //mtvec			
		12'h341:addr=4'h3; //mepc			
		12'h344:addr=4'h4; //mip			
		12'hb00:addr=4'h5; //cycle			
		12'hb02:addr=4'h6;			
		12'hb80:addr=4'h7; //finished instruction number		
		12'hb82:addr=4'h8;		
		default:addr=4'hf;
	endcase
	
	case(addr)
		4'd0:out = {19'd0,_out[12:11],3'd0,_out[7],3'd0,_out[3],3'd0};
		4'd1:out = {20'd0,_out[11],11'd0};
		4'd2:out = {32'h00010000};
		4'd3:out = {_out[31:2],2'd0};
		4'd4:out = 32'd0;//{20'd0,_out[11],11'd0};
		4'd5:out = _out;
		4'd6:out = _out;
		4'd7:out = _out;
		4'd8:out = _out;
		default:out = _out;
	endcase
end
endmodule	