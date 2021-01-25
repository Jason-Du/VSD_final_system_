`timescale 1ns/10ps
`define CYCLE 12.0 // Cycle time
`define MAX 125000000 // Max cycle number
`define		PIC1_GOLDEN_FILE_LAYER1		{prog_path, "/top_data/PIC1_CORRECT_LAYER1.data"}
`define		PIC1_GOLDEN_FILE_LAYER7		{prog_path, "/top_data/PIC1_CORRECT_LAYER7.data"}
`define		PIC2_GOLDEN_FILE_LAYER1	  {prog_path, "/top_data/PIC2_CORRECT_LAYER1.data"}
`define		PIC2_GOLDEN_FILE_LAYER7		{prog_path, "/top_data/PIC2_CORRECT_LAYER7.data"}
`define		RESULT_FILE		    "RESULT.csv"

`ifdef SYN2
`include "top_syn_layer1.v"
`include "SRAM/SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "SRAMcompiler/DMA_sram/dma_sram.v"
// CNN SRAM
`include "SRAMcompiler/pixel/pixel_sram.v"
`include "SRAMcompiler/layer1/layer1_sram.v"
`include "SRAMcompiler/layer3/layer3_sram.v"
`include "SRAMcompiler/layer4/layer4_sram.v"
`include "SRAMcompiler/word64/word64.v"
`include "SRAMcompiler/word72/word72.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif SYN
`include "top_syn.v"
`include "SRAM/SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "SRAMcompiler/DMA_sram/dma_sram.v"
// CNN SRAM
`include "SRAMcompiler/pixel/pixel_sram.v"
`include "SRAMcompiler/layer1/layer1_sram.v"
`include "SRAMcompiler/layer3/layer3_sram.v"
`include "SRAMcompiler/layer4/layer4_sram.v"
`include "SRAMcompiler/word64/word64.v"
`include "SRAMcompiler/word72/word72.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif PR
`include "top_pr.v"
`include "SRAM/SRAM.v"
`include "data_array/data_array.v"
`include "tag_array/tag_array.v"
`include "SRAMcompiler/DMA_sram/dma_sram.v"
// CNN SRAM
`include "SRAMcompiler/pixel/pixel_sram.v"
`include "SRAMcompiler/layer1/layer1_sram.v"
`include "SRAMcompiler/layer3/layer3_sram.v"
`include "SRAMcompiler/layer4/layer4_sram.v"
`include "SRAMcompiler/word64/word64.v"
`include "SRAMcompiler/word72/word72.v"
`timescale 1ns/10ps
`include "/usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog/fsa0m_a_generic_core_21.lib"
`elsif prog6
`include "top.sv"
`include "SRAM/SRAM_rtl.sv"
`include "data_array/data_array_rtl.sv"
`include "tag_array/tag_array_rtl.sv"
`include "SRAMcompiler/DMA_sram/dma_sram_rtl.sv"
// CNN SRAM
`include "SRAMcompiler/pixel/pixel_sram_rtl.sv"
`include "SRAMcompiler/layer1/layer1_sram_rtl.sv"
`include "SRAMcompiler/layer3/layer3_sram_rtl.sv"
`include "SRAMcompiler/layer4/layer4_sram_rtl.sv"
`include "SRAMcompiler/word64/word64_rtl.sv"
`include "SRAMcompiler/word72/word72_rtl.sv"
`else
`include "top_layer1.sv"
`include "SRAM/SRAM_rtl.sv"
`include "data_array/data_array_rtl.sv"
`include "tag_array/tag_array_rtl.sv"
`include "SRAMcompiler/DMA_sram/dma_sram_rtl.sv"
// CNN SRAM
`include "SRAMcompiler/pixel/pixel_sram_rtl.sv"
`include "SRAMcompiler/layer1/layer1_sram_rtl.sv"
`include "SRAMcompiler/layer3/layer3_sram_rtl.sv"
`include "SRAMcompiler/layer4/layer4_sram_rtl.sv"
`include "SRAMcompiler/word64/word64_rtl.sv"
`include "SRAMcompiler/word72/word72_rtl.sv"
`endif

`timescale 1ns/10ps
`include "ROM/ROM.v"
`include "DRAM/DRAM.sv"
`include "def.svh"

`ifdef prog6
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
  TOP.DM1.i_SRAM.Memory_byte2[addr], \
  TOP.DM1.i_SRAM.Memory_byte1[addr], \
  TOP.DM1.i_SRAM.Memory_byte0[addr]}
`define TEST_START 'h40000
`else
`define mem_word(addr) \
  {TOP.DM1.i_SRAM.Memory_byte3[addr], \
  TOP.DM1.i_SRAM.Memory_byte2[addr], \
  TOP.DM1.i_SRAM.Memory_byte1[addr], \
  TOP.DM1.i_SRAM.Memory_byte0[addr]}
`define TEST_START 'h40000
`define TEST_START_PROG2 'h83800//2020E000
`endif
`define dram_word(addr) \
  {i_DRAM.Memory_byte3[addr], \
  i_DRAM.Memory_byte2[addr], \
  i_DRAM.Memory_byte1[addr], \
  i_DRAM.Memory_byte0[addr]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1

module top_tb;

	logic clk;
	logic rst;
	logic [31:0] GOLDEN[300000];
	logic [127:0] GOLDEN_cnn[300000];
	logic [31:0]predict_GOLDEN[300000];
	logic [7:0] Memory_byte0[839500];
	logic [7:0] Memory_byte1[839500];
	logic [7:0] Memory_byte2[839500];
	logic [7:0] Memory_byte3[839500];
	//HW4
	logic [31:0] ROM_out;
	logic sensor_ready;
	logic [31:0] sensor_out;
	logic [31:0] DRAM_Q;
	logic ROM_enable;
	logic ROM_read;
	logic [31:0] ROM_address;
	logic sensor_en;
	logic DRAM_CSn;
	logic [3:0]DRAM_WEn;
	logic DRAM_RASn;
	logic DRAM_CASn;
	logic [10:0] DRAM_A;
	logic [31:0] DRAM_D; 
	logic DRAM_valid;

	logic [31:0] sensor_mem [0:511];  
	logic [8:0] sensor_counter;
	logic [9:0] data_counter;  
	//-----------------CNN------------------//
	//for whole CNN
	logic STAGE7_COMPLETE;
	integer picture_layer7=1;
	logic [159:0] result_reg7;
	//for one layer Convolution
	logic STAGE1_COMPLETE;
	logic [ 128-1:0] result_reg1;
	logic [127:0]layer1_result;
	integer picture_layer1=1;

	integer row=0;
	integer col=0;
	integer pass_count=0;
	integer fp_r, fp_w, cnt,p_err,p_num,pf,k,j;
	string classes;
	int FAIL_FLAG=0;
	int memory_index=0;
	int memory_even_even=0;
	int memory_even_odd=0;
	int memory_odd_even=0;
	int memory_odd_odd=0;
	int row_even=0;
	int col_even=0;
	//HW4
	integer gf, i, num;
	logic [31:0] temp;
	integer err;
	string prog_path;
	always #(`CYCLE/2) clk = ~clk;
 

  `ifdef prog6 //1 layer CNN
  
 top TOP(
    .clk(clk),
    .rst(rst),
    .ROM_out(ROM_out),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .DRAM_Q(DRAM_Q),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address),
    .sensor_en(sensor_en),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D),
	.DRAM_valid(DRAM_valid)
  );
  `elsif SYN2 //1 layer CNN
 top TOP(
    .clk(clk),
    .rst(rst),
    .ROM_out(ROM_out),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .DRAM_Q(DRAM_Q),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address),
    .sensor_en(sensor_en),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D),
	.DRAM_valid(DRAM_valid)
  );
  `elsif PR //1 layer CNN
   top TOP(
    .clk(clk),
    .rst(rst),
    .ROM_out(ROM_out),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .DRAM_Q(DRAM_Q),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address),
    .sensor_en(sensor_en),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D),
	.DRAM_valid(DRAM_valid)
  );
`else
  top_layer1 TOP(
    .clk(clk),
    .rst(rst),
    .ROM_out(ROM_out),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .DRAM_Q(DRAM_Q),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address),
    .sensor_en(sensor_en),
    .DRAM_CSn(DRAM_CSn),
    .DRAM_WEn(DRAM_WEn),
    .DRAM_RASn(DRAM_RASn),
    .DRAM_CASn(DRAM_CASn),
    .DRAM_A(DRAM_A),
    .DRAM_D(DRAM_D),
	.DRAM_valid(DRAM_valid)
  );
  `endif

  
  ROM i_ROM(
    .CK(clk),
    .CS(ROM_enable),
    .OE(ROM_read),
    .A(ROM_address[11:0]),
    .DO(ROM_out)
  );  
  
   DRAM i_DRAM(
    .CK(clk), 
    .Q(DRAM_Q),
    .RST(rst),
    .CSn(DRAM_CSn),
    .WEn(DRAM_WEn),
    .RASn(DRAM_RASn),
    .CASn(DRAM_CASn),
    .A(DRAM_A),
    .D(DRAM_D),
	.VALID(DRAM_valid)
  ); 
  
  
  
initial
  begin
    $value$plusargs("prog_path=%s", prog_path);
    clk = 0; rst = 1; sensor_counter = 0; data_counter = 0;
    #(`CYCLE) rst = 0;
    $readmemh({prog_path, "/rom0.hex"}, i_ROM.Memory_byte0);
    $readmemh({prog_path, "/rom1.hex"}, i_ROM.Memory_byte1);
    $readmemh({prog_path, "/rom2.hex"}, i_ROM.Memory_byte2);
    $readmemh({prog_path, "/rom3.hex"}, i_ROM.Memory_byte3);
    $readmemh({prog_path, "/dram0.hex"}, i_DRAM.Memory_byte0);
    $readmemh({prog_path, "/dram1.hex"}, i_DRAM.Memory_byte1);
    $readmemh({prog_path, "/dram2.hex"}, i_DRAM.Memory_byte2);
    $readmemh({prog_path, "/dram3.hex"}, i_DRAM.Memory_byte3);
	
	`ifdef prog2
		num = 0;
		gf = $fopen({prog_path, "/top_data/PIC1_CORRECT_LAYER1.data"}, "r");
		while (!$feof(gf))
		begin
		  $fscanf(gf, "%h\n", GOLDEN_cnn[num]);
		  num++;
		end
		$fclose(gf);
	`elsif prog6
		num = 0;//actual golden number
		p_num=0;//predict golden number
		gf = $fopen({prog_path, "/real.data"}, "r");
		pf = $fopen({prog_path, "/predict.data"}, "r");
		while (!$feof(gf))
		begin
		  $fscanf(gf, "%h\n", GOLDEN[num]);
		  num++;
		end
		while (!$feof(pf))
		begin
		  $fscanf(pf, "%h\n", predict_GOLDEN[p_num]);
		  p_num++;
		end
		$fclose(gf);
		$fclose(pf);
	`else
		num = 0;
		gf = $fopen({prog_path, "/golden.hex"}, "r");
		while (!$feof(gf))
		begin
		  $fscanf(gf, "%h\n", GOLDEN[num]);
		  num++;
		end
		$fclose(gf);
	`endif
		
    `ifdef prog6
      //weight
      $readmemh({prog_path, "/weight_byte0.hex"}, i_DRAM.Memory_byte0,524288);//weight num:3944 //0x2020_0000~2020_4d3c(spare:999)
      $readmemh({prog_path, "/weight_byte1.hex"}, i_DRAM.Memory_byte1,524288);
      $readmemh({prog_path, "/weight_byte2.hex"}, i_DRAM.Memory_byte2,524288);
      $readmemh({prog_path, "/weight_byte3.hex"}, i_DRAM.Memory_byte3,524288);//end:528231+999
      //bias
      $readmemh({prog_path, "/bias_byte0.hex"}, i_DRAM.Memory_byte0,529232);//bias num:42 //0x2020_4d40~0x2020_7ca0(spare:2990)
      $readmemh({prog_path, "/bias_byte1.hex"}, i_DRAM.Memory_byte1,529232);
      $readmemh({prog_path, "/bias_byte2.hex"}, i_DRAM.Memory_byte2,529232);
      $readmemh({prog_path, "/bias_byte3.hex"}, i_DRAM.Memory_byte3,529232);//end:529274+2990
      //pixel
      $readmemh({prog_path, "/pixel_byte0.hex"}, i_DRAM.Memory_byte0,532265);//pixel num:6144 //0x2020_7ca4
      $readmemh({prog_path, "/pixel_byte1.hex"}, i_DRAM.Memory_byte1,532265);
      $readmemh({prog_path, "/pixel_byte2.hex"}, i_DRAM.Memory_byte2,532265);
      $readmemh({prog_path, "/pixel_byte3.hex"}, i_DRAM.Memory_byte3,532265);
	`elsif prog2
      //weight
      $readmemh({prog_path, "/weight_byte0.hex"}, i_DRAM.Memory_byte0,524288);//weight num:3944 //0x2020_0000~2020_4d3c(spare:999)
      $readmemh({prog_path, "/weight_byte1.hex"}, i_DRAM.Memory_byte1,524288);
      $readmemh({prog_path, "/weight_byte2.hex"}, i_DRAM.Memory_byte2,524288);
      $readmemh({prog_path, "/weight_byte3.hex"}, i_DRAM.Memory_byte3,524288);//end:528231+999
      //bias
      $readmemh({prog_path, "/bias_byte0.hex"}, i_DRAM.Memory_byte0,529232);//bias num:42 //0x2020_4d40~0x2020_7ca0(spare:2990)
      $readmemh({prog_path, "/bias_byte1.hex"}, i_DRAM.Memory_byte1,529232);
      $readmemh({prog_path, "/bias_byte2.hex"}, i_DRAM.Memory_byte2,529232);
      $readmemh({prog_path, "/bias_byte3.hex"}, i_DRAM.Memory_byte3,529232);//end:529274+2990
      //pixel
      $readmemh({prog_path, "/pixel_byte0.hex"}, i_DRAM.Memory_byte0,532265);//pixel num:6144 //0x2020_7ca4
      $readmemh({prog_path, "/pixel_byte1.hex"}, i_DRAM.Memory_byte1,532265);
      $readmemh({prog_path, "/pixel_byte2.hex"}, i_DRAM.Memory_byte2,532265);
      $readmemh({prog_path, "/pixel_byte3.hex"}, i_DRAM.Memory_byte3,532265);
    `elsif prog3
      //test_pixel
      $readmemh({prog_path, "/hex_test_image_byte0.hex"}, i_DRAM.Memory_byte0,10000);
      $readmemh({prog_path, "/hex_test_image_byte1.hex"}, i_DRAM.Memory_byte1,10000);
      $readmemh({prog_path, "/hex_test_image_byte2.hex"}, i_DRAM.Memory_byte2,10000);
      $readmemh({prog_path, "/hex_test_image_byte3.hex"}, i_DRAM.Memory_byte3,10000);
      //test_weight
      $readmemh({prog_path, "/hex_Conv1_weights_byte0.hex"}, i_DRAM.Memory_byte0,15000);
      $readmemh({prog_path, "/hex_Conv1_weights_byte1.hex"}, i_DRAM.Memory_byte1,15000);
      $readmemh({prog_path, "/hex_Conv1_weights_byte2.hex"}, i_DRAM.Memory_byte2,15000);
      $readmemh({prog_path, "/hex_Conv1_weights_byte3.hex"}, i_DRAM.Memory_byte3,15000);
      //test_bias
      $readmemh({prog_path, "/hex_Conv1_bias_byte0.hex"}, i_DRAM.Memory_byte0,15100);
      $readmemh({prog_path, "/hex_Conv1_bias_byte1.hex"}, i_DRAM.Memory_byte1,15100);
      $readmemh({prog_path, "/hex_Conv1_bias_byte2.hex"}, i_DRAM.Memory_byte2,15100);
      $readmemh({prog_path, "/hex_Conv1_bias_byte3.hex"}, i_DRAM.Memory_byte3,15100);
    `elsif prog1
      $readmemh({prog_path, "/Sensor_data.dat"}, sensor_mem);
      while (1)
      begin
        #(`CYCLE)
		 if (`mem_word(`SIM_END) == `SIM_END_CODE)
		  begin
			break; 
		  end
        if (sensor_en)
        begin
          if (data_counter == 10'h3ff)
          begin
            sensor_out = sensor_mem[sensor_counter];
            sensor_counter ++;
            sensor_ready = 1'b1;
          end
          else
          begin
            sensor_out = 32'hxxxx_xxxx;
            sensor_ready = 1'b0;
          end
          data_counter ++;
        end
      end	
	`elsif prog1_DMA
      $readmemh({prog_path, "/Sensor_data.dat"}, sensor_mem);
      while (1)
      begin
        #(`CYCLE)
		 if (`mem_word(`SIM_END) == `SIM_END_CODE)
		  begin
			break; 
		  end
        if (sensor_en)
        begin
          if (data_counter == 10'h3ff)
          begin
            sensor_out = sensor_mem[sensor_counter];
            sensor_counter ++;
            sensor_ready = 1'b1;
          end
          else
          begin
            sensor_out = 32'hxxxx_xxxx;
            sensor_ready = 1'b0;
          end
          data_counter ++;
        end
      end
    `endif
	
	`ifdef prog1
	
	`elsif prog1_DMA
	
	`else
    while (1)
    begin
		  #(`CYCLE)
		  if (`mem_word(`SIM_END) == `SIM_END_CODE)
		  begin
        break; 
		  end
		end	
	`endif
	
    $display("\nDone\n");
    err = 0;
	`ifdef prog2
		classes=" ";
		for (i = 0; i < num; i++)
		begin
		  layer1_result={`dram_word(`TEST_START_PROG2 + (i*4)+3),`dram_word(`TEST_START_PROG2 + (i*4)+2),`dram_word(`TEST_START_PROG2 + (i*4)+1),`dram_word(`TEST_START_PROG2 + (i*4))};
		  if (layer1_result !== GOLDEN_cnn[i])
		  begin
			$display("DRAM[%4d~%4d] = %h, expect = %h", `TEST_START_PROG2 + (i*4),(`TEST_START_PROG2 + (i*4)+3), layer1_result, GOLDEN_cnn[i]);
			err = err + 1;
		  end
		  else begin
			$display("DRAM[%4d~%4d] = %h, pass", `TEST_START_PROG2 + (i*4),(`TEST_START_PROG2 + (i*4)+3), layer1_result);
		  end
		end
		result(err, num,classes);
		//----------display total cycle & total instruction-------------------------------// 
		$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START_PROG2 + num*4));
		$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + num*4+1));
		$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + num*4+2));
		$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + num*4+3));
		$finish;
	`elsif prog6
		p_err = 0;
		for (i = 0; i < num; i++)
		begin
		classes="Actual";
		  if (`dram_word(`TEST_START+ i) !== GOLDEN[i])
		  begin
			$display("Predict image class in DRAM[%4d] = %h, Actual image class = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
			err = err + 1;
		  end
		  else begin
			$display("Predict image class in DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
		  end
		end
		result(err, num,classes);
		
		for (k = 0; k < p_num; k++)
		begin
		classes="Predict";
		  if (`dram_word(`TEST_START  + k) !== predict_GOLDEN[k])
		  begin
			$display("Predict image class in DRAM[%4d] = %h, Software predict image class = %h", `TEST_START + k, `dram_word(`TEST_START  + k), predict_GOLDEN[k]);
			p_err = p_err + 1;
		  end
		  else begin
			$display("Predict image class in DRAM[%4d] = %h, pass", `TEST_START  + k, `dram_word(`TEST_START  + k));
		  end
		end
		result(p_err, p_num,classes);
		//----------display total cycle & total instruction-------------------------------// 
		$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START + num));
		$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START + num+1));
		$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START + num+2));
		$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START + num+3));
		$finish;
	`else
	classes=" ";
    for (i = 0; i < num; i++)
    begin
      if (`dram_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DRAM[%4d] = %h, expect = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
      end
    end
    result(err, num,classes);
	//----------display total cycle & total instruction-------------------------------// 
	$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START + num));
	$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START + num+1));
	$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START + num+2));
	$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START + num+3));
    $finish;
	`endif
  end

  `ifdef SYN2
  initial $sdf_annotate("top_syn_layer1.sdf", TOP);
  `elsif SYN
  initial $sdf_annotate("top_syn.sdf", TOP);
  `elsif PR
  initial $sdf_annotate("top_pr.sdf", TOP);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    //$fsdbDumpvars(0, TOP);
    $fsdbDumpvars;
	`elsif FSDB2_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    $fsdbDumpvars("+struct", "+mda", i_DRAM);
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+struct", "+mda", TOP);
    $fsdbDumpvars("+struct", "+mda", i_DRAM);
    `endif
    #(`CYCLE*`MAX)
	`ifdef prog2
		err = 0;
		classes=" ";
		for (i = 0; i < num; i++)
		begin
		  layer1_result={`dram_word(`TEST_START_PROG2 + i+3),`dram_word(`TEST_START_PROG2 + i+2),`dram_word(`TEST_START_PROG2 + i+1),`dram_word(`TEST_START_PROG2 + i)};
		  if (layer1_result !== GOLDEN_cnn[i])
		  begin
			$display("DRAM[%4d~%4d] = %h, expect = %h", `TEST_START_PROG2 + i,(`TEST_START_PROG2 + i+3), layer1_result, GOLDEN_cnn[i]);
			err = err + 1;
		  end
		  else begin
			$display("DRAM[%4d~%4d] = %h, pass", `TEST_START_PROG2 + i,(`TEST_START_PROG2 + i+3), layer1_result);
		  end
		end
		result(err, num,classes);
		//----------display total cycle & total instruction-------------------------------// 
		$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START_PROG2 + num*4));
		$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + (num*4)+1));
		$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + (num*4)+2));
		$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START_PROG2 + (num*4)+3));
		$finish;
	`elsif prog6
		err = 0;
		p_err=0;
		for (i = 0; i < num; i++)
		begin
		classes="Actual";
		  if (`dram_word(`TEST_START + i) !== GOLDEN[i])
		  begin
			$display("Predict image class in DRAM[%4d] = %h, Actual image class = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
			err = err + 1;
		  end
		  else begin
			$display("Predict image class in DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
		  end
		end
		$display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);
		result(err, num,classes);
		
		for (k = 0; k < p_num; k++)
		begin
		classes="Predict";
		  if (`dram_word(`TEST_START + k) !== predict_GOLDEN[k])
		  begin
			$display("Predict image class in DRAM[%4d] = %h, Software predict image class = %h", `TEST_START + k, `dram_word(`TEST_START + k), predict_GOLDEN[k]);
			p_err = p_err + 1;
		  end
		  else begin
			$display("Predict image class in DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + k));
		  end
		end
		$display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);
		result(p_err, p_num,classes);
		//----------display total cycle & total instruction-------------------------------// 
		$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START + num));
		$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START + num+1));
		$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START + num+2));
		$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START + num+3));
		$finish;
	`else
	classes=" ";
    err = 0;
    for (i = 0; i < num; i++)
    begin
      if (`dram_word(`TEST_START + i) !== GOLDEN[i])
      begin
        $display("DRAM[%4d] = %h, expect = %h", `TEST_START + i, `dram_word(`TEST_START + i), GOLDEN[i]);
        err = err + 1;
      end
      else begin
        $display("DRAM[%4d] = %h, pass", `TEST_START + i, `dram_word(`TEST_START + i));
      end
    end
    $display("SIM_END(%5d) = %h, expect = %h", `SIM_END, `mem_word(`SIM_END), `SIM_END_CODE);
    result(err, num,classes);
	//----------display total cycle & total instruction-------------------------------// 
	$display("cycle high 32bits = [ %d ]", `dram_word(`TEST_START + num));
	$display("cycle low 32bits = [ %d ] ", `dram_word(`TEST_START + num+1));
	$display("instruction high 32bits = [ %d ] ", `dram_word(`TEST_START + num+2));
	$display("instruction low 32bits = [ %d ] ", `dram_word(`TEST_START + num+3));
    $finish;
	`endif	
  end
  
  task result;
    input integer err;
    input integer num;
	input string classes;
    integer rf;
    begin
      `ifdef SYN
			rf = $fopen({prog_path, "/result_syn.txt"}, "w");
      `elsif PR
			rf = $fopen({prog_path, "/result_pr.txt"}, "w");
      `else
			rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
		`ifdef prog6
		$display("%s Accuracy is %d %", classes,(num - err)*100/num );
		`endif
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
		`ifdef prog6
		$display("%s Accuracy is %d %", classes,(num - err)*100/num );
		`endif
      end
    end
  endtask
  
	always_ff@(posedge clk)
	begin
		`ifdef prog2
			if(rst)
			begin	
				STAGE1_COMPLETE<=0;
			end
			else
			begin
				STAGE1_COMPLETE<=TOP.CNN_wrapper.CNN_top.layer1_calculation_done;
			end
		`elsif prog6
			if(rst)
			begin	
				STAGE7_COMPLETE<=0;
			end
			else
			begin
				STAGE7_COMPLETE<=TOP.CNN_wrapper.CNN_top.layer7_calculation_done;
			end
		`endif
	end
	
	always
	begin
		#(`CYCLE);
		`ifdef prog2
		if(STAGE1_COMPLETE&&(picture_layer1<=1))
		begin
			$display("PICTURE %d STAGE1_COMPLETE",picture_layer1);
			$display("%d",$time);
			row=0;
			col=0;
			memory_index=0;
			memory_even_even=0;
			memory_even_odd=0;
			memory_odd_even=0;
			memory_odd_odd=0;
			if(picture_layer1==1)
			begin
				fp_r = $fopen(`PIC1_GOLDEN_FILE_LAYER1, "r");
			end
			if(picture_layer1==2)
			begin
				fp_r = $fopen(`PIC2_GOLDEN_FILE_LAYER1, "r");
			end
			while(!$feof(fp_r)) 
			begin
				cnt = $fscanf(fp_r, "%h",result_reg1);			
				if(result_reg1==TOP.CNN_wrapper.CNN_top.layer1_data_mem.layer1_st.i_layer1_sram.Memory[memory_index])
				begin
					pass_count=pass_count+1;
					$display("row[%4d]col[%4d] CORRECT ANSWER:[ %h ] PASS",row,col,result_reg1);
				end
				else
				begin
					$display("row[%4d]col[%4d] CORRECT ANSWER:[ %h ]YOUR ANSWER:[ %h ]",row,col,result_reg1,TOP.CNN_wrapper.CNN_top.layer1_data_mem.layer1_st.i_layer1_sram.Memory[memory_index]);
					FAIL_FLAG=1;
				end
				if(col==`LAYER2_WIDTH-1)
				begin
					col=0;
					row=row+1;
				end
				else
				begin
					col=col+1;
				end
				memory_index++;
			end
			$fclose(fp_r);
			photo(.CORRECT_pass_count(`LAYER2_WIDTH**2),.REAL_pass_count(pass_count),.picture_num(picture_layer1),.STAGE("STAGE1"));
			/*
			if (picture_layer1==1)
			begin
				$finish;
			end
			*/
			
			picture_layer1++;
			//$finish;	
		end
		//////////////////////
	`elsif prog6
		
		pass_count=0;
		if(STAGE7_COMPLETE&&(picture_layer7<=2))
		begin		
			fp_w= $fopen(`RESULT_FILE, "w");
			$fwrite(fp_w,"%h",TOP.CNN_wrapper.CNN_top.result_st_mem.result_mem_out);
			$fclose(fp_w);
			if(picture_layer7==1)
			begin
				fp_r = $fopen(`PIC1_GOLDEN_FILE_LAYER7,"r");
			end
			if(picture_layer7==2)
			begin
				 fp_r = $fopen(`PIC2_GOLDEN_FILE_LAYER7,"r");
			 end
			
			while(!$feof(fp_r)) 
			begin
				cnt = $fscanf(fp_r, "%h",result_reg7);			
				if(result_reg7==TOP.CNN_wrapper.CNN_top.result_st_mem.result_mem_out)
				begin
					pass_count=pass_count+1;
					$display(" ANSWER:[ %h ] PASS",result_reg7);
				end
				else
				begin
					$display("CORRECT ANSWER:[ %h ]YOUR ANSWER:[ %h ]",result_reg7,TOP.CNN_wrapper.CNN_top.result_st_mem.result_mem_out);
					FAIL_FLAG=1;
				end
			end
			$fclose(fp_r);
			photo(.CORRECT_pass_count(1),.REAL_pass_count(pass_count),.picture_num(picture_layer7),.STAGE("STAGE7"));			
			picture_layer7++;
			if(FAIL_FLAG)
			begin
				$finish;
			end
		end
		`endif
end
	
	task photo();
		input int CORRECT_pass_count;
		input int REAL_pass_count;
		input int picture_num;
		input string STAGE;
		$display("PICTURE [%2d] %s COMPLETE",picture_num,STAGE);
		$display("%d",$time);
		if (REAL_pass_count==CORRECT_pass_count)
		begin
			$display("%d PASS",pass_count);
			$display("PICTURE [%2d] %s IS PASS",picture_num,STAGE);
			$display("\n");
			$display("        ****************************               ");
			$display("        **                        **       |\__||  ");
			$display("        **  Congratulations !!    **      / O.O  | ");
			$display("        **                        **    /_____   | ");
			$display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
			$display("        **                        **  |^ ^ ^ ^ |w| ");
			$display("        ****************************   \\m___m__|_|");
			$display("\n");
		end
		else
		begin
			err=CORRECT_pass_count-REAL_pass_count;
			$display("PICTURE [%2d] %s IS FAIL",picture_num,STAGE);
			$display("        ****************************   ");
			$display("        **                        **   ");
			$display("        **  OOPS!!                **   ");
			$display("        **                        **   ");
			$display("        **  Simulation Failed!!   **   ");
			$display("        **                        **   ");
			$display("        ****************************   ");
			$display("                 .   .                 ");
			$display("                . ':' .                ");
			$display("                ___:____     |//\//|   ");
			$display("              ,'        `.    \  /     ");
			$display("              |  O        \___/  |     ");
			$display("~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~");
			$display("         Totally has %d errors ", err); 
			$display("\n");
		end
	endtask

endmodule
