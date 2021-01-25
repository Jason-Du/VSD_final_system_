`ifndef PAR_S_COUNTER_SV
`define PAR_S_COUNTER_SV

module par_sensor_counter(rst, clk, stop, load, carry, count, load_value);

parameter NUM = 4;
input rst;
input clk;
input load;
input stop;
input [NUM-1:0] load_value;
output logic carry;
output logic [NUM-1:0] count;

assign carry = (count==load_value);

always_ff @(posedge clk or posedge rst)
begin
    if(rst)
        count <= {NUM{1'b0}};
    else
        if(stop)
            count <= count;
        else if(load)
            count <= count + {{(NUM-1){1'b0}},1'b1};
        else
            count <= {NUM{1'b0}};
end
endmodule

`endif
