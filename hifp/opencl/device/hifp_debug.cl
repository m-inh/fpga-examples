#define NUMWAVE   131072 /* Number of samples of PCM data */
#define NUMDWTECO 4096   /* Number of bits per FPIDs */
#define NUMFRAME  128    /* Number of frames of generated FPID data */


__kernel void dwt(
    __global const short int * wave16,
    __global unsigned int *    dwteco
)
{
    int global_id  = get_global_id(0);
    int wave_offset = global_id * 32;

    short int dwteco_tmp[4];

    /* 3-stages HAAR wavelet transform */
    /* 1st round */
    dwteco_tmp[0] = (wave16[wave_offset]     + wave16[wave_offset + 1]) / 2;
    dwteco_tmp[1] = (wave16[wave_offset + 2] + wave16[wave_offset + 3]) / 2;
    dwteco_tmp[2] = (wave16[wave_offset + 4] + wave16[wave_offset + 5]) / 2;
    dwteco_tmp[3] = (wave16[wave_offset + 6] + wave16[wave_offset + 7]) / 2;

    /* 2nd round */
    dwteco_tmp[0] = (dwteco_tmp[0] + dwteco_tmp[1]) / 2;
    dwteco_tmp[1] = (dwteco_tmp[2] + dwteco_tmp[3]) / 2;

    /* 3rd round */
    dwteco_tmp[0] = (dwteco_tmp[0] + dwteco_tmp[1]) / 2;

    dwteco[global_id] = dwteco_tmp[0];
}


__kernel void generate_fpid(
    __global const unsigned int * dwteco,
    __global unsigned int *       fpid
)
{
    int global_id     = get_global_id(0);
    int dwteco_offset = global_id * 32;
    int dwteco_index  = 0;
    int i = 0;

    /* Generate FPID */
    if (global_id < NUMFRAME - 1) {
        for (i=0; i<32; i++) {
            dwteco_index = dwteco_offset + i;
            
            fpid[global_id] <<= 1;
            
            if (dwteco[dwteco_index] > dwteco[dwteco_index + 1]) {
                fpid[global_id] |= 1;
            }
        }
    } else {
        for (i=0; i<31; i++) {
            dwteco_index = dwteco_offset + i;
            
            fpid[global_id] <<= 1;
            
            if (dwteco[dwteco_index] > dwteco[dwteco_index + 1]) {
                fpid[global_id] |= 1;
            }
        }

        fpid[global_id] <<= 1;
    }
}


/* For debug only */
__kernel void generate_fpid_debug(
    __global const unsigned int * dwteco,
    __global unsigned int *       fpid,
    __global unsigned int *       plain_fpid
)
{
    int global_id = get_global_id(0);
    int dwteco_offset = global_id * 32;
    int dwteco_index  = 0;
    int i = 0;

    /* Generate plain FPID */
    for (i=0; i<32; i++) {
        dwteco_index = dwteco_offset + i;
        
        if (dwteco_index < NUMDWTECO - 1) {
            if (dwteco[dwteco_index] > dwteco[dwteco_index + 1]) {
                plain_fpid[dwteco_index] = 1;
            } else {
                plain_fpid[dwteco_index] = 0;
            }
        } else {
            plain_fpid[dwteco_index] = 0;
        }
    }

    /* Compress plain FPID */
    for (i = 0; i < 32; i++)
    {   
        dwteco_index = dwteco_offset + i;
        fpid[global_id] <<= 1;
        fpid[global_id] |= plain_fpid[dwteco_index];
    }
}