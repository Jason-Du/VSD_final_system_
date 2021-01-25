`ifndef COUNTER_SV
`define COUNTER_SV

module counter(rst, clk, stop, load, carry, count);
input rst;
input clk;
input load;
input stop;
output logic carry;
output logic [1:0] count;

assign carry = (count==2'd3);

always_ff @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 2'd0;
    else
        if(stop)
            count <= count;
        else if(load)
            count <= count + 2'd1;
        else
            count <= 2'd0;
end
endmodule

`endif