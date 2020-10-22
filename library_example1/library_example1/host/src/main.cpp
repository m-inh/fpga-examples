// Copyright (C) 2013-2018 Altera Corporation, San Jose, California, USA. All rights reserved.
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to
// whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// 
// This agreement shall be governed in all respects by the laws of the State of California and
// by the laws of the United States of America.

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cstring>
#include "CL/opencl.h"
#include "AOCLUtils/aocl_utils.h"

using namespace aocl_utils;

#define STRING_BUFFER_LEN 1024


// Runtime constants
static unsigned int BUFSIZE = 4*1024*1024;

// OpenCL runtime configuration
static cl_platform_id platform = NULL;
static cl_device_id device = NULL;
static cl_context context = NULL;
static cl_command_queue queue = NULL;
static cl_kernel kernel_lib = NULL;
static cl_kernel kernel_builtin = NULL;
static cl_program program = NULL;
static cl_mem input = NULL;
static cl_mem output_lib = NULL;
static cl_mem output_builtin = NULL;
static cl_int N = 1;


// Function prototypes
bool init();
void cleanup();
static void device_info_ulong( cl_device_id device, cl_device_info param, const char* name);
static void device_info_uint( cl_device_id device, cl_device_info param, const char* name);
static void device_info_bool( cl_device_id device, cl_device_info param, const char* name);
static void device_info_string( cl_device_id device, cl_device_info param, const char* name);
static void display_device_info( cl_device_id device );

// Entry point.
int main(int argc, char** argv) {

   bool emulator_run = false;
   if ( (argc > 1) && (strcmp (argv[1], "-emulator") == 0) ) {
      emulator_run = true;
   }
   if (emulator_run) {
      BUFSIZE /= 1024;
      printf ("Shortened test size to %d for emulator run.\n", BUFSIZE);
   }
  cl_int status;

  if(!init()) {
    return -1;
  }

  // Generate random input data
  unsigned int *data_in      = (unsigned int *) aocl_utils::alignedMalloc(BUFSIZE*sizeof(unsigned int));
  printf("Generate random data for conversion...\n");
  srand( 1 );   
  for ( int i = 0; i < BUFSIZE ; i++ ) {
    data_in[i] = rand();
  }
  status = clEnqueueWriteBuffer(queue,input,0,0,BUFSIZE*sizeof(unsigned int),data_in,0,0,0);
  checkError(status, "Failed to enqueue writing to input buffer");

  // Set the kernel arguments for kernel_lib
  status = clSetKernelArg(kernel_lib,0,sizeof(cl_mem),&input);
  checkError(status, "Failed to set kernel_lib arg 0");
  status = clSetKernelArg(kernel_lib,1,sizeof(cl_mem),&output_lib);
  checkError(status, "Failed to set kernel_lib arg 1");
  status = clSetKernelArg(kernel_lib,2,sizeof(cl_int),&N) ;
  checkError(status, "Failed to set kernel_lib arg 2");
  
  // Set the kernel arguments for kernel_builtin
  status = clSetKernelArg(kernel_builtin,0,sizeof(cl_mem),&input);
  checkError(status, "Failed to set kernel_lib arg 0");
  status = clSetKernelArg(kernel_builtin,1,sizeof(cl_mem),&output_builtin);
  checkError(status, "Failed to set kernel_lib arg 1");
  status = clSetKernelArg(kernel_builtin,2,sizeof(cl_int),&N) ;
  checkError(status, "Failed to set kernel_lib arg 2");

  // Configure work set over which the kernel will execute
  size_t gSize = BUFSIZE/N;
  size_t lSize = 1; 

  // Launch the kernels
  int NUM_ITERATIONS = 4;
  printf("Enqueueing both library and builtin in kernels %d times with global size %d\n", NUM_ITERATIONS, (int) gSize);

  // Launch kernel_lib
  double lib_start = aocl_utils::getCurrentTimestamp();
  for (int i = 0; i < NUM_ITERATIONS; i++) {
    status = clEnqueueNDRangeKernel(queue, kernel_lib, 1, NULL, &gSize, &lSize, 0, NULL, NULL);
    checkError(status, "Failed to launch kernel_lib");
  }
  status = clFinish(queue);
  checkError(status, "Failed to finish");
  double lib_stop = aocl_utils::getCurrentTimestamp();
  printf ("Kernel computation using library function took %g seconds\n", lib_stop - lib_start);

  // Launch kernel_builtin
  double builtin_start = aocl_utils::getCurrentTimestamp();
  for (int i = 0; i < NUM_ITERATIONS; i++) {
    status = clEnqueueNDRangeKernel(queue, kernel_builtin, 1, NULL, &gSize, &lSize, 0, NULL, NULL);
    checkError(status, "Failed to launch kernel_builtin");
  }
  status = clFinish(queue);
  checkError(status, "Failed to finish");
  double builtin_stop = aocl_utils::getCurrentTimestamp();
  printf ("Kernel computation using builtin function took %g seconds\n", builtin_stop - builtin_start);
  double time_ratio = (lib_stop - lib_start) / (builtin_stop - builtin_start);

  // Reading results to buffer
  printf("Reading results to buffers...\n");
  unsigned int *data_out_lib = (unsigned int *) aocl_utils::alignedMalloc(BUFSIZE*sizeof(unsigned int));
  status = clEnqueueReadBuffer(queue, output_lib, 1, 0, BUFSIZE*sizeof(unsigned int), data_out_lib, 0, 0, 0);
  checkError(status, "Failed to enqueue read buffer output_lib to data_out_lib");
  status = clFinish(queue);
  checkError(status, "Failed to read buffer output_lib to data_out_lib");

  unsigned int *data_out_builtin = (unsigned int *) aocl_utils::alignedMalloc(BUFSIZE*sizeof(unsigned int));
  status = clEnqueueReadBuffer(queue, output_builtin, 1, 0, BUFSIZE*sizeof(unsigned int), data_out_builtin, 0, 0, 0);
  checkError(status, "Failed to enqueue read buffer output_builtin to data_out_builtin");
  status = clFinish(queue);
  checkError(status, "Failed to read buffer output_builtin to data_out_builtin");

  printf("Checking results...\n");

  int num_printed, num_errs = 0;
  for (int i = 0; i < BUFSIZE; i++ )
  {
    if (data_out_lib[i] != data_out_builtin[i] || 
        data_out_lib[i] == 0 && data_out_builtin[i] == 0 && data_in[i] != 0 ) {
      num_errs++;
      if (num_printed < 10) {
        printf ("ERROR at i=%d, library = %08x, builtin = %08x, datain = %08x\n", i, data_out_lib[i], data_out_builtin[i], data_in[i]);
        num_printed++;
      }
    }
  }

  if ( num_errs > 0 ) { 
    printf("FAILED with %i errors.\n", num_errs);
  } else {
    printf("PASSED\n");
  }

  // Free the resources allocated
  cleanup();
  aocl_utils::alignedFree(data_in);
  aocl_utils::alignedFree(data_out_lib);
  aocl_utils::alignedFree(data_out_builtin);


  return 0;
}

/////// HELPER FUNCTIONS ///////

bool init() {
  cl_int status;

  if(!setCwdToExeDir()) {
    return false;
  }

  // Get the OpenCL platform.
  platform = findPlatform("Intel(R) FPGA SDK for OpenCL(TM)");
  if(platform == NULL) {
    printf("ERROR: Unable to find Intel(R) FPGA OpenCL platform.\n");
    return false;
  }

  // User-visible output - Platform information
  {
    char char_buffer[STRING_BUFFER_LEN]; 
    printf("Querying platform for info:\n");
    printf("==========================\n");
    clGetPlatformInfo(platform, CL_PLATFORM_NAME, STRING_BUFFER_LEN, char_buffer, NULL);
    printf("%-40s = %s\n", "CL_PLATFORM_NAME", char_buffer);
    clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, STRING_BUFFER_LEN, char_buffer, NULL);
    printf("%-40s = %s\n", "CL_PLATFORM_VENDOR ", char_buffer);
    clGetPlatformInfo(platform, CL_PLATFORM_VERSION, STRING_BUFFER_LEN, char_buffer, NULL);
    printf("%-40s = %s\n\n", "CL_PLATFORM_VERSION ", char_buffer);
  }

  // Query the available OpenCL devices.
  scoped_array<cl_device_id> devices;
  cl_uint num_devices;

  devices.reset(getDevices(platform, CL_DEVICE_TYPE_ALL, &num_devices));

  // We'll just use the first device.
  device = devices[0];

  // Display some device information.
  display_device_info(device);

  // Create the context.
  context = clCreateContext(NULL, 1, &device, &oclContextCallback, NULL, &status);
  checkError(status, "Failed to create context");

  // Create the command queue.
  queue = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
  checkError(status, "Failed to create command queue");

  // Create the program.
  std::string binary_file = getBoardBinaryFile("example1", device);
  printf("Using AOCX: %s\n", binary_file.c_str());
  program = createProgramFromBinary(context, binary_file.c_str(), &device, 1);

  // Build the program that was just created.
  status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
  checkError(status, "Failed to build program");

  // Create the kernel - name passed in here must match kernel name in the
  // original CL file, that was compiled into an AOCX file using the AOC tool
  kernel_lib = clCreateKernel(program, "test_lib", &status);
  checkError(status, "Failed to create kernel_lib");

  kernel_builtin = clCreateKernel(program, "test_builtin", &status);
  checkError(status, "Failed to create kernel_builtin");


  // Create the input and output buffers
  input = clCreateBuffer(context, CL_MEM_READ_ONLY, BUFSIZE*sizeof(unsigned int), 0, &status);
  checkError(status, "Failed to create the input buffer");
  output_lib = clCreateBuffer(context, CL_MEM_WRITE_ONLY, BUFSIZE*sizeof(unsigned int), 0, &status);
  checkError(status, "Failed to create the output_lib buffer");
  output_builtin = clCreateBuffer(context, CL_MEM_WRITE_ONLY, BUFSIZE*sizeof(unsigned int), 0, &status);
  checkError(status, "Failed to create the output_builtin buffer");
  return true;
}

// Free the resources allocated during initialization
void cleanup() {
  if(kernel_lib) {
    clReleaseKernel(kernel_lib);  
  }
  if(kernel_builtin){
    clReleaseKernel(kernel_builtin);
  }
  if(program) {
    clReleaseProgram(program);
  }
  if(queue) {
    clReleaseCommandQueue(queue);
  }
  if(context) {
    clReleaseContext(context);
  }
  if(input){
    clReleaseMemObject(input);
  }
  if(output_lib){
    clReleaseMemObject(output_lib);
  }
  if(output_builtin){
    clReleaseMemObject(output_builtin);
  }
}

// Helper functions to display parameters returned by OpenCL queries
static void device_info_ulong( cl_device_id device, cl_device_info param, const char* name) {
  cl_ulong a;
  clGetDeviceInfo(device, param, sizeof(cl_ulong), &a, NULL);
  printf("%-40s = %lu\n", name, a);
}
static void device_info_uint( cl_device_id device, cl_device_info param, const char* name) {
  cl_uint a;
  clGetDeviceInfo(device, param, sizeof(cl_uint), &a, NULL);
  printf("%-40s = %u\n", name, a);
}
static void device_info_bool( cl_device_id device, cl_device_info param, const char* name) {
  cl_bool a;
  clGetDeviceInfo(device, param, sizeof(cl_bool), &a, NULL);
  printf("%-40s = %s\n", name, (a?"true":"false"));
}
static void device_info_string( cl_device_id device, cl_device_info param, const char* name) {
  char a[STRING_BUFFER_LEN]; 
  clGetDeviceInfo(device, param, STRING_BUFFER_LEN, &a, NULL);
  printf("%-40s = %s\n", name, a);
}

// Query and display OpenCL information on device and runtime environment
static void display_device_info( cl_device_id device ) {

  printf("Querying device for info:\n");
  printf("========================\n");
  device_info_string(device, CL_DEVICE_NAME, "CL_DEVICE_NAME");
  device_info_string(device, CL_DEVICE_VENDOR, "CL_DEVICE_VENDOR");
  device_info_uint(device, CL_DEVICE_VENDOR_ID, "CL_DEVICE_VENDOR_ID");
  device_info_string(device, CL_DEVICE_VERSION, "CL_DEVICE_VERSION");
  device_info_string(device, CL_DRIVER_VERSION, "CL_DRIVER_VERSION");
  device_info_uint(device, CL_DEVICE_ADDRESS_BITS, "CL_DEVICE_ADDRESS_BITS");
  device_info_bool(device, CL_DEVICE_AVAILABLE, "CL_DEVICE_AVAILABLE");
  device_info_bool(device, CL_DEVICE_ENDIAN_LITTLE, "CL_DEVICE_ENDIAN_LITTLE");
  device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, "CL_DEVICE_GLOBAL_MEM_CACHE_SIZE");
  device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, "CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE");
  device_info_ulong(device, CL_DEVICE_GLOBAL_MEM_SIZE, "CL_DEVICE_GLOBAL_MEM_SIZE");
  device_info_bool(device, CL_DEVICE_IMAGE_SUPPORT, "CL_DEVICE_IMAGE_SUPPORT");
  device_info_ulong(device, CL_DEVICE_LOCAL_MEM_SIZE, "CL_DEVICE_LOCAL_MEM_SIZE");
  device_info_ulong(device, CL_DEVICE_MAX_CLOCK_FREQUENCY, "CL_DEVICE_MAX_CLOCK_FREQUENCY");
  device_info_ulong(device, CL_DEVICE_MAX_COMPUTE_UNITS, "CL_DEVICE_MAX_COMPUTE_UNITS");
  device_info_ulong(device, CL_DEVICE_MAX_CONSTANT_ARGS, "CL_DEVICE_MAX_CONSTANT_ARGS");
  device_info_ulong(device, CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, "CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE");
  device_info_uint(device, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, "CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS");
  device_info_uint(device, CL_DEVICE_MEM_BASE_ADDR_ALIGN, "CL_DEVICE_MEM_BASE_ADDR_ALIGN");
  device_info_uint(device, CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, "CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT");
  device_info_uint(device, CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, "CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE");

  {
    cl_command_queue_properties ccp;
    clGetDeviceInfo(device, CL_DEVICE_QUEUE_PROPERTIES, sizeof(cl_command_queue_properties), &ccp, NULL);
    printf("%-40s = %s\n", "Command queue out of order? ", ((ccp & CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE)?"true":"false"));
    printf("%-40s = %s\n", "Command queue profiling enabled? ", ((ccp & CL_QUEUE_PROFILING_ENABLE)?"true":"false"));
  }
}

