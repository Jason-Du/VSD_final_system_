unsigned int *copy_addr; // = &_test_start;
extern unsigned int _test_start;
unsigned int interrupt_count=0;
volatile unsigned int *dma_addr = (int *) 0xf0000000;
volatile unsigned int *cpu_addr = (int *) 0xc0000000;   
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {//DRAM->DRAM : 34
	if(interrupt_count==1){
		dma_addr[0x0] = 2; // dma start
		dma_addr[0x1] = (int) &_test_start;
		dma_addr[0x2] = (int) copy_addr;
		dma_addr[0x4] = 33;
	}
	else{//IM->DRAM : 24
		dma_addr[0x0] = 1; // dma start
		dma_addr[0x1] = 0x00010000;
		dma_addr[0x2] = (int) copy_addr;
		dma_addr[0x4] = 23;
		copy_addr+=24;
	}
	
	if (interrupt_count == 1) {
		asm("li t6, 0x80");
		asm("csrc mstatus, t6"); // Disable MPIE of mstatus
	}
	interrupt_count++;
	return;
}

int main(void) {
  copy_addr = &_test_start;

  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x800");
  asm("csrs mie, t6"); // MEIE of mie 


   asm("li t6, 0x00020400");
   asm("addi t5, t6, 0");
   int i=0;
   for(i=0;i<10;i++){
		asm("addi t5, t5, 0x11");
		asm("sw t5, 0(t6)");
		asm("addi t6, t6, 0x4");
   }
   //DM->DRAM : 34
   dma_addr[0x0] = 1; // dma start
   dma_addr[0x1] = 0x00020400;
   dma_addr[0x2] = (int) copy_addr;
   dma_addr[0x4] = 9;
   copy_addr+=10;
	
    while(interrupt_count!=2){ 
      asm("wfi");   
    }


  asm("li t3, 0x2010010c");
  asm("csrr t4, mcycleh");
  asm("sw t4, 4(t3)");
  asm("csrr t4, mcycle");
  asm("sw t4, 8(t3)");
  asm("csrr t4, minstreth");
  asm("sw t4, 12(t3)");
  asm("csrr t4, minstret");
  asm("sw t4, 16(t3)");

  return 0;
}
