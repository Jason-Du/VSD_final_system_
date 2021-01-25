#include <stdio.h>
#include <stdlib.h>
void boot(void){
	volatile unsigned int *dma = (int *) 0xf0000000;
	volatile unsigned int *cpu = (int *) 0xc0000000;
	
	extern unsigned int _dram_i_start;//instruction start address in DRAM
	extern unsigned int _dram_i_end;//instruction end address in DRAM
	extern unsigned int _imem_start;//instruction start address in IM
	
	extern unsigned int __sdata_start;//Main_datastart address in DM
	extern unsigned int __sdata_end;//Main_dataend address in DM
	extern unsigned int __sdata_paddr_start;//Main_datastart address in DRAM
	
	extern unsigned int __data_start;//Main_datastart address in DM
	extern unsigned int __data_end;//Main_dataend address in DM
	extern unsigned int __data_paddr_start;//Main_datastart address in DRAM
	
	int i_size;
	int sdata_size;
	int data_size;
	//int i;
	
	i_size=abs(((&_dram_i_end)-(&_dram_i_start)))+1;
	sdata_size=abs(((&__sdata_end)-(&__sdata_start)))+1;
	data_size=abs(((&__data_end)-(&__data_start)))+1;
	/*
	dma[0x0] = 1; // dma start
	dma[0x1] = _dram_i_start;
	dma[0x2] = _imem_start;
	dma[0x4] = i_size;
	
	for(i=0;i<4;i++){
		asm("wfi");
		if(i<3){
			dma[0x0] = 1; // dma start
			dma[0x1] = (i==2)?__sdata_paddr_start:__data_paddr_start;
			dma[0x2] = (i==2)?__sdata_start:__data_start;
			dma[0x4] = (i==2)?sdata_size:data_size;
		}//round3 may not finish
	}
	*/
	//------------another type----------------//
/*	
	int finish=0; 
	
	dma[0x0] = 1; // dma start
	dma[0x1] = (int)&_dram_i_start;
	dma[0x2] = (int)&_imem_start;
	dma[0x4] = i_size;
	while(finish!=1){
		finish=cpu[0x00];
	}
	
	dma[0x0] = 1; // dma start
	dma[0x1] = (int)&__sdata_paddr_start;
	dma[0x2] = (int)&__sdata_start;
	dma[0x4] = sdata_size;
	while(finish!=1){
		finish=cpu[0x00];
	}
	
	dma[0x0] = 1; // dma start
	dma[0x1] = (int)&__data_paddr_start;
	dma[0x2] = (int)&__data_start;
	dma[0x4] = data_size;
	while(finish!=1){
		finish=cpu[0x00];
	}
	
	dma[0x0] = 2; // dma start
	dma[0x1] = 0x201FFFFF;
	dma[0x2] = 0x201FFFFE;
	dma[0x4] = 0;
	
	/////////////////////////////////////////////////
*/
	int i,j,k;
	
	for(i=0;i<i_size;i++){
		*((&_imem_start)+i)=*((&_dram_i_start)+i);
		//_imem_start[i]=_dram_i_start[i];
	}
	
	for(j=0;j<sdata_size;j++){
		//_sdata_start[j]=_sdata_paddr_start[j];
		*((&__sdata_start)+j)=*((&__sdata_paddr_start)+j);
	}
	
	for(k=0;k<data_size;k++){
		//_data_start[k]=_data_paddr_start[k];
		*((&__data_start)+k)=*((&__data_paddr_start)+k);
	}

}
