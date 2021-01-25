`ifndef COUNTERDELAY_SV
`define COUNTERDELAY_SV
`timescale 1ns/10ps

module counter_delay(rst, clk, stop, load, carry, count);
input rst;
input clk;
input load;
input stop;
output logic carry;
output logic [3:0] count;

assign carry = (count==4'd5);

always_ff @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 4'd1;
    else
        if(stop)
            count <= count;
        else if(load)
            count <= count + 4'd1;
        else
            count <= 4'd1;
end
endmodule

`endif
