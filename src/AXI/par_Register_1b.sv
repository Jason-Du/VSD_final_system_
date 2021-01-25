module par_Register_1b(
ACLK,ARESETn,data_in,data_out
);
input ACLK;
input ARESETn;
input data_in;
output logic data_out;

always_ff @(posedge ACLK or negedge ARESETn)
begin
if (~ARESETn)
    data_out <= 1'b0;
else
    data_out <= data_in;
end
endmodule