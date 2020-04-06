#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "CL/opencl.h"
#include "AOCLUtils/aocl_utils.h"

using namespace aocl_utils;

// OpenCL runtime configuration
std::string binary_file = "vector_add.aocx";
cl_platform_id platform = NULL;
unsigned num_devices = 0;
cl_device_id device;
cl_context context = NULL;
cl_command_queue queue; 
cl_program program = NULL;
cl_kernel kernel; 
cl_mem input_a_buf; 
cl_mem input_b_buf; 
cl_mem output_buf;  

// Problem data.
unsigned N = 1000000; // problem size
float* input_a;
float* input_b;
float* output;           
float* ref_output; 

// Function prototypes
float rand_float();
bool init_opencl();
void init_problem();
void run();
void cleanup();

// Entry point.
int main(int argc, char **argv)
{
    Options options(argc, argv);

    // Optional argument to specify the problem size.
    if (options.has("n"))
    {
        N = options.get<unsigned>("n");
    }

    if (options.has("kernel"))
    {
        binary_file = options.get<unsigned>("kernel");
    }

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
}

/////// HELPER FUNCTIONS ///////

// Randomly generate a floating-point number between -10 and 10.
float rand_float()
{
    return float(rand()) / float(RAND_MAX) * 20.0f - 10.0f;
}

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

    return true;
}


// Initialize the data for the problem. Requires num_devices to be known.
void init_problem()
{
    if (num_devices == 0)
    {
        checkError(-1, "No devices");
    }

    // Generate input vectors A and B and the reference output consisting
    // of a total of N elements.
    // We create separate arrays for each device so that each device has an
    // aligned buffer.
    input_a = (float*) malloc(N * sizeof(float));
    input_b = (float*) malloc(N * sizeof(float));
    output = (float*) malloc(N * sizeof(float));
    ref_output = (float*) malloc(N * sizeof(float));

    for (unsigned i = 0; i < N; ++i)
    {
        input_a[i] = rand_float();
        input_b[i] = rand_float();
        ref_output[i] = input_a[i] + input_b[i];
    }
}

void run()
{
    cl_int status;

    const double start_time = getCurrentTimestamp();

    // Launch the problem for each device.
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
        const size_t global_work_size = N;
        printf("Launching for device %d (%zd elements)\n", device, global_work_size);

        status = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_work_size, NULL, 2, write_event, &kernel_event);
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

    printf("\nVerification: %s\n", pass ? "PASS" : "FAIL");
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

    if (program)
    {
        clReleaseProgram(program);
    }
    if (context)
    {
        clReleaseContext(context);
    }
}

