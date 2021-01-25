// File: main.c
// First, system checks CPU instructions.
// And then, it uses DMA to move data. 
// Finally, it sorts data in ascending order.

unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;
volatile unsigned int *dma_addr = (int *) 0xf0000000;

extern unsigned int _test_start;
const unsigned int sort_size = 10;
const unsigned int initialAddr = 35;

int j = 0xffffffff;
int k;
int i = 0;
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {
  int i;
  for (i = 0; i < sensor_size; i++) { // Copy data from sensor controller to DM
    *(copy_addr + i) = sensor_addr[i];
  }
  copy_addr += sensor_size; // Update copy address
  copy_count++;    // Increase copy count
  sensor_addr[0x80] = 1; // Enable sctrl_clear
  sensor_addr[0x80] = 0; // Disable sctrl_clear
  if (copy_count == 4) {
    asm("li t6, 0x80");
    asm("csrc mstatus, t6"); // Disable MPIE of mstatus
  }
  return;
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
  int test_index = 0;
  // 0 add
  int t0;
  int t1;
  t0 = 0xffffffff;
  t1 = 0xffffffff;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t1 = 0xfffffffe;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  t0 = t0 + t1;
  *(&_test_start+test_index)=t0; //addr = 0x2_0000 
  test_index++;
  
  // 1 sub:
  t0 = 0x00000000;
  t1 = 0xffffffff;
  t0 = t0 - t1;
  t0 = t0 - t1;
  t0 = t0 - t1;
  t0 = t0 - t1;
  t0 = t0 - t1;
  t1 = 0xfffffffd;
  t0 = t1 - t0;
  t0 = t1 - t0;
  t0 = t1 - t0;
  t0 = t1 - t0;
  t0 = t1 - t0;
  *(&_test_start+test_index)=t0; //addr = 0x2_0004 
  test_index++;
  
  // 2 sll:
  t0 = 0x00000001;
  t1 = 0x00000001;
  t0 = t0 << t1;//t0 = 2
  t0 = t0 << t1;//t0 = 2
  t0 = t0 << t1;//t0 = 2
  t0 = t0 << t1;//t0 = 2
  t0 = t0 << t1;//t0 = 2
  t1 = 0x00000002;
  t0 = t1 << t0;//t0 = 2
  t0 = t1 << t0;//t0 = 2
  t0 = t1 << t0;//t0 = 2
  t0 = t1 << t0;//t0 = 2
  t0 = t1 << t0;//t0 = 2
  *(&_test_start+test_index)=t0; //addr = 0x2_0004 
  test_index++;
  
  // 3 slt:
  t0 = 0xffffffff ;//-1
  t1 = 0x00000001 ;//1
  t0 = (t0 < t1)? 1:0;//t0 = 1
  t0 = (t0 < t1)? 1:0;//t0 = 0
  t0 = (t0 < t1)? 1:0;//t0 = 1
  t0 = (t0 < t1)? 1:0;//t0 = 0
  t0 = (t0 < t1)? 1:0;//t0 = 1
  t1 = 0xffffffff ;//-1
  t0 = (t1 < t0)? 1:0; //t0 = 1
  t0 = (t1 < t0)? 1:0; //t0 = 1
  t0 = (t1 < t0)? 1:0; //t0 = 1
  t0 = (t1 < t0)? 1:0; //t0 = 1
  t0 = (t1 < t0)? 1:0; //t0 = 1
  *(&_test_start+test_index)=t0;
  test_index++;

  // 4 sltu:
  t0 = 0xffffffff ;//large positive number
  t1 = 0x00000001 ;//1
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 0
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 1
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 0
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 1
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 0
  t0 = ((unsigned int)t0 < (unsigned int)t1)? 1:0;//t0 = 1
  t1 = 0x00000000 ;//0
  t0 = ((unsigned int)t1 < (unsigned int)t0)? 1:0; //t0 = 1
  t0 = ((unsigned int)t1 < (unsigned int)t0)? 1:0; //t0 = 1
  t0 = ((unsigned int)t1 < (unsigned int)t0)? 1:0; //t0 = 1
  t0 = ((unsigned int)t1 < (unsigned int)t0)? 1:0; //t0 = 1
  t0 = ((unsigned int)t1 < (unsigned int)t0)? 1:0; //t0 = 1
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 5 xor:
  t0 = 0xffffffff;
  t1 = 0xf0f0f0f0;
  t0 = t0 ^ t1    ;//t0 = 0x0f0f0f0f
  t0 = t0 ^ t1    ;//t0 = 0xffffffff
  t0 = t0 ^ t1    ;//t0 = 0x0f0f0f0f
  t0 = t0 ^ t1    ;//t0 = 0xffffffff
  t0 = t0 ^ t1    ;//t0 = 0x0f0f0f0f
  t1 = 0x77777777;
  t0 = t1 ^ t0    ;//t0 = 0x78787878
  t0 = t1 ^ t0    ;//t0 = 0x0f0f0f0f
  t0 = t1 ^ t0    ;//t0 = 0x78787878
  t0 = t1 ^ t0    ;//t0 = 0x0f0f0f0f
  t0 = t1 ^ t0    ;//t0 = 0x78787878
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 6 srl:
  t0 = 0xffffffff;//
  t1 = 0x75eca864;//
  t0 = t0>>t1    ;//t0 = 0x0fffffff
  t0 = t0>>t1    ;//t0 = 0x00ffffff
  t0 = t0>>t1    ;//t0 = 0x000fffff
  t0 = t0>>t1    ;//t0 = 0x0000ffff
  t0 = t0>>t1    ;//t0 = 0x00000fff
  t1 = 0x12345678;;//
  t0 = t1>>t0    ;//t0 = 0x00000000
  t0 = t1>>t0    ;//t0 = 0x12345678
  t0 = t1>>t0    ;//t0 = 0x00000012
  t0 = t1>>t0    ;//t0 = 0x0000048d
  t0 = t1>>t0    ;//t0 = 0x000091a2
  *(&_test_start+test_index)=t0;
  test_index++;

  // 7 sra:
  t0 = 0x87654321;
  t1 = 0x00000004;
  t0 = t0>> t1    ;//t0 = 0xf8765432
  t0 = t0>> t1    ;//t0 = 0xff876543
  t0 = t0>> t1    ;//t0 = 0xfff87654
  t0 = t0>> t1    ;//t0 = 0xffff8765
  t0 = t0>> t1    ;//t0 = 0xfffff876
  t1 = 0x77777777;
  t0 = t1>> t0    ;//t0 = 0x000001dd
  t0 = t1>> t0    ;//t0 = 0x00000003
  t0 = t1>> t0    ;//t0 = 0x0eeeeeee
  t0 = t1>> t0    ;//t0 = 0x0001dddd
  t0 = t1>> t0    ;//t0 = 0x00000003
  *(&_test_start+test_index)=t0;
  test_index++;

  // 8 or:
  t0 = 0x12345678 ;//
  t1 = 0xfedcba98 ;//
  t0 = t0|t1     ;//t0 = 0xfefcfef8
  t0 = t0|t1     ;//t0 = 0xfefcfef8
  t0 = t0|t1     ;//t0 = 0xfefcfef8
  t0 = t0|t1     ;//t0 = 0xfefcfef8
  t0 = t0|t1     ;//t0 = 0xfefcfef8
  t1 = 0x62400285 ;//
  t0 = t1|t0     ;//t0 = 0xfefcfefd
  t0 = t1|t0     ;//t0 = 0xfefcfefd
  t0 = t1|t0     ;//t0 = 0xfefcfefd
  t0 = t1|t0     ;//t0 = 0xfefcfefd
  t0 = t1|t0     ;//t0 = 0xfefcfefd
  *(&_test_start+test_index)=t0;
  test_index++;
  // 9 and:
  t0 = 0x12345678;
  t1 = 0xffffffff;
  t0 = t0& t1    ;//t0 = 0x12345678
  t0 = t0& t1    ;//t0 = 0x12345678
  t0 = t0& t1    ;//t0 = 0x12345678
  t0 = t0& t1    ;//t0 = 0x12345678
  t0 = t0& t1    ;//t0 = 0x12345678
  t1 = 0xf0f0f0f0;
  t0 = t1& t0    ;//t0 = 0x10305070
  t0 = t1& t0    ;//t0 = 0x10305070
  t0 = t1& t0    ;//t0 = 0x10305070
  t0 = t1& t0    ;//t0 = 0x10305070
  t0 = t1& t0    ;//t0 = 0x10305070
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 10-14 load:
  t0 = 0xcccccccc;
  int here = test_index;
  *(&_test_start+here)=t0;
  test_index++;
  
  //lb
  signed char tmp_byte;
  tmp_byte = *(&_test_start+here);
  *(&_test_start+test_index)=tmp_byte;
  test_index++;
  
  //lh
  signed short tmp_short;
  tmp_short = *(&_test_start+here);
  *(&_test_start+test_index)=tmp_short;
  test_index++;
  
  //lbu
  unsigned char tmp_byte_u;
  tmp_byte_u = *(&_test_start+here);
  *(&_test_start+test_index)=tmp_byte_u;
  test_index++;
  
  //lh
  unsigned short tmp_short_u;
  tmp_short_u = *(&_test_start+here);
  *(&_test_start+test_index)=tmp_short_u;
  test_index++;

  // 15 addi:
  int t2;
  int t3;
  int t4;
  int t5;
  int t6;
  
  t0 = 0xffffffff;// -1
  t0 = t0+(-1);   // t0 = -2
  t0 = t0+1893 ;// t0 = 0x00000763
  t0 = t0+-1912;// t0 = 0xffffffeb
  t0 = t0+1074 ;// t0 = 0x0000041d
  t0 = t0+-1348;// t0 = 0xfffffed9
  t1 = 0x00000521;/// t1 = 1313
  t2 = t1+-798 ;// t2 = 515
  t3 = t1+315  ;// t3 = 1628
  t4 = t1+1177 ;// t4 = 2490
  t5 = t1+-2047;// t5 = -734
  t6 = t1+-1432;// t6 = -119
  t2 = t2+t3;// t2 = 2143
  t4 = t4+t5;// t4 = 1756
  t0 = t0+t6;// t0 = -414
  t2 = t2+t4;// t2 = 3899
  t0 = t0+t2;// t0 = 0x00000d9d

  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 16 slti:
  t0 = 0xffffffff;// -1
  t0 = (t0< -1   )?1:0;// t0 = 0
  t0 = (t0< 1000 )?1:0;// t0 = 1
  t0 = (t0< -2000)?1:0;// t0 = 0
  t0 = (t0< 1    )?1:0;// t0 = 1
  t0 = (t0< 1111 )?1:0;// t0 = 1
  t1 = 0xfffffc66;// -922
  t2 = (t1<-876 )?1:0;// t2 = 1
  t3 = (t1<555  )?1:0;// t3 = 1
  t4 = (t1<-1996)?1:0;// t4 = 0
  t5 = (t1<0    )?1:0;// t5 = 1
  t6 = (t1<-922 )?1:0;// t6 = 0
  t2 = t2+t3    ;// t2 = 2
  t4 = t4+t5    ;// t4 = 1
  t0 = t0+t6    ;// t0 = 1
  t2 = t2+t4    ;// t2 = 3
  t0 = t0+t2    ;// t0 = 4
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 17 sltiu
  t0 = 0xfffffffe; //large positive number
  t0 = ((unsigned int)t0< (unsigned int)-1   )?1:0 ; //t0 = 1 (< 0xffffffff)
  t0 = ((unsigned int)t0< (unsigned int)1000 )?1:0 ; //t0 = 1
  t0 = ((unsigned int)t0< (unsigned int)-2000)?1:0 ; //t0 = 1
  t0 = ((unsigned int)t0< (unsigned int)-255 )?1:0 ; //t0 = 1
  t0 = ((unsigned int)t0< (unsigned int)1    )?1:0 ; //t0 = 0
  t1 = 0xaaaabbbb; //large positive number
  t2 = ((unsigned int)t1< (unsigned int)-876 )?1:0 ; //t2 = 1
  t3 = ((unsigned int)t1< (unsigned int)555  )?1:0 ; //t3 = 0
  t4 = ((unsigned int)t1< (unsigned int)-1996)?1:0 ; //t4 = 1
  t5 = ((unsigned int)t1< (unsigned int)0    )?1:0 ; //t5 = 0
  t6 = ((unsigned int)t1< (unsigned int)-922 )?1:0 ; //t6 = 1
  t2 = t2+t3; //t2 = 1
  t4 = t4+t5; //t4 = 1
  t0 = t0+t6; //t0 = 1
  t2 = t2+t4; //t2 = 2
  t0 = t0+t2; //t0 = 3
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 18 xori:
  t0 = 0xffffffff;
  t0 = t0^123   ; //t0 = 0xffffff84
  t0 = t0^-1675 ; //t0 = 0x000006f1
  t0 = t0^-831  ; //t0 = 0xfffffa30
  t0 = t0^2033  ; //t0 = 0xfffffdc1
  t0 = t0^1187  ; //t0 = 0xfffff962
  t1 = 0x00000387;// t1 = 903
  t2 = t1^-285  ; //t2 = 0xfffffd64
  t3 = t1^164   ; //t3 = 0x00000323
  t4 = t1^1766  ; //t4 = 0x00000561
  t5 = t1^-1895 ; //t5 = 0xfffffb1e
  t6 = t1^1209  ; //t6 = 0x0000073e
  t2 = t2+t3;// t2 = 0x00000087
  t4 = t4+t5;// t4 = 0x0000007f
  t0 = t0+t6;// t0 = 0x000000a0
  t2 = t2+t4;// t2 = 0x00000106
  t0 = t0+t2;// t0 = 0x000001a6
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 19 ori:
  t0 = 0x00000001;//
  t0 = t0|444   ;//t0 = 0x000001bd
  t0 = t0|1765  ;//t0 = 0x000007fd
  t0 = t0|-291  ;//t0 = 0xfffffffd
  t0 = t0|156   ;//t0 = 0xfffffffd
  t0 = t0|1282  ;//t0 = 0xffffffff
  t1 = 0x00000783;// t1 = 1923
  t2 = t1|285   ;//t2 = 0x0000079f
  t3 = t1|-164  ;//t3 = 0xffffffdf
  t4 = t1|-1766 ;//t4 = 0xffffff9b
  t5 = t1|1895  ;//t5 = 0x000007e7
  t6 = t1|-1209 ;//t6 = 0xffffffc7
  t2 = t2+t3;// t2 = 0x0000077e
  t4 = t4+t5;// t4 = 0x00000782
  t0 = t0+t6;// t0 = 0xffffffc6
  t2 = t2+t4;// t2 = 0x00000f00
  t0 = t0+t2;// t0 = 0x00000ec6
  *(&_test_start+test_index)=t0;
  test_index++;
  
  // 20 andi:
  t0 = 0xabcdef98;//
  t0 = t0&-333 ;//t0 = 0xabcdef90
  t0 = t0&-188 ;//t0 = 0xabcdee00
  t0 = t0&521  ;//t0 = 0x00000200
  t0 = t0&-377 ;//t0 = 0x00000200
  t0 = t0&853  ;//t0 = 0x00000200
  t1 = 0x12345678;//
  t2 = t1&2033 ;//t2 = 0x00000670
  t3 = t1&218  ;//t3 = 0x00000058
  t4 = t1&-316 ;//t4 = 0x12345640
  t5 = t1&1199 ;//t5 = 0x00000428
  t6 = t1&-775 ;//t6 = 0x12345478
  t2 = t2+t3;//t2 = 0x000006c8
  t4 = t4+t5;//t4 = 0x12345a68
  t0 = t0+t6;//t0 = 0x12345678
  t2 = t2+t4;//t2 = 0x12346130
  t0 = t0+t2;//t0 = 0x2468b7a8
  *(&_test_start+test_index)=t0;
  test_index++;

  // 21 slli:
  t0 = 0x0000000a ;//
  t0 = t0<< 2    ;// t0 = 0x00000028
  t0 = t0<< 5    ;// t0 = 0x00000500
  t0 = t0<<7     ;//t0 = 0x00028000
  t0 = t0<<10    ;//t0 = 0x0a000000
  t0 = t0<<6     ;//t0 = 0x80000000
  t1 = 0x1ab23cd4 ;//
  t2 = t1<<15    ;//t2 = 0x1e6a0000
  t3 = t1<<6     ;//t3 = 0xac8f3500
  t4 = t1<<28    ;//t4 = 0x40000000
  t5 = t1<<17    ;//t5 = 0x79a80000
  t6 = t1<<7     ;//t6 = 0x591e6a00
  t2 = t2+t3;// t2 = 0xcaf93500
  t4 = t4+t5;// t4 = 0xb9a80000
  t0 = t0+t6;// t0 = 0xd91e6a00
  t2 = t2+t4;// t2 = 0x84a13500
  t0 = t0+t2;// t0 = 0x5dbf9f00
  *(&_test_start+test_index)=t0;
  test_index++;
//------------------------------------------------  
  // 22 srli:
  t0 = 0xa1b2c3d4;//
  t0 = (unsigned int)t0>>3   ;// t0 = 0x1436587a
  t0 = (unsigned int)t0>>4   ;// t0 = 0x01436587
  t0 = (unsigned int)t0>>6   ;// t0 = 0x00050d96
  t0 = (unsigned int)t0>>11  ;// t0 = 0x00000161
  t0 = (unsigned int)t0>>7   ;// t0 = 0x00000001
  t1 = 0xaabf790c;//
  t2 = (unsigned int)t1>>25  ;// t2 = 0x00000055
  t3 = (unsigned int)t1>>16  ;// t3 = 0x0000aabf
  t4 = (unsigned int)t1>>18  ;// t4 = 0x00002aaf
  t5 = (unsigned int)t1>>27  ;// t5 = 0x00000015
  t6 = (unsigned int)t1>>17  ;// t6 = 0x0000555f
  t2 = t2+t3;// t2 = 0x0000ab14
  t4 = t4+t5;// t4 = 0x00002ac4
  t0 = t0+t6;// t0 = 0x00005560
  t2 = t2+t4;// t2 = 0x0000d5d8
  t0 = t0+t2;// t0 = 0x00012b38
  *(&_test_start+test_index)=t0;
  test_index++;

  // 23 srai:
  t0 = 0xa1b2c3d4;//
  t0 = t0>>5   ;// t0 = 0xfd0d961e
  t0 = t0>>2   ;// t0 = 0xff436587
  t0 = t0>>8   ;// t0 = 0xffff4365
  t0 = t0>>9   ;// t0 = 0xffffffa1
  t0 = t0>>4   ;// t0 = 0xfffffffa
  t1 = 0xaabf790c;//
  t2 = t1>>13  ;// t2 = 0xfffd55fb
  t3 = t1>>8   ;// t3 = 0xffaabf79
  t4 = t1>>9   ;// t4 = 0xffd55fbc
  t5 = t1>>14  ;// t5 = 0xfffeaafd
  t6 = t1>>4   ;// t6 = 0xfaabf790
  t2 = t2+t3;// t2 = 0xffa81574
  t4 = t4+t5;// t4 = 0xffd40ab9
  t0 = t0+t6;// t0 = 0xfaabf78a
  t2 = t2+t4;// t2 = 0xff7c202d
  t0 = t0+t2;// t0 = 0xfa2817b7
  *(&_test_start+test_index)=t0;
  test_index++;

  // delete jalr

  // 24-34 store:
  t0 = 0x0000000f;//  #
  t1 = 0x000000f0;//  #
  t2 = 0x00000f00;//  #
  t3 = 0x0000f000;//  #
  t4 = 0x12345678;//  #
  *(&_test_start+test_index)=t4;
  test_index++;
  *(&_test_start+test_index)=t3;
  test_index++;
  *(&_test_start+test_index)=t2;
  test_index++;
  *(&_test_start+test_index)=t1;
  test_index++;
  *(&_test_start+test_index)=t0;
  test_index++;
  
  t5 = t4;
  
  *((short*)&_test_start+test_index*0x02+0x01)=(short)t5;
  test_index++;
  
  *((char*)&_test_start+test_index*0x04+0x03)=(char)t5;
  test_index++;

  *((short*)&_test_start+test_index*0x02)=(short)t5;
  test_index++;
  
  *((char*)&_test_start+test_index*0x04)=(char)t5;
  test_index++;
  
  *(&_test_start+test_index)=t5;
  test_index++;
  
  t0 = *(&_test_start+test_index-4);
  *(&_test_start+test_index)=t0;

  t1 = *(&_test_start+test_index-5);
  *(&_test_start+test_index)=t1;

  t2 = t1 + t0;
  *(&_test_start+test_index)=t2;
  test_index++;
  
  
  // delete "branch"s
  // delete auipc
  // delete lui
  // delete jal

  // data
  // addr = 0x2_00000+ initialAddr * 0x4 ~ initialAddr+sort_size-1 * 0x4
  while(i < sort_size){
    k = initialAddr + i;  
    *(&_test_start+k) = j;    
    j = j-0x10;
    i = i+1;
  }  
  
  dma_addr[0x0] = 1; // dma start
  dma_addr[0x1] = (int) ((&_test_start)+initialAddr); // dma source = 20000
  dma_addr[0x2] = (int) ((&_test_start)+(initialAddr+sort_size+0x1)); // dma destination
  dma_addr[0x4] = sort_size; // dma lenth 
  
  *(&_test_start+initialAddr+sort_size) = 0x11111111;
  // sort
  int *sort_addr = ((&_test_start)+(initialAddr+sort_size+0x1));
  sort(sort_addr, sort_size);
  
  asm("li t3, 0x201000dc");
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
