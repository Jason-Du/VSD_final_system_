//================================================
// Auther:      SHI XUAN ZHENG
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     2.0
// When giving address "index" to the array, data "TA_out/DA_out" could output immediately.
// However, while the address "index" changes, data "TA_out/DA_out" remain for one cycle.
// ------- 20201116 -------
// use AXI and change len to get data // reduce cycles
// ------- 20201218 -------
// STATE_READSYS: change the WaitStateCtrLoad
// and count
// ------- 20201222 --------
// delete write part
// ------- 20210106 ------
// remove case default
//================================================
`include "def.svh"
`include "counter.sv"
`include "DA_process.sv"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] I_out,
  input I_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic I_req,
  output logic [`DATA_BITS-1:0] I_addr,
  output logic I_write,
  output [`DATA_BITS-1:0] I_in,
  output [`CACHE_TYPE_BITS-1:0] I_type
);

  bit [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;

//--------------- complete this part by yourself -----------------//

logic [`CACHE_TAG_BITS-1:0] tag; //22 bits
logic [1:0] block_offset;
// logic [1:0] byte_offset;
logic [`DATA_BITS-1:0] Rdata;
logic hit;
logic cpu_read;
// logic cpu_write;
logic [`DATA_BITS-1:0] Rdata_block; //32b
//logic [7:0] Rdata_byte; //8b    
logic [3:0] state;
logic [3:0] Nstate;
logic [1:0] count;
logic WaitStateCtrLoad;
logic WaitStateCtrCarry;
// logic [`CACHE_DATA_BITS-1:0] DA_in_tmp;
// logic [`CACHE_WRITE_BITS-1:0] DA_write_tmp;
logic [31:0] core_out_last;

assign tag = core_addr[31:10];
assign index = (rst)?`CACHE_INDEX_BITS'd0:core_addr[9:4];
assign block_offset = core_addr[3:2];
assign hit = (TA_read&valid[index])?(TA_out==tag):1'b0;
assign cpu_read = core_req & !core_write;
// assign cpu_write = core_req & core_write;

assign I_in = core_in;
assign I_type = core_type;

counter counter_Icache(.rst(rst), 
.clk(clk),
.load(WaitStateCtrLoad),
.carry(WaitStateCtrCarry),
.count(count),
.stop(1'b0) //I_wait
);

/* DA_process DA_process(
.core_in(core_in),
.core_type(core_type),
.offset(core_addr[3:0]),
.DA_in(DA_in_tmp),
.DA_write(DA_write_tmp)
); */

always_ff@ (posedge clk or posedge rst)
begin
  if(rst) begin
    for(integer i=0; i<`CACHE_LINES; i++)
      valid[i] <= 1'b0;
    state <= `STATE_IDLE;
    core_out_last <= 32'b0;      
  end
  else begin
    if(!TA_write)
      valid[index] <= 1'b1;
    else
      valid[index] <= valid[index];
    state <= Nstate;
    core_out_last <= core_out;
  end
end
    
// Next State Logic
always_comb begin
  case(state)
  `STATE_IDLE: begin
      if (cpu_read)
          Nstate = `STATE_READ;
      // else if (cpu_write)
          // Nstate = `STATE_WRITE;
      else  
          Nstate = `STATE_IDLE;
  end
  `STATE_READ: begin
      if (hit)
          Nstate = `STATE_IDLE; 
      else	
          Nstate = `STATE_READSYS;
  end
  `STATE_READSYS: begin
      if(WaitStateCtrCarry)
          Nstate = `STATE_READDATA;
      else
          Nstate = `STATE_READSYS;
  end
  `STATE_READDATA : begin
      Nstate = `STATE_IDLE;
  end
/*   `STATE_WRITE : begin
      if (hit)
          Nstate = `STATE_WRITEHIT;
      else
          Nstate = `STATE_WRITEMISS;
  end
  `STATE_WRITEHIT : begin
      if (!I_wait)
          Nstate = `STATE_WRITEDATA;
      else 
          Nstate = `STATE_WRITEHIT;
  end
  `STATE_WRITEMISS : begin
      if (!I_wait)
          Nstate = `STATE_WRITEDATA;
      else 
          Nstate = `STATE_WRITEMISS;
  end
  `STATE_WRITEDATA : begin
      Nstate = `STATE_IDLE;
  end
 */
  default: begin
      Nstate = `STATE_IDLE;
  end
	endcase
end  

always_comb begin
    case(block_offset)
    2'b00:
        Rdata_block = DA_out[31:0];
    2'b01:
        Rdata_block = DA_out[63:32];
    2'b10:
        Rdata_block = DA_out[95:64];
    2'b11:
        Rdata_block = DA_out[127:96];
    endcase
end

// Output Logic
always_comb begin
    WaitStateCtrLoad = 1'b0;
    case(state) 
    `STATE_IDLE: begin //0
        core_out = core_out_last;
        core_wait = core_req;
        
        I_req = 1'b0;
        I_write = 1'b0;
        I_addr = core_addr;
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end
    `STATE_READ: begin //1
        core_out = (hit)? Rdata_block:core_out_last;
        core_wait = !hit;
        
        I_req = 1'b0;
        I_write = 1'b0;
        I_addr = core_addr;       
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = hit;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = valid[index];
    end
    `STATE_READSYS: begin //3
      core_out = core_out_last;
      core_wait = 1'b1;
      
      I_addr = {core_addr[31:4],4'b0000};
      I_req = 1'b1;
      I_write = 1'b0;
      
      TA_in = tag;
      TA_write = 1'b1;
      TA_read = 1'b0;
      
      DA_read = 1'b0; 
      if(I_wait) begin
        WaitStateCtrLoad = 1'b0;
        DA_in = 128'b0;
        DA_write = 16'hffff;
	TA_write = 1'b1;
      end
      else begin
        WaitStateCtrLoad = 1'b1;
        case(count)
        2'd0: begin
            DA_in = {96'h0,I_out};
            DA_write = 16'hfff0;
            TA_write = 1'b0;
        end    
        2'd1: begin
            DA_in =  {64'h0,I_out,32'h0};
            DA_write = 16'hff0f; 
	    TA_write = 1'b1;
        end
        2'd2: begin
            DA_in =  {32'h0,I_out,64'h0};
            DA_write = 16'hf0ff; 
	    TA_write = 1'b1;
        end
        2'd3: begin
            DA_in =  {I_out,96'h0};
            DA_write = 16'h0fff; 
	    TA_write = 1'b1;
        end
        endcase
      end
    end
    `STATE_READDATA : begin //4
        core_out = Rdata_block;
        core_wait = 1'b0;
        
        I_req = 1'b0;
        I_write = 1'b0;
        I_addr = core_addr; 
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b1;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end
   /*  `STATE_WRITE : begin
        core_out = core_out_last;
        core_wait = 1'b1;
        
        I_req = 1'b0;
        I_write = 1'b1;
        I_addr = core_addr; 
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b1;
    end
    `STATE_WRITEHIT : begin
        core_out = core_out_last;
        core_wait = 1'b1;
        
        I_req = 1'b1;
        I_write = 1'b1;
        I_addr = core_addr; 
        
        DA_in = DA_in_tmp;
        DA_write = DA_write_tmp;//depending on type
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end
    `STATE_WRITEMISS : begin
        core_out = core_out_last;
        core_wait = 1'b1;
        
        I_req = 1'b1;
        I_write = 1'b1;
        I_addr = core_addr; 
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end
    `STATE_WRITEDATA : begin
        core_out = core_out_last;
        core_wait = 1'b0;
        
        I_req = 1'b0;
        I_write = 1'b0;
        I_addr = core_addr;
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end */
    default: begin
        core_out = core_out_last;
        core_wait = core_req;
        
        I_req = 1'b0;
        I_write = 1'b0;
        I_addr = core_addr;
        
        DA_in = 128'b0;
        DA_write = 16'hffff;
        DA_read = 1'b0;
        
        TA_in = 22'b0;
        TA_write = 1'b1;
        TA_read = 1'b0;
    end
	endcase
end  

  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule

