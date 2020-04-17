#include "hifp/hifp.h"

namespace hifp
{

const int NUMWAVE = NUM_WAVE;
const int NUMDWTECO = NUM_DWT_ECO;
const int NUMFRAME = NUM_FRAME;

const unsigned int ref_fpid[] = {
    0,0,0,0,0,0,0,0,0,0,0,4237911,3437835855,984421710,1288723052,2994394416,2477896276,2892647602,3165996717,1441311827,1218892071,866555207,2592805774,1554889074,1800760004,2504436557,1500284116,3425414034,4062517593,1822631524,2337623626,2593493668,3042036299,2460650835,719445161,2739099559,177040971,1688553960,1473685373,1529656660,3937064080,2839697826,3436596026,2964016466,2544323238,2542996769,1447400587,714429102,1297328789,1655346519,706632988,1916625252,4121505182,734939290,962161332,3536505170,1529629525,1427295466,3634255558,1163489962,896871081,3024923696,3651839331,114103579,978728044,2781201093,1449827098,693416677,1691005779,2871350613,2859816106,1297700523,1930880595,726421365,709409698,1262832018,2727699050,2899651257,1453500757,1924486442,3264566810,1427933493,1920521674,3415325348,1427943093,715744614,2305656483,3073291477,3718997814,2325021354,2908039789,1233987927,747972897,3613080147,3063578261,1557328489,289582165,1516935338,1498730153,3986338442,621564564,2796120655,1705891443,2732812365,3579174250,3342146678,1414363544,4079724043,105462450,2778039493,850021017,1368560930,1783977131,359050393,1500158821,1238143255,743729809,543871697,2833601194,2353351340,883075733,1766509207,2545495206,2471322417,1261132618,2506692170,2496473362,1415359188};

int dwt1(short int *wave16)
{
    int dwt_eco1;
    int dwt_tmp[4];

    /* 1st round */
    dwt_tmp[0] = (wave16[0] + wave16[1]) / 2;
    dwt_tmp[1] = (wave16[2] + wave16[3]) / 2;
    dwt_tmp[2] = (wave16[4] + wave16[5]) / 2;
    dwt_tmp[3] = (wave16[6] + wave16[7]) / 2;

    /* 2nd round */
    dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;
    dwt_tmp[1] = (dwt_tmp[2] + dwt_tmp[3]) / 2;

    /* 3rd round */
    dwt_eco1 = (dwt_tmp[0] + dwt_tmp[1]) / 2;

    return dwt_eco1;
}

int readwav8(FILE *fp, short int *wave16, unsigned short int numch)
{
    short int buf[16];
    short int dum[48];
    size_t rsz;
    int i;

    if (numch == 2)
    {
        rsz = fread(buf, sizeof(short int), 16, fp);
        ASSERT(rsz == 16);
        for (i = 0; i < 8; i++)
        {
            wave16[i] = buf[2 * i];
        }
        rsz = fread(dum, sizeof(short int), 48, fp);
        ASSERT(rsz == 48);
    }
    else
    {
        rsz = fread(wave16, sizeof(short int), 8, fp);
        ASSERT(rsz == 8);
        rsz = fread(dum, sizeof(short int), 24, fp);
        ASSERT(rsz == 24);
    }

    return 0;

err:
    return -1;
}

WAVEHEADER read_wave_header(FILE *ifp)
{
    size_t rsz;
    WAVEHEADER wave_header;

    rsz = fread(&wave_header, sizeof(unsigned int), 5, ifp);
    ASSERT(rsz == 5);
    rsz = fread(&wave_header.FormatId, sizeof(unsigned short int), 2, ifp);
    ASSERT(rsz == 2);
    rsz = fread(&wave_header.SampleRate, sizeof(unsigned int), 2, ifp);
    ASSERT(rsz == 2);
    rsz = fread(&wave_header.BlockAlign, sizeof(unsigned short int), 2, ifp);
    ASSERT(rsz == 2);
    rsz = fread(&wave_header.data, sizeof(unsigned int), 2, ifp);
    ASSERT(rsz == 2);
    ASSERT(memcmp(&wave_header.riff, "RIFF", 4) == 0);
    ASSERT(memcmp(&wave_header.wave, "WAVE", 4) == 0);
    ASSERT(memcmp(&wave_header.fmt, "fmt ", 4) == 0);
    ASSERT(memcmp(&wave_header.data, "data", 4) == 0);
    ASSERT(wave_header.BitsPerSample == 16);
    ASSERT(wave_header.SampleRate == 44100);

    return wave_header;

err:
    return wave_header;
}

int read_wav_data(FILE *ifp, short int *wav_data, WAVEHEADER wave_header)
{
    int r;

    for (int i = 0, j = 0; j < NUMDWTECO; i += 32, j += 1)
    {
        r = readwav8(ifp, &wav_data[i], wave_header.NumChannel);
        ASSERT(r == 0);
    }

    return 0;
err:
    return -1;
}

int gen_fpid(short int *wave16, unsigned int *fpid, unsigned int *dwt_eco)
{
    // int dwt_eco[NUMDWTECO];
    // memset(dwt_eco, 0, sizeof(dwt_eco));
    dwt_eco[0] = dwt1(&wave16[0]);

    for (int i = 32, j = 0, k = 0; j < (NUMDWTECO - 1); j++)
    {
        dwt_eco[j + 1] = dwt1(&wave16[i]);
        fpid[k] <<= 1;
        if (dwt_eco[j] > dwt_eco[j + 1])
        {
            fpid[k] |= 1;
        }
        if ((j % 32) == 31)
        {
            k++;
        }
        i += 32;
    }

    fpid[NUMFRAME - 1] <<= 1;

    return 0;
err:
    return -1;
}

int save_fp_to_disk(FILE *ofp, unsigned int *fpid)
{
    size_t wsz;

    wsz = fwrite(fpid, sizeof(unsigned int), NUMFRAME, ofp);
    ASSERT(wsz == NUMFRAME);

    return 0;

err:
    return -1;
}

void verify_fpid(unsigned int *fpid)
{
    /* Print meta-data of generated FPID */
    printf("\n");
    printf("---------------------\n");
    printf("Data Analysis \n\n");
    printf("- Number of samples of PCM data (NUMWAVE)            : %d \n", NUMWAVE);
    printf("- Number of bits per FPIDs (NUMDWTECO)               : %d \n", NUMDWTECO);
    printf("- Number of frames of generated FPID data (NUMFRAME) : %d \n", NUMFRAME);

    /* Print generated FPID */
    printf("\n");
    printf("- Generated FPID:\n");

    for (int i = 0; i < NUMFRAME; i++)
    {
        printf("%u ", fpid[i]);
    }

    printf("\n\n");
    printf("---------------------\n");
    printf("Verfification \n\n");

    /* Verify generated FPID */
    bool pass = true;

    for (int i = 0; i < NUMFRAME; i++)
    {
        if (ref_fpid[i] != fpid[i])
        {
            pass = false;
            printf("- Diffrent: \n");
            printf("  - Index: %d\n", i);
            printf("  - Expected vs Real output: %u - %u \n", ref_fpid[i], fpid[i]);
            printf("\n");
            break;
        }
    }

    printf("- Result: %s", pass == true ? "PASS! 🎉🎉🎉" : "FAILED! 🤕");
    printf("\n");
}

int run_all(FILE *ifp, FILE *ofp)
{
    WAVEHEADER wave_header;
    short int wave16[NUMWAVE];
    unsigned int fpid[NUMFRAME];
    unsigned int dwt_eco[NUMDWTECO];

    /* initialize all array elements to zero */
    memset(wave16, 0, sizeof(wave16));
    memset(fpid, 0, sizeof(fpid));
    memset(dwt_eco, 0, sizeof(dwt_eco));

    /* run all */
    wave_header = read_wave_header(ifp);
    read_wav_data(ifp, wave16, wave_header);
    gen_fpid(wave16, fpid, dwt_eco);
    verify_fpid(fpid);
    save_fp_to_disk(ofp, fpid);

    return 0;

err:
    return -1;
}

} // namespace hifp
