module Mux5to1(sel,in0,in1,in2,in3,in4,out);
input [2:0] sel;
input [31:0] in0,in1,in2,in3,in4;
output reg [31:0] out;

always@(*)
 case(sel)
 3'b001:out=in1;
 3'b010:out=in2;
 3'b011:out=in3;
 3'b100:out=in4;
 default:out=in0;
 endcase
endmodule