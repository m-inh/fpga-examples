#define NUMWAVE   131072 /* Number of samples of PCM data */
#define NUMDWTECO 4096   /* Number of bits per FPIDs */
#define NUMFRAME  128    /* Number of frames of generated FPID data */


__kernel void hifp2(
    __global const short int *  wave16,
    __global unsigned int *     fpid,
    __global unsigned int *     plain_fpid,
    __global unsigned int *     dwt
) 
{
    int g_id = get_global_id(0);

    int dwt_offset = g_id * 32;
    int dwt_index = 0;

    int dwt_tmp[4];

    int wave_offset = g_id * 1024;
    int wave_index = 0;
    int i;

    /* 3-stages HAAR wavelet transform */
    for (i=0; i<32; i++) {
        dwt_index = dwt_offset + i;
        wave_index = wave_offset + (i * 32);

        /* 1st round */
        dwt_tmp[0] = (wave16[wave_index] + wave16[wave_index + 1]) / 2;
        dwt_tmp[1] = (wave16[wave_index + 2] + wave16[wave_index + 3]) / 2;
        dwt_tmp[2] = (wave16[wave_index + 4] + wave16[wave_index + 5]) / 2;
        dwt_tmp[3] = (wave16[wave_index + 6] + wave16[wave_index+ 7]) / 2;

        /* 2nd round */
        dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;
        dwt_tmp[1] = (dwt_tmp[2] + dwt_tmp[3]) / 2;

        /* 3rd round */
        dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;

        dwt[dwt_index] = dwt_tmp[0];
    }

    barrier(CLK_GLOBAL_MEM_FENCE);

    unsigned int local_orientations[32];

    /* Generate plain FPID */
    for (i=0; i<32; i++) {
        dwt_index = dwt_offset + i;
        
        if (dwt_index < NUMDWTECO - 1) {
            if (dwt[dwt_index] > dwt[dwt_index + 1]) {
                local_orientations[i] = 1;
            } else {
                local_orientations[i] = 0;
            }
        } else {
            local_orientations[i] = 0;
        }
    }

    for (i=0; i<32; i++) {
        dwt_index = dwt_offset + i;
        plain_fpid[dwt_index] = local_orientations[i];
    }

    barrier(CLK_GLOBAL_MEM_FENCE);

    /* Compress plain FPID */
    unsigned int temp_fpid = 0;

    for (i = 0; i < 32; i++)
    {   
        dwt_index = dwt_offset + i;
        temp_fpid <<= 1;
        temp_fpid |= plain_fpid[dwt_index];
    }

    fpid[g_id] = temp_fpid;
    
}