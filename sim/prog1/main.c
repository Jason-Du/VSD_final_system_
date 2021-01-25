unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
//unsigned int boot = 1;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;
volatile unsigned int *dma_addr = (int *) 0xf0000000;
volatile unsigned int *cpu_addr = (int *) 0xc0000000;   
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {
/*  
  int choose;
  choose=cpu_addr[0x00];  
  if(choose==1){
	
	//for future other function to trigger dma
	return;
	
  }
  if(choose==2){
*/

	int i;
	for (i = 0; i < sensor_size; i++) { // Copy data from sensor controller to DM
		*(copy_addr + i) = sensor_addr[i];
	}


	//dma_addr[0x0] = 2; // dma start
	//dma_addr[0x1] = (int)(sensor_addr);
	//dma_addr[0x2] = (int)(copy_addr);
	//dma_addr[0x4] = sensor_size-1;

	//because move data to dma buffer need 2 clock sensor mem reset need 1024 clock
	//it is ok to use dma to move
	
	//decide which interrupt first in this part
	
	copy_addr += sensor_size; // Update copy address
	copy_count++;    // Increase copy count
	sensor_addr[0x80] = 1; // Enable sctrl_clear
	sensor_addr[0x80] = 0; // Disable sctrl_clear
	if (copy_count == 8) {
		asm("li t6, 0x80");
		asm("csrc mstatus, t6"); // Disable MPIE of mstatus
	}
	return;
  //}
}

/*****************************************************************
 * Function: void sort(int *, unsigned int)                                    *
 * Description: Sorting data                                     *
 *****************************************************************/
void sort(int *array, unsigned int size) {
  int i, j;
  int temp;
  for (i = 0; i < size - 1; i++) {
    for (j = i + 1; j < size; j++) {
      if (array[i] > array[j]) {
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
      }
    }
  }

  return;
}

int main(void) {
  extern unsigned int _test_start;
  int *sort_addr = &_test_start;
  int sort_count = 0;
  copy_addr = &_test_start;

  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x800");
  asm("csrs mie, t6"); // MEIE of mie 

  // Enable Sensor Controller
  sensor_addr[0x40] = 1; // Enable sctrl_en

  while (sort_count != 2) {
    while (sort_count == copy_count / 4) { // Sensor controller isn't ready
      // Wait for interrupt of sensor controller
      asm("wfi");
      // Because there is only one interrupt source, we don't need to poll interrupt source
    }

    // Start sorting
    sort(sort_addr, sensor_size * 4);
    sort_addr += sensor_size * 4;
    sort_count++;
  }
  asm("li t5, 0x201007fc");
  asm("csrr t6, mcycleh");
  asm("sw t6, 4(t5)");
  asm("csrr t6, mcycle");
  asm("sw t6, 8(t5)");
  asm("csrr t6, minstreth");
  asm("sw t6, 12(t5)");
  asm("csrr t6, minstret");
  asm("sw t6, 16(t5)");
  return 0;
}
