#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

#include "CL/opencl.h"
#include "AOCLUtils/aocl_utils.h"

using namespace aocl_utils;

// OpenCL runtime configuration
std::string binary_file = "dwt1.aocx";
cl_platform_id platform = NULL;
unsigned num_devices = 0;
cl_device_id device;
cl_context context = NULL;
cl_command_queue queue;
cl_program program = NULL;
cl_kernel kernel;
cl_mem input_buf;
cl_mem output_buf;

// problem data
const char *IDIR = "./distorted-wav";
const char *ODIR = "./distorted-fp";
int *input_wav;
int *output_fp;
DIR *dir = NULL;
struct dirent *ep;
char ifpath[256];
char ofpath[256];
FILE *ifp = NULL;
FILE *ofp = NULL;
int r;

// Function prototypes
float rand_float();
bool init_opencl();
void init_problem();
void run();
void cleanup();

typedef struct
{
    /* RIFF Header */
    unsigned int riff;      /* RIFF */
    unsigned int size_file; /* ファイル全体のサイズから8引いたバイト数 */
    unsigned int wave;      /* WAVE */

    /* fmt Chunk */
    unsigned int fmt;             /* fmt */
    unsigned int size_fmt;        /* フォーマットID以降のfmtチャネルのバイト数 */
    unsigned short FormatId;      /* フォーマットID */
    unsigned short NumChannel;    /* チャンネル数 */
    unsigned int SampleRate;      /* サンプリング周波数 */
    unsigned int ByteRate;        /* 1sec当たりのサンプリングするバイト数 (byte/sec) */
    unsigned short BlockAlign;    /* 1ブロック当たりのバイト数 */
    unsigned short BitsPerSample; /* 量子化ビット数 */

    /* data Chunk */
    unsigned int data;      /* DATA */
    unsigned int size_wave; /* 波形データのバイト数 */
} WAVEHEADER;

const int NUMWAVE = 131072;
const int NUMDWTECO = 4096;
const int NUMFRAME = 128;

#define ERRPRINT(c)                                                    \
    do                                                                 \
    {                                                                  \
        if (errno == 0)                                                \
        {                                                              \
            printf("%s,%d\n", __FILE__, __LINE__);                     \
        }                                                              \
        else                                                           \
        {                                                              \
            printf("%s,%d,%s\n", __FILE__, __LINE__, strerror(errno)); \
        }                                                              \
    } while (0)

#define ASSERT(c)       \
    do                  \
    {                   \
        if (!(c))       \
        {               \
            ERRPRINT(); \
            goto err;   \
        }               \
    } while (0)

int readwav8(FILE *fp, short int *wave16, unsigned short int numch)
{
    short int buf[16];
    short int dum[48]; // TODO
    size_t rsz;
    int i;

    // WAVデータ読み込み。
    if (numch == 2)
    {
        rsz = fread(buf, sizeof(short int), 16, fp);
        // ASSERT(rsz == 16);
        for (i = 0; i < 8; i++)
        {
            wave16[i] = buf[2 * i];
        }
        rsz = fread(dum, sizeof(short int), 48, fp);
        // ASSERT(rsz == 48);
    }
    else
    {
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
    for (j = 0; j < (NUMDWTECO - 1); j++)
    {
        r = readwav8(ifp, &wave16[i], wave_header.NumChannel);
        // ASSERT(r == 0);
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

    wsz = fwrite(fpid, sizeof(unsigned int), NUMFRAME, ofp);
    // ASSERT(wsz == NUMFRAME);

    return 0;

err:
    return -1;
}

int main(int argc, char **argv)
{
    // Initialize OpenCL.
    if (!init_opencl())
    {
        return -1;
    }

    // Initialize the problem data.
    // Requires the number of devices to be known.
    init_problem();

    // Run the kernel.
    run();

    // Free the resources allocated
    cleanup();

    return 0;

err:
    if (ifp != NULL)
    {
        fclose(ifp);
    }
    if (ofp != NULL)
    {
        fclose(ofp);
    }
    if (dir != NULL)
    {
        closedir(dir);
    }
    return 0;
}

/////// HELPER FUNCTIONS ///////

// Initializes the OpenCL objects.
bool init_opencl()
{
    cl_int status;

    printf("Initializing OpenCL\n");

    if (!setCwdToExeDir())
    {
        return false;
    }

    // Get the OpenCL platform.
    platform = findPlatform("Intel");
    if (platform == NULL)
    {
        printf("ERROR: Unable to find Intel FPGA OpenCL platform.\n");
        return false;
    }

    // Query the available OpenCL device.
    cl_device_id *devices = getDevices(platform, CL_DEVICE_TYPE_ALL, &num_devices);

    printf("Platform: %s\n", getPlatformName(platform).c_str());

    printf("Found %d device(s)\n", num_devices);
    for (unsigned i = 0; i < num_devices; ++i)
    {
        printf("  %s\n", getDeviceName(devices[i]).c_str());
    }

    // pick 1st device
    device = devices[0];

    printf("Choose device: %d\n", device);
    printf("  name: %s\n", getDeviceName(device).c_str());

    // Create the context.
    context = clCreateContext(NULL, 1, &device, &oclContextCallback, NULL, &status);
    checkError(status, "Failed to create context");

    // Create the program for all device. Use the first device as the
    // representative device (assuming all device are of the same type).
    printf("Using kernel binary: %s\n", binary_file.c_str());
    program = createProgramFromBinary(context, binary_file.c_str(), &device, 1);

    // Build the program that was just created.
    status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
    checkError(status, "Failed to build program");

    // Command queue.
    queue = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
    checkError(status, "Failed to create command queue");

    // Kernel.
    const char *kernel_name = "dwt1";
    kernel = clCreateKernel(program, kernel_name, &status);
    checkError(status, "Failed to create kernel");



    // Input buffers.
    input_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, 8 * sizeof(short int), NULL, &status);
    checkError(status, "Failed to create buffer for input");

    // Output buffer.
    output_buf = clCreateBuffer(context, CL_MEM_WRITE_ONLY, 1 * sizeof(int), NULL, &status);
    checkError(status, "Failed to create buffer for output");

    return true;
}

// Initialize the data for the problem. Requires num_devices to be known.
void init_problem()
{
    if (num_devices == 0)
    {
        checkError(-1, "No devices");
    }

    dir = opendir(IDIR);
    // ASSERT(dir != NULL);

    // todo: implement multi-audio extraction
    while ((ep = readdir(dir)) != NULL)
    {
        if (ep->d_type == DT_REG)
        {
            sprintf(ifpath, "%s/%s", IDIR, ep->d_name);
            sprintf(ofpath, "%s/%s.raw", ODIR, ep->d_name);

            printf("\ninput file: %s ", ifpath);

            ifp = fopen(ifpath, "rb+");
            // ASSERT(ifp != NULL);

            ofp = fopen(ofpath, "wb");
            // ASSERT(ifp != NULL);

            // r = genfp(ifp, ofp);
            // ASSERT(r == 0);

            // fclose(ifp);
            // ifp = NULL;

            // fclose(ofp);
            // ofp = NULL;
        }
    }
}

void run()
{
    cl_int status;

    const double start_time = getCurrentTimestamp();

    // Launch the problem for each device.
    cl_event kernel_event;
    cl_event finish_event;

    // hifp
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
    // dwt_eco[0] = dwt1(&wave16[0]);
    // i = 32;
    // k = 0;

    {
        // Transfer inputs to each device. Each of the host buffers supplied to
        // clEnqueueWriteBuffer here is already aligned to ensure that DMA is used
        // for the host-to-device transfer.
        cl_event write_event[2];
        status = clEnqueueWriteBuffer(queue, input_buf, CL_FALSE, 0, 8 * sizeof(short int), wave16, 0, NULL, &write_event[0]);
        checkError(status, "Failed to transfer input A");

        // Set kernel arguments.
        unsigned argi = 0;

        status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &input_buf);
        checkError(status, "Failed to set argument %d", argi - 1);

        status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &output_buf);
        checkError(status, "Failed to set argument %d", argi - 1);

        // Enqueue kernel.
        // Use a global work size corresponding to the number of elements to add
        // for this device.
        //
        // We don't specify a local work size and let the runtime choose
        // (it'll choose to use one work-group with the same size as the global
        // work-size).
        //
        // Events are used to ensure that the kernel is not launched until
        // the writes to the input buffers have completed.
        const size_t global_work_size = 1;
        printf("Launching for device %d (%zd elements)\n", device, global_work_size);

        status = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_work_size, NULL, 2, write_event, &kernel_event);
        checkError(status, "Failed to launch kernel");

        // Read the result. This the final operation.
        status = clEnqueueReadBuffer(queue, output_buf, CL_FALSE, 0, 1 * sizeof(int), dwt_eco[0], 1, &kernel_event, &finish_event);

        // Release local events.
        clReleaseEvent(write_event[0]);
        clReleaseEvent(write_event[1]);
    }

    // Wait for all devices to finish.
    clWaitForEvents(1, &finish_event);

    const double end_time = getCurrentTimestamp();

    // Wall-clock time taken.
    printf("\nTime: %0.3f ms\n", (end_time - start_time) * 1e3);

    // Get kernel times using the OpenCL event profiling API.
    {
        cl_ulong time_ns = getStartEndTime(kernel_event);
        printf("Kernel time (device %d): %0.3f ms\n", device, double(time_ns) * 1e-6);
    }

    // Release all events.
    {
        clReleaseEvent(kernel_event);
        clReleaseEvent(finish_event);
    }
}

// Free the resources allocated during initialization
void cleanup()
{
    if (kernel)
    {
        clReleaseKernel(kernel);
    }
    if (queue)
    {
        clReleaseCommandQueue(queue);
    }
    if (input_buf)
    {
        clReleaseMemObject(input_buf);
    }
    if (output_buf)
    {
        clReleaseMemObject(output_buf);
    }
    if (program)
    {
        clReleaseProgram(program);
    }
    if (context)
    {
        clReleaseContext(context);
    }

    // old
    if (dir)
    {
        closedir(dir);
    }
    if (ifp)
    {
        fclose(ifp);
        ifp = NULL;
    }
    if (ofp)
    {
        fclose(ofp);
        ofp = NULL;
    }
}