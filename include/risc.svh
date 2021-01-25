`ifndef CPU_SVH
`define CPU_SVH

//control_alu
`define ADD 5'd0
`define SUB 5'd1
`define SLU 5'd2
`define SLTS 5'd3
`define SLTU 5'd4
`define XOR 5'd5
`define SRU 5'd6
`define SRS 5'd7
`define OR 5'd8
`define AND 5'd9
//add alu signal for CSR
`define CSRRW 5'b10000
`define CSRRS 5'b10001
`define CSRRC 5'b10010
`define CSRRWI 5'b10011
`define CSRRSI 5'b10100
`define CSRRCI 5'b10101

`define BEQ 5'b01011
`define BNE 5'b01100
`define BLT 5'b01101
`define BGE 5'b01110
`define BLTU 5'b01111
`define BGEU 5'b01010

//opcode
`define NOP 7'b0000000
`define R 7'b0110011
`define I_lwlb 7'b0000011
`define I_other 7'b0010011
`define I_jalr 7'b1100111
`define S_swsb 7'b0100011
`define B 7'b1100011
`define U_auipc 7'b0010111
`define U_lui 7'b0110111
`define J_jal 7'b1101111
`define CSR 7'b1110011

`endif
