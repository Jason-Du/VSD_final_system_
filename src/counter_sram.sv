`ifndef COUNTERSRAM_SV
`define COUNTERSRAM_SV

module counter_sram(rst, clk, stop, load, carry, load_value);
input rst;
input clk;
input load;
input stop;
input [3:0] load_value; //for len
output logic carry;

logic [3:0] count;
assign carry = (count==load_value);

always_ff @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 4'd0;
    else
        if(load)
            count <= count + 4'd1;
        else
            count <= 4'd0;
end
endmodule

`endif
