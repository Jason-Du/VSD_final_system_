// INPUT 
#define image_size_x  32
#define image_size_y  32

//CONV 1
#define Conv1_size_x  3
#define Conv1_size_y  3
#define Conv1_input_channel  3
#define Conv1_kernel_number  8

// CONV 1-output
#define Conv1_output_size_x  30
#define Conv1_output_size_y  30
#define Conv1_output_channel  8

//CONV2
#define Conv2_size_x  3
#define Conv2_size_y  3
#define Conv2_input_channel  8
#define Conv2_kernel_number  8

// CONV2-output
#define Conv2_output_size_x  28
#define Conv2_output_size_y  28
#define Conv2_output_channel  8

// MAXPOOILNG
#define Pooling1_stride  2
#define Pooling1_size_x  2
#define Pooling1_size_y  2

#define Pooling1_output_width  14
#define Pooling1_output_height  14
#define Pooling1_output_channel  8

//FLATTEN
#define Flatten_input_width 14
#define Flatten_input_height 14
#define Flatten_input_channel 8

#define Flatten_length  1568

//DENSE 1
#define Dense1_input  1568
#define Dense1_output 5


unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;


extern unsigned int _test_start;
const unsigned int initialAddr = 35;








/*****************************************************************
 * Function: for cnn computing                   *
 * Description: 					       *
 *                                                               *
 *****************************************************************/
int relu(int x)
{
    int temp=x&0b00000000000000001000000000000000;
	
    if (temp!= 0b00000000000000001000000000000000)
        return x;
    else
        return 0;
}


int fixpoint_mult(int x)
{
    x = x & 0X3FFFC00;
    x = x >> 10;
    return x;
}
int fixpoint(int x)
{
    x = x & 0X0000FFFF;
    return x;
}
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


int main(void) {


int addr = 0;

// 宣告區
// input

int image[image_size_x][image_size_y][3];

// CONV 1
int C1_wights    [Conv1_size_x][Conv1_size_y][Conv1_input_channel][Conv1_kernel_number];
int C1_bias      [Conv1_kernel_number] ;
int C1_output    [Conv1_output_size_x][Conv1_output_size_y][Conv1_output_channel] ;


const unsigned int* image_addr =   (int*)0x20009C40;

addr=0;

for (int k = 0; k < image_size_x; k++)
    {
        for (int m = 0; m < image_size_y; m++)
        {
            for (int j = 0; j < 3; j++)//channel
            {
              image[m][k][j] = image_addr[addr];	
	   
               addr = addr + 1;
            }
        }
    }


   //cout << "----------------image load----------------" << endl;



const unsigned int* weights_addr = (int*)0x2000EA60;

addr=0;



    for (int m = 0; m < Conv1_size_y; m++)
    {
        for (int k = 0; k < Conv1_size_x; k++) 
        {
            for (int i = 0; i < Conv1_input_channel; i++)
            {
                for (int j = 0; j < Conv1_kernel_number; j++)
                {
                  C1_wights[k][m][i][j]=weights_addr[addr];			   	  
                    addr = addr + 1;
                }
            }
        }

    }


    //cout << "----------------CONV1 weights load----------------" << endl;
const unsigned int* bias_addr =    (int*)0x2000EBF0;
addr=0;

    for (int j = 0; j < Conv1_kernel_number; j++)
    {
        C1_bias[j]= bias_addr[addr];
        addr = addr + 1;
    }





int temp = 0;
addr=0;

for (int j = 0; j < Conv1_kernel_number; j++) //kernel number
    {
        for (int y = 0; y < Conv1_output_size_y; y++) //image y 
        {
            for (int x = 0; x < Conv1_output_size_x; x++)  //image x 卷積完 (30x30)
            {
                temp = 0;
                for (int i = 0; i < Conv1_input_channel; i++) //image channel                                          
                {
                    for (int conv_y = 0; conv_y < Conv1_size_y; conv_y++) // conv y    
                    {
                        for (int conv_x = 0; conv_x < Conv1_size_x; conv_x++) //conv x  
                        {


			temp = temp + fixpoint_mult(image[x + conv_x][y + conv_y][i] * C1_wights[conv_x][conv_y][i][j]);
			
                        }
                    }
                }

		*(&_test_start+addr) =fixpoint(relu(temp + C1_bias[j]));
		addr = addr + 1;	
	
            }
        }

    }

addr=addr+2;

for (int k = 0; k < image_size_x; k++)
    {
        for (int m = 0; m < image_size_y; m++)
        {
            for (int j = 0; j < 3; j++)//channel
            {
              *(&_test_start+addr) =image[m][k][j] ;	
	   
               addr = addr + 1;
            }
        }
    }



  return 0;
}
