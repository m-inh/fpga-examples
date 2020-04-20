#define NUMWAVE   131072 /* Number of samples of PCM data */
#define NUMDWTECO 4096   /* Number of bits per FPIDs */
#define NUMFRAME  128    /* Number of frames of generated FPID data */


__kernel void dwt(
    __global const short int *  wave16,
    __global unsigned int *     fpid,
    __global unsigned int *     plain_fpid,
    __global unsigned int *     dwteco
)
{
    int g_id = get_global_id(0);

    int dwteco_offset = g_id * 32;
    int dwteco_index  = 0;

    int dwteco_tmp[4];

    int wave_offset = g_id * 1024;
    int wave_index  = 0;
    int i;

    /* 3-stages HAAR wavelet transform */
    for (i=0; i<32; i++) {
        dwteco_index  = dwteco_offset + i;
        wave_index = wave_offset + (i * 32);

        /* 1st round */
        dwteco_tmp[0] = (wave16[wave_index]     + wave16[wave_index + 1]) / 2;
        dwteco_tmp[1] = (wave16[wave_index + 2] + wave16[wave_index + 3]) / 2;
        dwteco_tmp[2] = (wave16[wave_index + 4] + wave16[wave_index + 5]) / 2;
        dwteco_tmp[3] = (wave16[wave_index + 6] + wave16[wave_index + 7]) / 2;

        /* 2nd round */
        dwteco_tmp[0] = (dwteco_tmp[0] + dwteco_tmp[1]) / 2;
        dwteco_tmp[1] = (dwteco_tmp[2] + dwteco_tmp[3]) / 2;

        /* 3rd round */
        dwteco_tmp[0] = (dwteco_tmp[0] + dwteco_tmp[1]) / 2;

        dwteco[dwteco_index] = dwteco_tmp[0];
    }
}

__kernel void generate_fpid(
    __global const unsigned int * dwteco,
    __global unsigned int *       fpid,
    __global unsigned int *       plain_fpid
)
{
    int g_id = get_global_id(0);

    int dwteco_offset = g_id * 32;
    int dwteco_index  = 0;

    int i;

    unsigned int local_orientations[32];

    /* Generate plain FPID */
    for (i=0; i<32; i++) {
        dwteco_index = dwteco_offset + i;
        
        if (dwteco_index < NUMDWTECO - 1) {
            if (dwteco[dwteco_index] > dwteco[dwteco_index + 1]) {
                local_orientations[i] = 1;
            } else {
                local_orientations[i] = 0;
            }
        } else {
            local_orientations[i] = 0;
        }
    }


    for (i=0; i<32; i++) {
        dwteco_index = dwteco_offset + i;
        plain_fpid[dwteco_index] = local_orientations[i];
    }

    // barrier(CLK_LOCAL_MEM_FENCE);


    /* Compress plain FPID */
    unsigned int temp_fpid = 0;

    for (i = 0; i < 32; i++)
    {   
        dwteco_index = dwteco_offset + i;
        temp_fpid <<= 1;
        temp_fpid |= plain_fpid[dwteco_index];
    }

    fpid[g_id] = temp_fpid;
}