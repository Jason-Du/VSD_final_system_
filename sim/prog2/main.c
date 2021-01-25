//unsigned int *copy_addr; // = &_test_start;
//unsigned int copy_count = 0;
unsigned int *cnn_answer_addr; // = &_test_start;
unsigned int cnn_count = 0;
unsigned int cnn_intial = 0;
const unsigned int img_size = 3072;
//const unsigned int sensor_size = 64;
//volatile unsigned int *sensor_addr = (int *) 0x10000000;
volatile unsigned int *cnn_addr = (int *) 0xd0000000;
volatile unsigned int *dma_addr = (int *) 0xf0000000;
volatile unsigned int *cpu_addr = (int *) 0xc0000000;   
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {
//decide which interrupt first in this part

	int choose;
	choose=cpu_addr[0x00];  
	if(choose==1){		
		if(cnn_intial==0){ //remaining weight
			dma_addr[0x0] = 1; // dma start bias	
			dma_addr[0x1] = 0x20204d40;//source 
			dma_addr[0x2] = 0xd4440000;//dest
			dma_addr[0x4] = 7;//len(-1)  
			cnn_intial++;
		}
		else if(cnn_intial==1){
			//for moving picture to trigger dma
			dma_addr[0x0] = 2; // dma start img
			dma_addr[0x1] = 0x20207ca4+((img_size*4)*(cnn_intial-1));
			dma_addr[0x2] = 0xd5550000;
			dma_addr[0x4] = 3071;
			cnn_intial++;
		}
		else{
			dma_addr[0x0] = (cnn_intial==901)?2:1; // dma start take result
			dma_addr[0x1] = cnn_addr;
			dma_addr[0x2] = cnn_answer_addr;
			dma_addr[0x4] = 3;
			cnn_intial++;
			cnn_addr=(int)cnn_addr+1;
			cnn_answer_addr=cnn_answer_addr+4;
			cnn_count=(cnn_intial==902)?1:0;
		}
		
		if (cnn_count == 1) {
			asm("li t6, 0x80");
			asm("csrc mstatus, t6"); // Disable MPIE of mstatus
		}
		return;
	}

	if(choose==4){
		//clear cnn interrupt signal
		cnn_addr[0x4000] = 1;
		cnn_addr[0x4000] = 0;
		//cnn to take answer to other place to save
		dma_addr[0x0] = 1; // dma start img
		dma_addr[0x1] = cnn_addr;
		dma_addr[0x2] = cnn_answer_addr;
		dma_addr[0x4] = 3;
		cnn_intial++;
		cnn_addr=(int)cnn_addr+1;
		cnn_answer_addr=cnn_answer_addr+4;
		return;
	}
}

int main(void) {
  
  cnn_answer_addr = (int*)0x2020E000;

  
  
  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x800");
  asm("csrs mie, t6"); // MEIE of mie 

  //-------------cnn initial----------------//

  dma_addr[0x0] = 1; // dma start weight
  dma_addr[0x1] = 0x20200000;
  dma_addr[0x2] = 0xd3330000;
  dma_addr[0x4] = 215;//total : one conv layer


  while (cnn_count != 1) {
    asm("wfi");
  }

  asm("li t3, 0x2021183C");
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
