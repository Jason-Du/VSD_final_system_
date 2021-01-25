//=====================================================
// File Name:   load_unit.sv                            
// Version:     2.0 
// Description:
// There are five kind of load instructions including LB, LH, LW, LBU, LHU
// Signal "selLWHB" would decide pass word, halfword or byte ,and unsigned or signed
// They are func3 : ins[14:12]
// Signal "Addr" is offset, which is to select the specified halfword or byte
// These two signals would determine signal "MemRD_out"
// ------- 20201113 ------------------------------------
// all data is on the right hand side // prog1 error fixed
// halfword is only depending on Addr[1] 
//=======================================================
localparam LB = 3'b000;
localparam LH = 3'b001;
localparam LW = 3'b010;
localparam LBU = 3'b100;
localparam LHU = 3'b101;

module load_unit(
input [2:0] selLWHB,
input [1:0] Addr,
input [31:0] MemRD_in,
output logic [31:0] MemRD_out
);

always_comb begin
    case(selLWHB)
    LB: 
        case(Addr)
        2'd0: MemRD_out = {{24{MemRD_in[7]}},MemRD_in[7:0]};
        2'd1: MemRD_out = {{24{MemRD_in[15]}},MemRD_in[15:8]};
        2'd2: MemRD_out = {{24{MemRD_in[23]}},MemRD_in[23:16]};
        2'd3: MemRD_out = {{24{MemRD_in[31]}},MemRD_in[31:24]};
        endcase
    LH:
        case(Addr[1])
        1'd0: MemRD_out = {{16{MemRD_in[15]}},MemRD_in[15:0]};
        1'd1: MemRD_out = {{16{MemRD_in[31]}},MemRD_in[31:16]};
        endcase
    LW: MemRD_out = MemRD_in;
    LBU: 
        case(Addr)
        2'd0: MemRD_out = {24'b0,MemRD_in[7:0]};
        2'd1: MemRD_out = {24'b0,MemRD_in[15:8]};
        2'd2: MemRD_out = {24'b0,MemRD_in[23:16]};
        2'd3: MemRD_out = {24'b0,MemRD_in[31:24]};
        endcase
    LHU: 
        case(Addr[1])
        1'd0: MemRD_out = {16'b0,MemRD_in[15:0]};
        1'd1: MemRD_out = {16'b0,MemRD_in[31:16]};
        endcase
    default: MemRD_out=MemRD_in;
    endcase
end
endmodule