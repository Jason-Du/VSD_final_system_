//=====================================================
// File Name:   store_unit.sv                            
// Version:     2.0 
// Description:
// There are three kind of store instructions including SW, SH, SB
// signal "MEM_selSWHB" would decide pass word, halfword or byte
// signal "MEM_WritAddr_in" is offset, which is to select the specified halfword or byte
// These two signals would determine signal "MemWrite & MEM_MemWD"
// ------- 20201113 ------------------------------------
// halfword is only depending on Addr[1] 
// -----------------------------------------------------
// Thinking : "MEM_MemWrite_in" is unused in the module
//=======================================================

module store_unit(
input [1:0] MEM_selSWHB,
input [1:0] MEM_WritAddr_in,

input [3:0] MEM_MemWrite_in,
output [3:0] MEM_MemWrite_out,

input [31:0] MEM_MemWD_in,
output logic [31:0] MEM_MemWD_out
);

wire [3:0] MEM_MemWrite_bar_SB;
wire [3:0] MEM_MemWrite_bar_SH;

assign MEM_MemWrite_bar_SB = (4'b0001 << MEM_WritAddr_in[1:0]);
assign MEM_MemWrite_bar_SH = (4'b0011 << {MEM_WritAddr_in[1],1'b0});
assign MEM_MemWrite_out = (MEM_selSWHB==2'd2)? ~MEM_MemWrite_bar_SB :
                          (MEM_selSWHB==2'd1)? ~MEM_MemWrite_bar_SH :
                          MEM_MemWrite_in;

always_comb begin
    case(MEM_selSWHB)
    2'd1:
        case(MEM_WritAddr_in[1])
        1'b0: MEM_MemWD_out = {16'b0,MEM_MemWD_in[15:0]};
        1'b1: MEM_MemWD_out = {MEM_MemWD_in[15:0],16'b0};
        endcase 
        /*
        case(MEM_WritAddr_in)
        2'b00: MEM_MemWD_out = {16'b0,MEM_MemWD_in[15:0]};
        2'b01: MEM_MemWD_out = {8'b0,MEM_MemWD_in[15:0],8'b0};
        2'b10: MEM_MemWD_out = {MEM_MemWD_in[15:0],16'b0};
        2'b11: MEM_MemWD_out = {MEM_MemWD_in[7:0],24'b0};
        endcase     
        */        
    2'd2:
        case(MEM_WritAddr_in)
        2'b00: MEM_MemWD_out = {24'b0,MEM_MemWD_in[7:0]};
        2'b01: MEM_MemWD_out = {24'b0,MEM_MemWD_in[7:0]} << 8;
        2'b10: MEM_MemWD_out = {24'b0,MEM_MemWD_in[7:0]} << 16;
        2'b11: MEM_MemWD_out = {24'b0,MEM_MemWD_in[7:0]} << 24;
        endcase
    default:
        MEM_MemWD_out = MEM_MemWD_in;
    endcase
end
endmodule