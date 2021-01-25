//=====================================================
// File Name:   DA_process.sv                            
// Version:     2.0 
// Description:
// Only store instructions would use this module
// There are three kind of store instructions including SW, SH, SB
// signal "core_in" is data from CPU
// signal "core_type" is word, halfword or byte
// signal "offset" include block_offset & byte offset,
// which is to select the specified halfword or byte
// They would determine signal "DA_write & DA_in"
//=======================================================

`ifndef DA_PROCESS_SV
`define DA_PROCESS_SV

`include "def.svh"

module DA_process(
input [`DATA_BITS-1:0] core_in,
input [2:0] core_type,
input [3:0] offset, //include block_offset & byte offset
output logic [`CACHE_DATA_BITS-1:0] DA_in, //128
output [`CACHE_WRITE_BITS-1:0] DA_write //16
);

wire [`CACHE_WRITE_BITS-1:0] DA_write_bar_SB;
wire [`CACHE_WRITE_BITS-1:0] DA_write_bar_SH;
wire [`CACHE_WRITE_BITS-1:0] DA_write_bar_SW;
wire [1:0] block_offset;

assign DA_write_bar_SB = (16'h0001 << offset);
assign DA_write_bar_SH = (16'h0003 << {offset[3:1],1'b0});
assign DA_write_bar_SW = (16'h000f << {offset[3:2],2'b0});
assign DA_write = (core_type==`CACHE_BYTE)? ~DA_write_bar_SB :
                  (core_type==`CACHE_HWORD)? ~DA_write_bar_SH :
                  ~DA_write_bar_SW;
assign block_offset = offset[3:2];

always_comb begin
    // Another simple state:
    // DA_in = {96'h0,core_in} << 32*block_offset;
    case(block_offset)
    2'd0: DA_in = {96'h0,core_in};
    2'd1: DA_in = {64'h0,core_in,32'h0};
    2'd2: DA_in = {32'h0,core_in,64'h0};
    2'd3: DA_in = {core_in,96'h0};
    endcase
end
endmodule

`endif
