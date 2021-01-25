`ifndef COUNTERDRAM_SV
`define COUNTERDRAM_SV

module counter_dram(rst, clk, stop, load, carry, load_value);
parameter DataNumberSize=4;
input rst;
input clk;
input load;//keep counting signal
input stop;
input [DataNumberSize-1:0] load_value; //for data load length(the number of data)
output logic carry;

logic [DataNumberSize-1:0] count;
logic [DataNumberSize-1:0]dram_delay;

assign carry = (count==(load_value));

always_ff @(posedge clk or posedge rst)
begin
    if(rst)begin
        count <= 4'd0;
	end
    else begin
		if(stop)begin
			count <= 4'd0;
		end
        else if(load)begin
            count <= count + 4'd1;
		end
        else begin
            count <= count;
		end
	end
end
endmodule

`endif