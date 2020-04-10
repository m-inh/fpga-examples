#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#define MAX_SOURCE_SIZE (0x100000)

bool fileExists(const char *file_name)
{
#ifdef _WIN32 // Windows
    DWORD attrib = GetFileAttributesA(file_name);
    return (attrib != INVALID_FILE_ATTRIBUTES && !(attrib & FILE_ATTRIBUTE_DIRECTORY));
#else // Linux
    return access(file_name, R_OK) != -1;
#endif
}

// Loads a file in binary form.
unsigned char *loadBinaryFile(const char *file_name, size_t *size)
{
    // Open the File
    FILE *fp;

    fp = fopen(file_name, "rb");
    if (fp == 0)
    {
        return NULL;
    }

    // Get the size of the file
    fseek(fp, 0, SEEK_END);
    *size = ftell(fp);

    // Allocate space for the binary
    unsigned char *binary = new unsigned char[*size];

    // Go back to the file start
    rewind(fp);

    // Read the file into the binary
    if (fread((void *)binary, *size, 1, fp) == 0)
    {
        delete[] binary;
        fclose(fp);
        return NULL;
    }

    return binary;
}

// Create a program for all devices associated with the context.
cl_program createProgramFromBinary(cl_context context, const char *binary_file_name, const cl_device_id device_id)
{
    // Early exit for potentially the most common way to fail: AOCX does not exist.
    if (!fileExists(binary_file_name))
    {
        printf("Kernel file '%s' does not exist.\n", binary_file_name);
    }

    // Load the binary.
    size_t binary_size;
    unsigned char *binary(loadBinaryFile(binary_file_name, &binary_size));
    if (binary == NULL)
    {
        printf("Failed to load binary file \n");
    }

    cl_int status;
    cl_int binary_status;

    cl_program program = clCreateProgramWithBinary(context,
                                                   1,
                                                   &device_id,
                                                   &binary_size,
                                                   (const unsigned char **)binary,
                                                   &binary_status,
                                                   &status);

    return program;
}

//////////////////////////  main  ///////////////////////////////

int main(void)
{
    // Create the two input vectors
    int i;
    const int LIST_SIZE = 1000000;
    int *A = (int *)malloc(sizeof(int) * LIST_SIZE);
    int *B = (int *)malloc(sizeof(int) * LIST_SIZE);

    for (i = 0; i < LIST_SIZE; i++)
    {
        A[i] = 1023;
        B[i] = 1.0;
    }

    // Load the kernel source code into the array source_str
    FILE *fp;
    char *source_str;
    size_t source_size;

    fp = fopen("vector_add_kernel.cl", "r");
    if (!fp)
    {
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    source_str = (char *)malloc(MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);

    // Get platform and device information
    cl_platform_id platform_id = NULL;
    cl_device_id device_id = NULL;
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_DEFAULT, 1,
                         &device_id, &ret_num_devices);

    // Create an OpenCL context
    cl_context context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);

    // Create a command queue
    cl_command_queue command_queue = clCreateCommandQueue(context, device_id, 0, &ret);

    // Create memory buffers on the device for each vector
    cl_mem a_mem_obj = clCreateBuffer(context, CL_MEM_READ_ONLY,
                                      LIST_SIZE * sizeof(int), NULL, &ret);
    cl_mem b_mem_obj = clCreateBuffer(context, CL_MEM_READ_ONLY,
                                      LIST_SIZE * sizeof(int), NULL, &ret);
    cl_mem c_mem_obj = clCreateBuffer(context, CL_MEM_WRITE_ONLY,
                                      LIST_SIZE * sizeof(int), NULL, &ret);

    // Copy the lists A and B to their respective memory buffers
    ret = clEnqueueWriteBuffer(command_queue, a_mem_obj, CL_TRUE, 0,
                               LIST_SIZE * sizeof(int), A, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, b_mem_obj, CL_TRUE, 0,
                               LIST_SIZE * sizeof(int), B, 0, NULL, NULL);

    // Create a program from the kernel source
#ifdef __APPLE__
    cl_program program = clCreateProgramWithSource(context, 1,
                                                   (const char **)&source_str,
                                                   (const size_t *)&source_size,
                                                   &ret);
#else
    char *binary_filename = "vector_add_kernel.aocx";
    cl_program program = createProgramFromBinary(context, binary_filename, device_id);
#endif

    // Build the program
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

    // Create the OpenCL kernel
    cl_kernel kernel = clCreateKernel(program, "vector_add", &ret);

    // Set the arguments of the kernel
    ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&a_mem_obj);
    ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&b_mem_obj);
    ret = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *)&c_mem_obj);

    // Execute the OpenCL kernel on the list
    size_t global_item_size = LIST_SIZE; // Process the entire lists
    size_t local_item_size = 64;         // Divide work items into groups of 64
    ret = clEnqueueNDRangeKernel(command_queue, kernel, 1, NULL,
                                 &global_item_size, &local_item_size, 0, NULL, NULL);

    // Read the memory buffer C on the device to the local variable C
    int *C = (int *)malloc(sizeof(int) * LIST_SIZE);
    ret = clEnqueueReadBuffer(command_queue, c_mem_obj, CL_TRUE, 0,
                              LIST_SIZE * sizeof(int), C, 0, NULL, NULL);

    // Display the result to the screen
    for (i = 0; i < LIST_SIZE; i++)
    {
        printf("%d\n", C[i]);
    }

    // Clean up
    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);
    ret = clReleaseMemObject(a_mem_obj);
    ret = clReleaseMemObject(b_mem_obj);
    ret = clReleaseMemObject(c_mem_obj);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    free(A);
    free(B);
    free(C);
    return 0;
}