module par_Register(
ACLK,ARESETn,data_in,data_out
);
// parameter
parameter WIDTH = 4;
input ACLK;
input ARESETn;
input [WIDTH-1:0] data_in;
output logic [WIDTH-1:0] data_out;

always_ff @(posedge ACLK or negedge ARESETn)
begin
if (~ARESETn)
    data_out <= {WIDTH{1'b0}};
else
    data_out <= data_in;
end
endmodule
