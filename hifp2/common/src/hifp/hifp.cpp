#include "hifp/hifp.h"

namespace hifp
{

const int NUMWAVE = NUM_WAVE;
const int NUMDWTECO = NUM_DWT_ECO;
const int NUMFRAME = NUM_FRAME;

const unsigned int ref_fpid[] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    4238158, 3605113675, 2653881950, 217062118, 2498600210, 850749608, 3578964581, 1588237655,
    720655530, 2706743973, 1468701974, 3123008170, 3579292373, 1454026068, 715478378, 2866088613,
    2517579417, 2016563922, 3599174442, 375172249, 1395311942, 2861913386, 2840906409, 2512629333,
    1246387637, 690415301, 3398112628, 787305978, 3008719530, 3579226660, 1418244937, 1768580460,
    3784156950, 1322719462, 868632200, 2635278885, 1420466519, 715609418, 2845125294, 1415231829,
    1655653674, 3176413884, 1441440085, 715871578, 2857719976, 3042223529, 3313864109, 2621224530,
    3268600717, 389690964, 3903411490, 2874493610, 358230613, 1957340501, 2340898380, 1555608914,
    2730841546, 2840935082, 3578964661, 1433053589, 380284239, 976055409, 2741585882, 2736025384,
    2572264099, 1162520917, 984241500, 2878427818, 3847662229, 1378514008, 2845131430, 3579489109,
    1521022288, 2861914026, 2371168941, 343581905, 3953874343, 2941701789, 355082580, 3936965978,
    2739296437, 1766499593, 1805547817, 4082300805, 3465991736, 609282225, 3580070485, 480927064,
    4206191938, 2357532970, 911505579, 3520572135, 1372238109, 1957362133, 1672107356, 2853624620,
    3056448553, 622947753, 2336950860, 1490588978, 2739227273, 1428859477, 1252742482, 2875543211,
    358230069, 1487459138, 2186647209, 879405269, 1218626900, 2860865066, 3029166253, 3052512917,
    2266704484, 1503228834, 3335162645, 447370320, 2832552874};

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

    for (int i = 0, j = 0; j < NUMDWTECO - 1; i += 32, j += 1)
    {
        r = readwav8(ifp, &wav_data[i], wave_header.NumChannel);
        ASSERT(r == 0);
    }

    return 0;
err:
    return -1;
}

int gen_fpid(short int *wave16, unsigned int *fpid)
{
    int dwt_eco[NUMDWTECO];
    memset(dwt_eco, 0, sizeof(dwt_eco));

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

    /* initialize all array elements to zero */
    memset(wave16, 0, sizeof(wave16));
    memset(fpid, 0, sizeof(fpid));

    /* run all */
    wave_header = read_wave_header(ifp);
    read_wav_data(ifp, wave16, wave_header);
    gen_fpid(wave16, fpid);
    verify_fpid(fpid);
    save_fp_to_disk(ofp, fpid);

    return 0;

err:
    return -1;
}

} // namespace hifp
