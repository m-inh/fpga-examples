#include "hifp/hifp.h"

namespace hifp
{

const int _PRINT_FPID = PRINT_FPID;
const int _PRINT_PLAIN_FPID = PRINT_PLAIN_FPID;
const int _PRINT_DWT = PRINT_DWT;

const int NUMWAVE = NUM_WAVE;
const int NUMDWTECO = NUM_DWT_ECO;
const int NUMFRAME = NUM_FRAME;

unsigned int ref_fpid[NUMFRAME];
unsigned int ref_dwt_eco[NUMDWTECO];

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

int gen_fpid(short int *wave16, unsigned int *plain_fpid, unsigned int *fpid, unsigned int *dwt_eco)
{
    dwt_eco[0] = dwt1(&wave16[0]);

    for (int i = 32, j = 0, k = 0; j < (NUMDWTECO - 1); j++)
    {
        dwt_eco[j + 1] = dwt1(&wave16[i]);
        fpid[k] <<= 1;
        if (dwt_eco[j] > dwt_eco[j + 1])
        {   
            plain_fpid[j] = 1;
            fpid[k] |= 1;
        }
        if ((j % 32) == 31)
        {
            k++;
        }
        i += 32;
    }

    fpid[NUMFRAME - 1] <<= 1;
    plain_fpid[NUMDWTECO - 1] = 0;

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

void verify_fpid(unsigned int *fpid, unsigned int *plain_fpid, unsigned int *dwt_eco)
{
    /* Initialize reference data */
    init_ref_fpid(ref_fpid);
    init_ref_dwt(ref_dwt_eco);

    /* Print meta-data of generated FPID */
    printf("\n");
    printf("---------------------\n");
    printf("Data Analysis \n\n");
    printf("- Number of samples of PCM data (NUMWAVE)            : %d \n", NUMWAVE);
    printf("- Number of bits per FPIDs (NUMDWTECO)               : %d \n", NUMDWTECO);
    printf("- Number of frames of generated FPID data (NUMFRAME) : %d \n", NUMFRAME);

    /* Print generated FPID */
    if (_PRINT_FPID == 1) {
        printf("\n");
        printf("- Generated FPID:\n");

        for (int i = 0; i < NUMFRAME; i++)
        {
            printf("%u ", fpid[i]);
        }
    }

    /* Print generated FPID */
    if (_PRINT_PLAIN_FPID == 1) {
        printf("\n\n");
        printf("- Generated plain FPID:\n");

        for (int i = 0; i < NUMDWTECO; i++)
        {
            printf("%u ", plain_fpid[i]);
        }
    }

    /* Print generated DWT */
    if (_PRINT_DWT == 1) {
        printf("\n\n");
        printf("- Generated DWT:\n");

        for (int i = 0; i < NUMDWTECO; i++)
        {
            printf("%u ", dwt_eco[i]);
        }
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
            printf("- Diffrent FPID: \n");
            printf("  - Index: %d\n", i);
            printf("  - Expected vs Real output: %u - %u \n", ref_fpid[i], fpid[i]);
            printf("\n");
            // break;
        }
    }

    for (int i = 0; i < NUMDWTECO; i++)
    {
        if (ref_dwt_eco[i] != dwt_eco[i])
        {
            pass = false;
            printf("- Diffrent DWT: \n");
            printf("  - Index: %d\n", i);
            printf("  - Expected vs Real output: %u - %u \n", ref_dwt_eco[i], dwt_eco[i]);
            printf("\n");
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
    unsigned int plain_fpid[NUMFRAME];
    unsigned int dwt_eco[NUMDWTECO];

    /* initialize all array elements to zero */
    memset(wave16, 0, sizeof(wave16));
    memset(fpid, 0, sizeof(fpid));
    memset(plain_fpid, 0, sizeof(plain_fpid));
    memset(dwt_eco, 0, sizeof(dwt_eco));

    /* run all */
    wave_header = read_wave_header(ifp);
    read_wav_data(ifp, wave16, wave_header);
    gen_fpid(wave16, plain_fpid, fpid, dwt_eco);
    verify_fpid(fpid, plain_fpid, dwt_eco);
    save_fp_to_disk(ofp, fpid);

    return 0;

err:
    return -1;
}

} // namespace hifp
