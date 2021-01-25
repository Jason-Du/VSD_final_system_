# Clear the environment
clear -all

# Analyze design files
# analyze -sv ../src/DMA.sv
analyze -sv ../sim/SRAMcompiler/DMA_sram/dma_sram_rtl.sv
analyze -sv +incdir+../include ../src/DMA.sv

# Analyze SVA file
analyze -sv ../sva/v_dma.sva

# Elaborate design and properties
elaborate -top DMA

# Set up Clock and Reset
clock clk
reset -expression {rst}
#Prove all properties
set_engine_mode {Hp Ht B D Tri}
prove -all
