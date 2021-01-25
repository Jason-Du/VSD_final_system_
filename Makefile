root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
pr_dir := ./pr
inc_dir := ./include
inc_dir2 := ./include2
sim_dir := ./sim
vip_dir := $(PWD)/vip
bld_dir := ./build
FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
ifeq ($(FSDB2),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB2),2)
FSDB_DEF := +FSDB2_ALL
endif
CYCLE=`grep -v '^$$' $(root_dir)/sim/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim/MAX`
pend=$(shell grep '[1-2]' $(root_dir)/sim/maxpend)
maxpend :=
ifeq ($(pend),1)
	maxpend := 1
else ifeq ($(pend),2) 
	maxpend := 2
else
	maxpend := 0
endif
$(info maxpend=$(maxpend))

export vip_dir
export maxpend

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(pr_dir):
	mkdir -p $(pr_dir)

# dma sva
dma: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg.tcl -batch

# AXI simulation
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl

# RTL simulation
rtl_all: clean rtl0 rtl0_DMA rtl1 rtl1_DMA rtl2 rtl3 rtl4 rtl5 rtl6

rtl0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0
	
rtl0_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0_DMA

rtl1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1
	
rtl1_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog1_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1_DMA
	
rtl2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
  +incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir2)+$(root_dir)/$(sim_dir) \
	+define+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog2
	
rtl3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
  +incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog3
 
rtl4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog4/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
  +incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
 +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog4$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog4

rtl5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog5/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
  +incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN1 \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog5$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog5
	
rtl6: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog6/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
  +incdir+$(root_dir)/$(src_dir) \
  +incdir+$(root_dir)/$(src_dir)/AXI \
	+incdir+$(root_dir)/$(src_dir)/Cache \
  +incdir+$(root_dir)/$(src_dir)/CPU \
  +incdir+$(root_dir)/$(src_dir)/CNN \
  +incdir+$(root_dir)/$(src_dir)/LocalBuffer \
  +incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog6$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog6
 
# Post-Synthesis simulation
syn_all: clean syn0 syn0_DMA syn1 syn1_DMA syn2 syn3 syn4 syn5 syn6

syn0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0
	
syn0_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog0_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0_DMA

syn1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1
	
syn1_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog1_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1_DMA
 
syn2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog2

syn3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog3

syn4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog4/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog4$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog4
	
syn5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog5/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn_layer1.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN2+prog5$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog5
 
syn6: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog6/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog6$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog6
# Post-Layout simulation
pr_all: clean pr0 pr0_DMA pr1 pr1_DMA pr2 pr3 pr4 pr5 pr6

pr0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0
	
pr0_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog0_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0_DMA

pr1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1
	
pr1_DMA: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1_DMA/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog1_DMA$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1_DMA
	
pr2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog2	

pr3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog3

pr4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog4/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog4$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog4
	
pr5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog5/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog5$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog5
	
pr6: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog6/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog6$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog6
	
# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave top.fsdb &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl

innovus: | $(bld_dir) $(pr_dir)
	cd $(bld_dir); \
	innovus

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean

clean:
	rm -rf $(bld_dir); \
	rm -rf $(sim_dir)/prog*/result*.txt; \
	make -C $(sim_dir)/prog0/ clean; \
	make -C $(sim_dir)/prog1/ clean; \
	make -C $(sim_dir)/prog0_DMA/ clean; \
	make -C $(sim_dir)/prog1_DMA/ clean; \
	make -C $(sim_dir)/prog2/ clean; \
	make -C $(sim_dir)/prog3/ clean; \
	make -C $(sim_dir)/prog4/ clean; \
	make -C $(sim_dir)/prog5/ clean; \
	make -C $(sim_dir)/prog6/ clean; \
