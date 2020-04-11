#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include "CL/opencl.h"
#endif

#include "AOCLUtils/aocl_utils.h"

using namespace aocl_utils;

#define MAX_SOURCE_SIZE (0x100000)

// OpenCL runtime configuration
std::string binary_file = "vector_add.aocx";
cl_platform_id platform = NULL;
unsigned num_devices = 0;
cl_device_id device = NULL;
cl_context context = NULL;
cl_command_queue queue = NULL;
cl_program program = NULL;
cl_kernel kernel = NULL;
cl_mem input_a_buf = NULL;
cl_mem input_b_buf = NULL;
cl_mem output_buf = NULL;

// Problem data
unsigned N = 1000000;
float *input_a;
float *input_b;
float *output;
float *ref_output;

// Function prototypes
void init_opencl();
void init_problem();
void run();
void cleanup();

int main(int argc, char **argv)
{
    Options options(argc, argv);

    if (options.has("n"))
    {
        N = options.get<unsigned>("n");
    }

    if (options.has("kernel"))
    {
        binary_file = options.get<unsigned>("kernel");
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

    fp = fopen("device/vector_add.cl", "r");
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

    // Kernel.
    const char *kernel_name = "vector_add";
    kernel = clCreateKernel(program, kernel_name, &status);
    checkError(status, "Failed to create kernel");

    // Input buffers.
    input_a_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, N * sizeof(float), NULL, &status);
    checkError(status, "Failed to create buffer for input A");

    input_b_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, N * sizeof(float), NULL, &status);
    checkError(status, "Failed to create buffer for input B");

    // Output buffer.
    output_buf = clCreateBuffer(context, CL_MEM_WRITE_ONLY, N * sizeof(float), NULL, &status);
    checkError(status, "Failed to create buffer for output");
}

void init_problem()
{
    if (num_devices == 0)
    {
        checkError(-1, "No devices");
    }

    input_a = (float *)malloc(N * sizeof(float));
    input_b = (float *)malloc(N * sizeof(float));
    output = (float *)malloc(N * sizeof(float));
    ref_output = (float *)malloc(N * sizeof(float));

    for (unsigned i = 0; i < N; ++i)
    {
        input_a[i] = 1023;
        input_b[i] = 1.0;
        ref_output[i] = input_a[i] + input_b[i];
    }
}

void run()
{
    const double start_time = getCurrentTimestamp();
    cl_int status;
    cl_event kernel_event;
    cl_event finish_event;

    {
        // Transfer inputs to each device. Each of the host buffers supplied to
        // clEnqueueWriteBuffer here is already aligned to ensure that DMA is used
        // for the host-to-device transfer.
        cl_event write_event[2];
        status = clEnqueueWriteBuffer(queue, input_a_buf, CL_FALSE, 0, N * sizeof(float), input_a, 0, NULL, &write_event[0]);
        checkError(status, "Failed to transfer input A");

        status = clEnqueueWriteBuffer(queue, input_b_buf, CL_FALSE, 0, N * sizeof(float), input_b, 0, NULL, &write_event[1]);
        checkError(status, "Failed to transfer input B");

        // Set kernel arguments.
        unsigned argi = 0;

        status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &input_a_buf);
        checkError(status, "Failed to set argument %d", argi - 1);

        status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &input_b_buf);
        checkError(status, "Failed to set argument %d", argi - 1);

        status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &output_buf);
        checkError(status, "Failed to set argument %d", argi - 1);

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
        const cl_uint num_events_in_wait_list = 2;
        const size_t global_work_offset = 0;
        const size_t global_work_size = N;
        const size_t local_work_size = 0;

        printf("\n");
        printf("Launching for device %d: \n");
        printf("- work_dim: %zd \n", work_dim);
        printf("- num_events_in_wait_list: %zd \n", num_events_in_wait_list);
        printf("- global_work_offset: %zd \n", global_work_offset);
        printf("- global_work_size: %zd \n", global_work_size);
        printf("- local_work_size: %zd \n", local_work_size);

        status = clEnqueueNDRangeKernel(queue,
                                        kernel,
                                        work_dim,
                                        global_work_offset == 0 ? NULL : &global_work_offset,
                                        global_work_size == 0 ? NULL : &global_work_size,
                                        local_work_size == 0 ? NULL : &local_work_size,
                                        num_events_in_wait_list,
                                        write_event,
                                        &kernel_event);

        checkError(status, "Failed to launch kernel");

        // Read the result. This the final operation.
        status = clEnqueueReadBuffer(queue, output_buf, CL_FALSE, 0, N * sizeof(float), output, 1, &kernel_event, &finish_event);

        // Release local events.
        clReleaseEvent(write_event[0]);
        clReleaseEvent(write_event[1]);
    }

    // Wait for all devices to finish.
    clWaitForEvents(1, &finish_event);

    const double end_time = getCurrentTimestamp();

    // Wall-clock time taken.
    printf("\n");
    printf("Time: %0.3f ms \n", (end_time - start_time) * 1e3);

    // Get kernel times using the OpenCL event profiling API.
    {
        cl_ulong time_ns = getStartEndTime(kernel_event);
        printf("Kernel time: %0.3f ms \n", device, double(time_ns) * 1e-6);
    }

    // Release all events.
    {
        clReleaseEvent(kernel_event);
        clReleaseEvent(finish_event);
    }

    // Verify results.
    bool pass = true;
    {
        for (unsigned j = 0; j < N && pass; ++j)
        {
            if (fabsf(output[j] - ref_output[j]) > 1.0e-5f)
            {
                printf("Failed verification @ device %d, index %d\nOutput: %f\nReference: %f\n", device, j, output[j], ref_output[j]);
                pass = false;
            }
        }
    }

    printf("\n");
    printf("Verification: %s\n", pass ? "PASS" : "FAIL");
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
    if (program)
    {
        clReleaseProgram(program);
    }
    if (context)
    {
        clReleaseContext(context);
    }

    // Free problem data
    if (input_a_buf)
    {
        clReleaseMemObject(input_a_buf);
    }
    if (input_b_buf)
    {
        clReleaseMemObject(input_b_buf);
    }
    if (output_buf)
    {
        clReleaseMemObject(output_buf);
    }
}
