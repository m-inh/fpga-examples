#define MAX_SOURCE_SIZE (0x100000)

#ifdef __APPLE__
#define I_DIR "../distorted-wav"
#else
#define I_DIR "../../distorted-wav"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include "CL/opencl.h"
#endif

#include "AOCLUtils/aocl_utils.h"
#include "hifp/hifp.h"
#include "utils/utils.h"

using namespace std;
using namespace aocl_utils;
using namespace hifp;
using namespace my_utils;


// OpenCL runtime configuration
string binary_file = "hifp.aocx";
cl_platform_id platform = NULL;
unsigned num_devices = 0;
cl_device_id device = NULL;
cl_context context = NULL;
cl_command_queue queue = NULL;
cl_command_queue queue_2 = NULL;
cl_program program = NULL;
cl_kernel kernel[2];

cl_mem wave16_buf = NULL;
cl_mem fpid_buf = NULL;
// cl_mem plain_fpid_buf = NULL;
cl_mem dwteco_buf = NULL;


// Problem data
const char *IDIR = I_DIR;
const char *ODIR = "./distorted-fp";

const int NUMWAVE = NUM_WAVE;
const int NUMDWTECO = NUM_DWT_ECO;
const int NUMFRAME = NUM_FRAME;

short int    wave16[NUMWAVE];
unsigned int fpid[NUMFRAME];
// unsigned int plain_fpid[NUMDWTECO];
unsigned int dwt[NUMDWTECO];


// Function prototypes
void init_opencl();
int init_problem(FILE *ifp, FILE *ofp);
void run();
void cleanup();



int main(int argc, char ** argv)
{
    Options options(argc, argv);

    if (options.has("kernel_bin"))
    {
        binary_file = options.get<string>("kernel_bin");
    }

    init_opencl();
    
    DIR *dir = NULL;
    struct dirent *ep;
    char ifpath[256];
    char ofpath[256];
    FILE *ifp = NULL;
    FILE *ofp = NULL;

    dir = opendir(IDIR);
    ASSERT(dir != NULL);

    while ((ep = readdir(dir)) != NULL)
    {
        if (ep->d_type == DT_REG)
        {
            sprintf(ifpath, "%s/%s",     IDIR, ep->d_name);
            sprintf(ofpath, "%s/%s.raw", ODIR, ep->d_name);

            ifp = fopen(ifpath, "rb+");
            ASSERT(ifp != NULL);

            ofp = fopen(ofpath, "wb");
            ASSERT(ifp != NULL);

            init_problem(ifp, ofp);
            run();
            save_fp_to_disk(ofp, fpid);
            
            fclose(ifp);
            fclose(ofp);
            ifp = NULL;
            ofp = NULL;
        }
    }
    
    closedir(dir);

    cleanup();

    return 0;

err:
    closedir(dir);
    return -1;
}



void init_opencl()
{
    cl_int status;

    printf("Initializing OpenCL \n");

    // Get the OpenCL platform
#ifdef __APPLE__
    platform = findPlatform("Apple");
#else
    if (!setCwdToExeDir())
    {
        checkError(-1, "Failed to perform setCwdToExeDir()");
    }

    platform = findPlatform("Intel");
#endif
    if (platform == NULL)
    {
        checkError(-1, "Unable to find platform");
    }

    // Query the available OpenCL device.
    cl_device_id *devices = getDevices(platform, CL_DEVICE_TYPE_ALL, &num_devices);

    printf("\n");
    printf("Platform: %s\n", getPlatformName(platform).c_str());

    printf("Found %d device(s):\n", num_devices);
    for (unsigned i = 0; i < num_devices; ++i)
    {
        printf("- %s (id: %d)\n", getDeviceName(devices[i]).c_str(), devices[i]);
    }

    // Choose 1st device
    device = devices[0];

    printf("\n");
    printf("Choose device:\n");
    printf("- %s (id: %d)\n", getDeviceName(device).c_str(), device);

    // Create the context.
    context = clCreateContext(NULL, 1, &device, &oclContextCallback, NULL, &status);
    checkError(status, "Failed to create context");

    // Create the program for all device. Use the first device as the
    // representative device (assuming all device are of the same type).
#ifdef __APPLE__
    // Load the kernel source code into the array source_str
    FILE *fp;
    char *source_str;
    size_t source_size;

    fp = fopen("device/hifp.cl", "r");
    if (!fp)
    {
        checkError(-1, "Failed to load kernel");
    }
    source_str = (char *)malloc(MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    program = clCreateProgramWithSource(context, 1, (const char **)&source_str, (const size_t *)&source_size, &status);
#else
    printf("Using kernel binary: %s\n", binary_file.c_str());
    program = createProgramFromBinary(context, binary_file.c_str(), &device, 1);
#endif

    // Build the program that was just created.
    status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
    checkError(status, "Failed to build program");

    // Command queue.
    queue = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
    checkError(status, "Failed to create command queue");

    queue_2 = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
    checkError(status, "Failed to create command queue_2");

    // Kernel.
    kernel[0] = clCreateKernel(program, "dwt", &status);
    kernel[1] = clCreateKernel(program, "generate_fpid", &status);
    checkError(status, "Failed to create kernel");
}



/* Load problem data here */
int init_problem(FILE *ifp, FILE *ofp)
{
    if (num_devices == 0)
    {
        checkError(-1, "No devices");
    }

    /* Load 1 wav */
    WAVEHEADER wave_header;

    /* initialize all array elements to zero */
    memset(wave16, 0, sizeof(wave16));
    memset(fpid, 0, sizeof(fpid));
    // memset(plain_fpid, 0, sizeof(plain_fpid));
    memset(dwt, 0, sizeof(dwt));

    /* Load data */
    wave_header = read_wave_header(ifp);
    read_wav_data(ifp, wave16, wave_header);

    return 0;
}



void run()
{
    const double start_time = getCurrentTimestamp();
    cl_int status;
    cl_event write_event[1];
    cl_event read_event[1];
    cl_event kernel_event[2];

    const cl_uint work_dim[2] = {1, 1};
    const cl_uint num_events_in_wait_list[2] = {1, 1};
    const size_t global_work_offset[2] = {0, 0};
    const size_t global_work_size[2] = {NUMDWTECO, NUMFRAME};
    const size_t local_work_size[2] = {0, 0};


    /* Create buffer */
    wave16_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, NUMWAVE * sizeof(short int), NULL, &status);
    checkError(status, "Failed to create buffer for input");
    fpid_buf   = clCreateBuffer(context, CL_MEM_READ_WRITE, NUMFRAME * sizeof(unsigned int), NULL, &status);
    checkError(status, "Failed to create buffer for output 1 - fpid");
    dwteco_buf = clCreateBuffer(context, CL_MEM_READ_WRITE, NUMDWTECO * sizeof(unsigned int), NULL, &status);
    checkError(status, "Failed to create buffer for output 3 - dwt");

    
    // Set kernel arguments.
    /* kernel 0 */
    unsigned argi = 0;
    status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &wave16_buf);
    checkError(status, "Failed to set argument %d", argi - 1);
    status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &dwteco_buf);
    checkError(status, "Failed to set argument %d", argi - 1);    
    /* kernel 1 */
    argi = 0;
    status = clSetKernelArg(kernel[1], argi++, sizeof(cl_mem), &dwteco_buf);
    checkError(status, "Failed to set argument %d", argi - 1);
    status = clSetKernelArg(kernel[1], argi++, sizeof(cl_mem), &fpid_buf);
    checkError(status, "Failed to set argument %d", argi - 1);


    /* Transfer data to device */
    status = clEnqueueWriteBuffer(queue, wave16_buf, CL_FALSE, 0, NUMWAVE * sizeof(short int), wave16, 0, NULL, &write_event[0]);
    checkError(status, "Failed to transfer input wav");


    /* Run kernel */
    /* kernel 0 */
    printf("\n");
    printf("Launching for device:      %d  \n", device);
    printf("- work_dim:                %u  \n", work_dim[0]);
    printf("- num_events_in_wait_list: %u  \n", num_events_in_wait_list[0]);
    printf("- global_work_offset:      %lu \n", global_work_offset[0]);
    printf("- global_work_size:        %lu \n", global_work_size[0]);
    printf("- local_work_size:         %lu \n", local_work_size[0]);

    status = clEnqueueNDRangeKernel(queue,
                                    kernel[0],
                                    work_dim[0],
                                    global_work_offset[0] == 0 ? NULL : &global_work_offset[0],
                                    global_work_size[0]   == 0 ? NULL : &global_work_size[0],
                                    local_work_size[0]    == 0 ? NULL : &local_work_size[0],
                                    num_events_in_wait_list[0],
                                    &write_event[0],
                                    &kernel_event[0]);
    checkError(status, "Failed to launch dwt kernel");

    /* kernel 1 */
    printf("\n");
    printf("Launching for device:      %d  \n", device);
    printf("- work_dim:                %u  \n", work_dim[1]);
    printf("- num_events_in_wait_list: %u  \n", num_events_in_wait_list[1]);
    printf("- global_work_offset:      %lu \n", global_work_offset[1]);
    printf("- global_work_size:        %lu \n", global_work_size[1]);
    printf("- local_work_size:         %lu \n", local_work_size[1]);

    status = clEnqueueNDRangeKernel(queue,
                                    kernel[1],
                                    work_dim[1],
                                    global_work_offset[1] == 0 ? NULL : &global_work_offset[1],
                                    global_work_size[1]   == 0 ? NULL : &global_work_size[1],
                                    local_work_size[1]    == 0 ? NULL : &local_work_size[1],
                                    num_events_in_wait_list[1],
                                    &kernel_event[0],
                                    &kernel_event[1]);
    checkError(status, "Failed to launch gen_fpid kernel");    


    /* Read result from device */
    status = clEnqueueReadBuffer(queue, fpid_buf, CL_FALSE, 0, NUMFRAME * sizeof(unsigned int), fpid, 1, &kernel_event[1], &read_event[0]);
    clWaitForEvents(1, read_event);


    // Print time taken.
    const double end_time = getCurrentTimestamp();
    cl_ulong transfer_time[2];
    cl_ulong kernel_time[2];

    printf("\n");
    printf("Wall-clock time:      %0.3f ms \n", (end_time - start_time) * 1e3);

    transfer_time[0] = getStartEndTime(write_event[0]);
    transfer_time[1] = getStartEndTime(read_event[0]);
    kernel_time[0] = getStartEndTime(kernel_event[0]);
    kernel_time[1] = getStartEndTime(kernel_event[1]);
    printf("Transfer write time:  %0.3f ms \n", double(transfer_time[0]) * 1e-6);
    printf("Transfer read time:   %0.3f ms \n", double(transfer_time[1]) * 1e-6);
    printf("Kernel time dwt:      %0.3f ms \n", double(kernel_time[0]) * 1e-6);
    printf("Kernel time gen_fpid: %0.3f ms \n", double(kernel_time[1]) * 1e-6);


    /* Release all events */
    clReleaseEvent(kernel_event[0]);
    clReleaseEvent(kernel_event[1]);
    clReleaseEvent(read_event[0]);
    clReleaseEvent(write_event[0]);


    /* Verify result */
    // verify_fpid(fpid, NULL, NULL);

    /* Save FPID to disk */
    // save_fp_to_disk(ofp, fpid);
}



// Free the resources allocated during initialization
void cleanup()
{
    clReleaseKernel(kernel[0]);
    clReleaseKernel(kernel[1]);
    clReleaseCommandQueue(queue);
    clReleaseProgram(program);
    clReleaseContext(context);
    clReleaseMemObject(wave16_buf);
    clReleaseMemObject(fpid_buf);
    clReleaseMemObject(dwteco_buf);

    // Free problem data
    // closedir(dir);
    // fclose(ifp);
    // fclose(ofp);
    // ifp = NULL;
    // ofp = NULL;
}