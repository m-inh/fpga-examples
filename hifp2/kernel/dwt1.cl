__kernel void dwt1(
    __global const short int *wave16, 
    __global int *dwt_eco1
)
{
    // int dwt_eco1;
    // int dwt_tmp[4];

    // // 1st round
    // dwt_tmp[0] = (wave16[0] + wave16[1]) / 2;
    // dwt_tmp[1] = (wave16[2] + wave16[3]) / 2;
    // dwt_tmp[2] = (wave16[4] + wave16[5]) / 2;
    // dwt_tmp[3] = (wave16[6] + wave16[7]) / 2;

    // // 2nd round
    // dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;
    // dwt_tmp[1] = (dwt_tmp[2] + dwt_tmp[3]) / 2;

    // 3rd round
    // dwt_eco1 = (dwt_tmp[0] + dwt_tmp[1]) / 2;
    dwt_eco1 = (wave16[0] + wave16[1]) / 2;
}
