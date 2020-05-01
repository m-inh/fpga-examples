#define NUM_WAVE 131072; /* Number of samples of PCM data */
#define NUM_DWT_ECO 4096; /* Number of bits per FPIDs */
#define NUM_FRAME 128;   /* Number of frames of generated FPID data */

#include <stdio.h>
#include <algorithm>

namespace my_utils
{

// void init_ref_dwt(unsigned int *ref_dwt);
// void init_ref_fpid(unsigned int *ref_fpid);

void print_array(int *arr, int n);
void print_array(unsigned int *arr, int n);

double getCurrentTimestamp();

}