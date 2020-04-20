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
cl_mem plain_fpid_buf = NULL;
cl_mem dwteco_buf = NULL;


// Problem data
const char *IDIR = I_DIR;
const char *ODIR = "./distorted-fp";

const int NUMWAVE = NUM_WAVE;
const int NUMDWTECO = NUM_DWT_ECO;
const int NUMFRAME = NUM_FRAME;


// Function prototypes
void init_opencl();
int init_problem();
void run();
void cleanup();



int main(
    int     argc, 
    char ** argv
)
{
    Options options(argc, argv);

    if (options.has("kernel_bin"))
    {
        binary_file = options.get<string>("kernel_bin");
    }

    init_opencl();
    init_problem();
    run();
    cleanup();

    return 0;
}



// Initializes the OpenCL objects
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
    // const char *kernel_name = "dwt";
    kernel[0] = clCreateKernel(program, "dwt", &status);
    kernel[1] = clCreateKernel(program, "generate_fpid", &status);
    checkError(status, "Failed to create kernel");
}


DIR *dir = NULL;
struct dirent *ep;
char ifpath[256];
char ofpath[256];
FILE *ifp = NULL;
FILE *ofp = NULL;

short int    wave16[NUMWAVE];
unsigned int fpid[NUMFRAME];
unsigned int plain_fpid[NUMDWTECO];
unsigned int dwt[NUMDWTECO];

/* Load problem data here */
int init_problem()
{
    if (num_devices == 0)
    {
        checkError(-1, "No devices");
    }

    dir = opendir(IDIR);
    ASSERT(dir != NULL);

    while ((ep = readdir(dir)) != NULL)
    {
        if (ep->d_type == DT_REG)
        {
            sprintf(ifpath, "%s/%s", IDIR, ep->d_name);
            sprintf(ofpath, "%s/%s.raw", ODIR, ep->d_name);

            ifp = fopen(ifpath, "rb+");
            ASSERT(ifp != NULL);

            ofp = fopen(ofpath, "wb");
            ASSERT(ifp != NULL);
        }
    }

    /* Load 1 wav */
    WAVEHEADER wave_header;

    /* initialize all array elements to zero */
    memset(wave16, 0, sizeof(wave16));
    memset(fpid, 0, sizeof(fpid));
    memset(plain_fpid, 0, sizeof(plain_fpid));
    memset(dwt, 0, sizeof(dwt));

    /* Load data */
    wave_header = read_wave_header(ifp);
    read_wav_data(ifp, wave16, wave_header);

    return 0;

err:
    closedir(dir);
    return -1;
}



void run()
{
    cl_int status;

    /* Create buffer */
    wave16_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, NUMWAVE * sizeof(short int), NULL, &status);
    checkError(status, "Failed to create buffer for input");

    fpid_buf = clCreateBuffer(context, CL_MEM_READ_WRITE, NUMFRAME * sizeof(unsigned int), NULL, &status);
    checkError(status, "Failed to create buffer for output 1 - fpid");

    plain_fpid_buf = clCreateBuffer(context, CL_MEM_READ_WRITE, NUMDWTECO * sizeof(unsigned int), NULL, &status);
    checkError(status, "Failed to create buffer for output 2 - plain_fpid");

    dwteco_buf = clCreateBuffer(context, CL_MEM_READ_WRITE, NUMDWTECO * sizeof(unsigned int), NULL, &status);
    checkError(status, "Failed to create buffer for output 3 - dwt");

    {
        const double start_time = getCurrentTimestamp();
        cl_event kernel_event;
        cl_event finish_event[3];
        cl_event write_event[1];

        status = clEnqueueWriteBuffer(queue, wave16_buf, CL_FALSE, 0, NUMWAVE * sizeof(short int), wave16, 0, NULL, &write_event[0]);
        checkError(status, "Failed to transfer input wav");

        // Set kernel arguments.
        {
            unsigned argi = 0;

            status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &wave16_buf);
            checkError(status, "Failed to set argument %d", argi - 1);

            status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &fpid_buf);
            checkError(status, "Failed to set argument %d", argi - 1);

            status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &plain_fpid_buf);
            checkError(status, "Failed to set argument %d", argi - 1);

            status = clSetKernelArg(kernel[0], argi++, sizeof(cl_mem), &dwteco_buf);
            checkError(status, "Failed to set argument %d", argi - 1);
        }

        /*
        Enqueue kernel.
        Use a global work size corresponding to the number of elements to add
        for this device.
        
        We don't specify a local work size and let the runtime choose
        (it'll choose to use one work-group with the same size as the global
        work-size).
        
        Events are used to ensure that the kernel is not launched until
        the writes to the input buffers have completed. 
        */
        const cl_uint work_dim = 1;
        const cl_uint num_events_in_wait_list = 1;
        const size_t global_work_offset = 0;
        const size_t global_work_size = NUMFRAME;
        const size_t local_work_size = 0;

        printf("\n");
        printf("Launching for device %u: \n", device);
        printf("- work_dim: %u \n", work_dim);
        printf("- num_events_in_wait_list: %u \n", num_events_in_wait_list);
        printf("- global_work_offset: %lu \n", global_work_offset);
        printf("- global_work_size: %lu \n", global_work_size);
        printf("- local_work_size: %lu \n", local_work_size);

        status = clEnqueueNDRangeKernel(queue,
                                        kernel[0],
                                        work_dim,
                                        global_work_offset == 0 ? NULL : &global_work_offset,
                                        global_work_size == 0 ? NULL : &global_work_size,
                                        local_work_size == 0 ? NULL : &local_work_size,
                                        num_events_in_wait_list,
                                        write_event,
                                        &kernel_event);

        checkError(status, "Failed to launch kernel");

        // Read the result. This the final operation.
        status = clEnqueueReadBuffer(queue, fpid_buf, CL_FALSE, 0, NUMFRAME * sizeof(unsigned int), fpid, 1, &kernel_event, &finish_event[0]);
        status = clEnqueueReadBuffer(queue, plain_fpid_buf, CL_FALSE, 0, NUMDWTECO * sizeof(unsigned int), plain_fpid, 1, &kernel_event, &finish_event[1]);
        status = clEnqueueReadBuffer(queue, dwteco_buf, CL_FALSE, 0, NUMDWTECO * sizeof(unsigned int), dwt, 1, &kernel_event, &finish_event[2]);

        // Release local events.
        clReleaseEvent(write_event[0]);

        // Wait for all devices to finish.
        clWaitForEvents(3, finish_event);

        const double end_time = getCurrentTimestamp();

        // Wall-clock time taken.
        printf("\n");
        printf("Time: %0.3f ms \n", (end_time - start_time) * 1e3);

        // Get kernel times using the OpenCL event profiling API.
        {
            cl_ulong time_ns = getStartEndTime(kernel_event);
            printf("Kernel time (%d): %0.3f ms \n", device, double(time_ns) * 1e-6);
        }

        // Release all events.
        {
            clReleaseEvent(kernel_event);
            clReleaseEvent(finish_event[0]);
            clReleaseEvent(finish_event[1]);
            clReleaseEvent(finish_event[2]);
        }
    }

    {
        const double start_time = getCurrentTimestamp();
        cl_event kernel_event;
        cl_event finish_event[2];
        cl_event write_event[1];

        status = clEnqueueWriteBuffer(queue_2, dwteco_buf, CL_FALSE, 0, NUMDWTECO * sizeof(unsigned int), dwt, 0, NULL, &write_event[0]);
        checkError(status, "Failed to transfer input dwteco");

        {
            unsigned argi = 0;

            status = clSetKernelArg(kernel[1], argi++, sizeof(cl_mem), &dwteco_buf);
            checkError(status, "Failed to set argument %d", argi - 1);

            status = clSetKernelArg(kernel[1], argi++, sizeof(cl_mem), &fpid_buf);
            checkError(status, "Failed to set argument %d", argi - 1);

            status = clSetKernelArg(kernel[1], argi++, sizeof(cl_mem), &plain_fpid_buf);
            checkError(status, "Failed to set argument %d", argi - 1);
        }

        /*
        Enqueue kernel.
        Use a global work size corresponding to the number of elements to add
        for this device.
        
        We don't specify a local work size and let the runtime choose
        (it'll choose to use one work-group with the same size as the global
        work-size).
        
        Events are used to ensure that the kernel is not launched until
        the writes to the input buffers have completed. 
        */
        const cl_uint work_dim = 1;
        const cl_uint num_events_in_wait_list = 1;
        const size_t global_work_offset = 0;
        const size_t global_work_size = NUMFRAME;
        const size_t local_work_size = 0;

        printf("\n");
        printf("Launching for device %u: \n", device);
        printf("- work_dim: %u \n", work_dim);
        printf("- num_events_in_wait_list: %u \n", num_events_in_wait_list);
        printf("- global_work_offset: %lu \n", global_work_offset);
        printf("- global_work_size: %lu \n", global_work_size);
        printf("- local_work_size: %lu \n", local_work_size);

        status = clEnqueueNDRangeKernel(queue_2,
                                        kernel[1],
                                        work_dim,
                                        global_work_offset == 0 ? NULL : &global_work_offset,
                                        global_work_size == 0 ? NULL : &global_work_size,
                                        local_work_size == 0 ? NULL : &local_work_size,
                                        num_events_in_wait_list,
                                        write_event,
                                        &kernel_event);

        checkError(status, "Failed to launch kernel");

        // Read the result. This the final operation.
        status = clEnqueueReadBuffer(queue_2, fpid_buf, CL_FALSE, 0, NUMFRAME * sizeof(unsigned int), fpid, 1, &kernel_event, &finish_event[0]);
        status = clEnqueueReadBuffer(queue_2, plain_fpid_buf, CL_FALSE, 0, NUMDWTECO * sizeof(unsigned int), plain_fpid, 1, &kernel_event, &finish_event[1]);

        // Release local events.
        clReleaseEvent(write_event[0]);

        // Wait for all devices to finish.
        clWaitForEvents(2, finish_event);

        const double end_time = getCurrentTimestamp();

        // Wall-clock time taken.
        printf("\n");
        printf("Time: %0.3f ms \n", (end_time - start_time) * 1e3);

        // Get kernel times using the OpenCL event profiling API.
        {
            cl_ulong time_ns = getStartEndTime(kernel_event);
            printf("Kernel time (%d): %0.3f ms \n", device, double(time_ns) * 1e-6);
        }

        // Release all events.
        {
            clReleaseEvent(kernel_event);
            clReleaseEvent(finish_event[0]);
            clReleaseEvent(finish_event[1]);
        }
    }

    /* Verify result */
    verify_fpid(fpid, plain_fpid, dwt);

    /* Save FPID to disk */
    save_fp_to_disk(ofp, fpid);
}



// Free the resources allocated during initialization
void cleanup()
{
    if (kernel[0])
    {
        clReleaseKernel(kernel[0]);
    }
    if (kernel[1])
    {
        clReleaseKernel(kernel[1]);
    }
    if (queue)
    {
        clReleaseCommandQueue(queue);
    }
    if (program)
    {
        clReleaseProgram(program);
    }
    if (context)
    {
        clReleaseContext(context);
    }
    if (wave16_buf)
    {
        clReleaseMemObject(wave16_buf);
    }
    if (fpid_buf)
    {
        clReleaseMemObject(fpid_buf);
    }
    if (plain_fpid_buf)
    {
        clReleaseMemObject(plain_fpid_buf);
    }
    if (dwteco_buf)
    {
        clReleaseMemObject(dwteco_buf);
    }

    // Free problem data
    if (dir) {
        closedir(dir);
    }
    if (ifp) {
        fclose(ifp);
        ifp = NULL;
    }
    if (ofp) {
        fclose(ofp);
        ofp = NULL;
    }
}