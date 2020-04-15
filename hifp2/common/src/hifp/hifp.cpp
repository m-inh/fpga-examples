#include "hifp/hifp.h"

namespace hifp
{

const int NUMWAVE = 131072; /* Number of samples of PCM data */
const int NUMDWTECO = 4096; /* Number of bits per FPIDs */
const int NUMFRAME = 128;   /* Number of frames of generated FPID data */

const unsigned int ref_fpid[] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    4238158, -689853621, -1641085346, 217062118, -1796367086, 850749608, -716002715, 1588237655,
    720655530, -1588223323, 1468701974, -1171959126, -715674923, 1454026068, 715478378, -1428878683,
    -1777387879, 2016563922, -695792854, 375172249, 1395311942, -1433053910, -1454060887, -1782337963,
    1246387637, 690415301, -896854668, 787305978, -1286247766, -715740636, 1418244937, 1768580460,
    -510810346, 1322719462, 868632200, -1659688411, 1420466519, 715609418, -1449842002, 1415231829,
    1655653674, -1118553412, 1441440085, 715871578, -1437247320, -1252743767, -981103187, -1673742766,
    -1026366579, 389690964, -391555806, -1420473686, 358230613, 1957340501, -1954068916, 1555608914,
    -1564125750, -1454032214, -716002635, 1433053589, 380284239, 976055409, -1553381414, -1558941912,
    -1722703197, 1162520917, 984241500, -1416539478, -447305067, 1378514008, -1449835866, -715478187,
    1521022288, -1433053270, -1923798355, 343581905, -341092953, -1353265507, 355082580, -358001318,
    -1555670859, 1766499593, 1805547817, -212666491, -828975560, 609282225, -714896811, 480927064,
    -88775358, -1937434326, 911505579, -774395161, 1372238109, 1957362133, 1672107356, -1441342676,
    -1238518743, 622947753, -1958016436, 1490588978, -1555740023, 1428859477, 1252742482, -1419424085,
    358230069, 1487459138, -2108320087, 879405269, 1218626900, -1434102230, -1265801043, -1242454379,
    -2028262812, 1503228834, -959804651, 447370320, -1462414422};

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

void verify_fpid(unsigned int *fpid, const unsigned int *ref_fpid)
{
    /* Print meta-data of generated FPID */
    printf("\n");
    printf("---------------------\n");
    printf("Analysis \n\n");
    printf("- Number of samples of PCM data (NUMWAVE)            : %d \n", NUMWAVE);
    printf("- Number of bits per FPIDs (NUMDWTECO)               : %d \n", NUMDWTECO);
    printf("- Number of frames of generated FPID data (NUMFRAME) : %d \n", NUMFRAME);

    /* Print generated FPID */
    printf("\n");
    printf("- Generated FPID:\n");

    for (int i = 0; i < NUMFRAME; i++)
    {
        printf("%d ", fpid[i]);
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
            printf("  - Expected vs Real output: %d - %d \n", ref_fpid[i], fpid[i]);
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
    verify_fpid(fpid, ref_fpid);
    save_fp_to_disk(ofp, fpid);

    return 0;

err:
    return -1;
}

} // namespace hifp
