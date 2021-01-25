module IF_ID_Reg(
    input resetn,
    input clk,
    input IF_ID_enable,
	input WFI_stall,
	input return_intr,
    input NOP,
    input flush, //flush=branch
	input [31:0] pc_in,
	output reg [31:0] pc_out,
    
    input [31:0] ins_in,
	output [31:0] ins_out
);
logic [31:0] ins_tmp;
logic pass_before_intr;

assign ins_out = (flush)?32'h00000000:ins_tmp;
	
always@(posedge clk or negedge resetn)
    if(!resetn)
        begin //ins. preserve
        pc_out<=32'h00000000;
        ins_tmp<=32'h00000000;
		pass_before_intr<=1'b0;
        end
    else if((NOP==1'b1)||(WFI_stall==1'b1))
        begin
        pc_out<=pc_out;
        ins_tmp<=ins_tmp;
		pass_before_intr<=(WFI_stall==1'b1)?1'b1:1'b0;
        end
	else if(pass_before_intr==1'b1) //to pass a clock off, because had already read ins and pc when WFI is happened
        begin
        pc_out<=pc_in;
        ins_tmp<=32'h00000000;
		pass_before_intr<=1'b0;
        end	    	    
    else if(IF_ID_enable==1'b1)
        begin //ins. refresh
        pc_out<=pc_in;
        ins_tmp<=(return_intr==1'b1)?32'h00000000:ins_in;
		pass_before_intr<=1'b0;
        end	
    else
        begin
        pc_out<=pc_out;
        ins_tmp<=ins_tmp;
		pass_before_intr<=1'b0;
        end	
endmodule
