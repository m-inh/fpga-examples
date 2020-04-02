#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

const char *IDIR = "../distorted-wav";
const char *ODIR = "../distorted-fp";

typedef struct {
	/* RIFF Header */
	unsigned int   riff;          /* RIFF */
	unsigned int   size_file;     /* ファイル全体のサイズから8引いたバイト数 */
	unsigned int   wave;          /* WAVE */

	/* fmt Chunk */
	unsigned int   fmt;           /* fmt */
	unsigned int   size_fmt;      /* フォーマットID以降のfmtチャネルのバイト数 */
	unsigned short FormatId;      /* フォーマットID */
	unsigned short NumChannel;    /* チャンネル数 */
	unsigned int   SampleRate;    /* サンプリング周波数 */
	unsigned int   ByteRate;      /* 1sec当たりのサンプリングするバイト数 (byte/sec) */
	unsigned short BlockAlign;    /* 1ブロック当たりのバイト数 */
	unsigned short BitsPerSample; /* 量子化ビット数 */

	/* data Chunk */
	unsigned int   data;           /* DATA */
	unsigned int   size_wave;      /* 波形データのバイト数 */
} WAVEHEADER;

const int NUMWAVE   = 131072;
const int NUMDWTECO =   4096;
const int NUMFRAME  =    128;

#define ERRPRINT(c) do { \
	if (errno == 0) {    \
		printf("%s,%d\n", __FILE__, __LINE__); \
	} else {             \
		printf("%s,%d,%s\n", __FILE__, __LINE__, strerror(errno)); \
	}                    \
} while (0)

#define ASSERT(c) do { \
	if (!(c)) {        \
		ERRPRINT();    \
		goto err;      \
	}                  \
} while (0)

int readwav8(FILE *fp, short int *wave16, unsigned short int numch)
{
	short int buf[16];
	short int dum[48]; // TODO
	size_t rsz;
	int i;

	// WAVデータ読み込み。
	if (numch == 2) {
		rsz = fread(buf, sizeof(short int), 16, fp);
		// ASSERT(rsz == 16);
		for (i = 0; i < 8; i++) {
			wave16[i] = buf[2 * i];
		}
		rsz = fread(dum, sizeof(short int), 48, fp);
		// ASSERT(rsz == 48);
	} else {
		rsz = fread(wave16, sizeof(short int), 8, fp);
		// ASSERT(rsz == 8);
		rsz = fread(dum, sizeof(short int), 24, fp);
		// ASSERT(rsz == 24);
	}

	return 0;

err:
	return -1;
}

int dwt1(short int *wave16)
{
	int dwt_eco1;
	int dwt_tmp[4];

	// 1st round
	dwt_tmp[0] = (wave16[0] + wave16[1]) / 2;
	dwt_tmp[1] = (wave16[2] + wave16[3]) / 2;
	dwt_tmp[2] = (wave16[4] + wave16[5]) / 2;
	dwt_tmp[3] = (wave16[6] + wave16[7]) / 2;

	// 2nd round
	dwt_tmp[0] = (dwt_tmp[0] + dwt_tmp[1]) / 2;
	dwt_tmp[1] = (dwt_tmp[2] + dwt_tmp[3]) / 2;

	// 3rd round
	dwt_eco1 = (dwt_tmp[0] + dwt_tmp[1]) / 2;

	return dwt_eco1;
}

int genfp(FILE *ifp, FILE *ofp)
{
	WAVEHEADER wave_header;
	size_t rsz;
	size_t wsz;
	int i, j, k;
	int r;

	short int wave16[NUMWAVE];
	int dwt_eco[NUMDWTECO];
	unsigned int fpid[NUMFRAME];

	memset(wave16, 0, sizeof(wave16));
	memset(dwt_eco, 0, sizeof(dwt_eco));
	memset(fpid, 0, sizeof(fpid));

	// WAVヘッダー読み込み。
	rsz = fread(&wave_header, sizeof(unsigned int), 5, ifp);
	// ASSERT(rsz == 5);
	rsz = fread(&wave_header.FormatId, sizeof(unsigned short int), 2, ifp);
	// ASSERT(rsz == 2);
	rsz = fread(&wave_header.SampleRate, sizeof(unsigned int), 2, ifp);
	// ASSERT(rsz == 2);
	rsz = fread(&wave_header.BlockAlign, sizeof(unsigned short int), 2, ifp);
	// ASSERT(rsz == 2);
	rsz = fread(&wave_header.data, sizeof(unsigned int), 2, ifp);
	// ASSERT(rsz == 2);
	// ASSERT(memcmp(&wave_header.riff, "RIFF", 4) == 0);
	// ASSERT(memcmp(&wave_header.wave, "WAVE", 4) == 0);
	// ASSERT(memcmp(&wave_header.fmt,  "fmt ", 4) == 0);
	// ASSERT(memcmp(&wave_header.data, "data", 4) == 0);
	// ASSERT(wave_header.BitsPerSample == 16);
	// ASSERT(wave_header.SampleRate == 44100);

	r = readwav8(ifp, &wave16[0], wave_header.NumChannel);
	// ASSERT(r == 0);
	dwt_eco[0] = dwt1(&wave16[0]);
	i = 32;
	k = 0;
	for (j = 0; j < (NUMDWTECO - 1); j++) {
		r = readwav8(ifp, &wave16[i], wave_header.NumChannel);
		// ASSERT(r == 0);
		dwt_eco[j+1] = dwt1(&wave16[i]);
		fpid[k] <<= 1;
		if (dwt_eco[j] > dwt_eco[j+1]) {
			fpid[k] |= 1;
		}
		if ((j % 32) == 31) {
			k++;
		}
		i += 32;
	}
	fpid[NUMFRAME - 1] <<= 1;

	// for (int i=0; i < NUMFRAME; i++) {
	// 	printf("%d ", fpid[i]);
	// }

	int fpLength = sizeof fpid;
	// printf("-----%d---", fpLength);
	// printf("-----NUMFRAME: %d---", NUMFRAME);

	wsz = fwrite(fpid, sizeof(unsigned int), NUMFRAME, ofp);
	// ASSERT(wsz == NUMFRAME);

	return 0;

err:
	return -1;
}

int main(void)
{
	DIR *dir = NULL;
	struct dirent *ep;
	char ifpath[256];
	char ofpath[256];
	FILE *ifp = NULL;
	FILE *ofp = NULL;
	int r;

	dir = opendir(IDIR);

	//printf("%s", dir);
	// ASSERT(dir != NULL);

	while ((ep = readdir(dir)) != NULL) {
		if (ep->d_type == DT_REG) {
			// sprintf(ifpath, "%s/%s", IDIR, ep->d_name);
			sprintf(ifpath, "%s/%s", IDIR, ep->d_name);
			sprintf(ofpath, "%s/%s.raw", ODIR, ep->d_name);

			ifp = fopen(ifpath, "rb+");
			// ASSERT(ifp != NULL);

			ofp = fopen(ofpath, "wb");
			// ASSERT(ifp != NULL);

			r = genfp(ifp, ofp);
			// ASSERT(r == 0);

			fclose(ifp);
			ifp = NULL;

			fclose(ofp);
			ofp = NULL;
		}
	}

	closedir(dir);

	return 0;

err:
	if (ifp != NULL) {
		fclose(ifp);
	}
	if (ofp != NULL) {
		fclose(ofp);
	}
	if (dir != NULL) {
		closedir(dir);
	}
	return 0;
}
