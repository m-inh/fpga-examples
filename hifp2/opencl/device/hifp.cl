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

    int dwt_tmp[4];

    int wave_offset;
    int i;

    /* 3-stages HAAR wavelet transform */
    for (i=0; i<32; i++) {
        wave_offset = g_id * i * 32;

        /* 1st round */
        dwt_tmp[0] = (wave16[wave_offset] + wave16[wave_offset + 1]) / 2;
        dwt_tmp[1] = (wave16[wave_offset + 2] + wave16[wave_offset + 3]) / 2;
        dwt_tmp[2] = (wave16[wave_offset + 4] + wave16[wave_offset + 5]) / 2;
        dwt_tmp[3] = (wave16[wave_offset + 6] + wave16[wave_offset+ 7]) / 2;

        /* 2nd round */
        dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;
        dwt_tmp[1] = (dwt_tmp[2] + dwt_tmp[3]) / 2;

        /* 3rd round */
        dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;

        dwt[dwt_offset + i] = dwt_tmp[0];
    }

    barrier(CLK_GLOBAL_MEM_FENCE);

    int dwt_index = 0;
    unsigned int local_orientations[32];

    /* Generate plain FPID */
    for (i=0; i<32; i++) {
        dwt_index = dwt_offset + i;
        
        if (dwt_index < NUMDWTECO - 1) {
            if (dwt[dwt_index] < dwt[dwt_index + 1]) {
                local_orientations[i] = 1;
            } else {
                local_orientations[i] = 0;
            }
        } else {
            local_orientations[i] = 0;
        }
    }

    barrier(CLK_GLOBAL_MEM_FENCE);

    /* Compress plain FPID */
    unsigned int temp_fpid = 0;
    int plain_fpid_index = 0;

    for (i = 0; i < 32; i++)
    {   
        temp_fpid <<= 1;
        plain_fpid_index = dwt_offset + i;
        
        if (plain_fpid_index < NUMDWTECO - 1) {
            if (plain_fpid[plain_fpid_index] > plain_fpid[plain_fpid_index + 1])
            {
                temp_fpid |= 1;
            }
        }
    }

    fpid[g_id] = temp_fpid;
}