// Copyright (C) 2013-2016 Altera Corporation, San Jose, California, USA. All rights reserved.
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


#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>

// ACL specific includes
#include "CL/opencl.h"
#include "AOCLUtils/aocl_utils.h"

#define CHECK(X) assert(CL_SUCCESS == (X))


// ACL runtime configuration
static cl_platform_id platform;
static cl_device_id device;
static cl_context context;
static cl_command_queue queue;
static cl_kernel kernel;
static cl_program program;
static cl_int status;

static cl_mem bufferC;
static cl_mem bufferB;
static cl_mem bufferA;

static void *A;
static void *B;
static void *C;

static unsigned sizeA = 0;
static unsigned sizeB = 0;
static unsigned sizeC = 0;

static unsigned flagBufferA = CL_MEM_READ_WRITE;
static unsigned flagBufferB = CL_MEM_READ_WRITE;

typedef enum {
  INT_TEST,
  UINT_TEST,
  FLOAT_TEST
} TestType;

static void dump_error(const char *str, cl_int status) {
  printf("%s\n", str);
  printf("Error code: %d\n", status);
}

static unsigned char *load_file(const char* filename,size_t*size_ret) {
   FILE* fp;
   int len;
   const size_t CHUNK_SIZE = 1000000;
   unsigned char *result;
   size_t r = 0;
   size_t w = 0;
   fp = fopen(filename,"rb");
   if ( !fp ) return 0;
   // Obtain file size.
   fseek(fp, 0, SEEK_END);
   len = ftell(fp);
   // Go to the beginning.
   fseek(fp, 0, SEEK_SET);
   // Allocate memory for the file data.
   result = (unsigned char*)malloc(len+CHUNK_SIZE);
   if ( !result )
   {
     fclose(fp);
     return 0;
   }
   // Read file.
   while ( 0 < (r=fread(result+w,1,CHUNK_SIZE,fp) ) )
   {
     w+=r;
   }
   fclose(fp);
   *size_ret = w;
   return result;
}


// free the resources allocated during initialization
static void freeResources() {
  if(kernel) 
    clReleaseKernel(kernel);  
  if(program) 
    clReleaseProgram(program);
  if(queue) 
    clReleaseCommandQueue(queue);
  if(bufferA) 
    clReleaseMemObject(bufferA);
  if(bufferB) 
    clReleaseMemObject(bufferB);
  if(bufferC) 
    clReleaseMemObject(bufferC);
  if(A)
    aocl_utils::alignedFree(A);
  if(B)
    aocl_utils::alignedFree(B);
  if(C)
    aocl_utils::alignedFree(C);
  if(context) 
    clReleaseContext(context);
}

bool set_args6(size_t globalSize, size_t localSize) {
  // set the arguments
  status = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&bufferA);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 0.", status);
    return 1;
  }
    
  status = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&bufferB);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 1.", status);
    return 1;
  }

  status = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*)&bufferC);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 2.", status);
    return 1;
  }
  
  int N = globalSize;
  status = clSetKernelArg(kernel, 3, sizeof(cl_int), (void*)&N);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 3.", status);
    return 1;
  }

  return 0;
}

static void init6(size_t globalSize, size_t localSize) { 

  sizeA = sizeB = sizeC = globalSize;

  // allocate and initialize the input vectors
  A = (void *)aocl_utils::alignedMalloc(sizeof(int) * globalSize);
  B = (void *)aocl_utils::alignedMalloc(sizeof(int) * globalSize);
  C = (void *)aocl_utils::alignedMalloc(sizeof(int) * globalSize);
    
  unsigned int* PA = (unsigned int*)A;
  unsigned int* PB = (unsigned int*)B;
  unsigned int* PC = (unsigned int*)C;
  for(unsigned i = 0; i < globalSize; i++) {
    PA[i] = 0;
    PB[i] = i;
    PC[i] = 0;
  }
}

static bool verify6(size_t globalSize, size_t localSize) { 
  unsigned int* PA = (unsigned int*)A;
  unsigned int* PB = (unsigned int*)B;
  unsigned int* PC = (unsigned int*)C;
  for(unsigned gid = 0; gid < globalSize; gid++) {
    if(PA[gid] != PB[gid]) return false;
  }
  return true;
}

#undef ARG_N
#define ARG_N 64
static void init11(size_t globalSize, size_t localSize) { 

  sizeA = sizeB = sizeC = ARG_N;

  // allocate and initialize the input vectors
  A = (void *)aocl_utils::alignedMalloc(sizeof(int) * sizeA);
  B = (void *)aocl_utils::alignedMalloc(sizeof(int) * sizeB);
  C = (void *)aocl_utils::alignedMalloc(sizeof(int) * sizeC);

  unsigned int* PA = (unsigned int*)A;
  unsigned int* PB = (unsigned int*)B;
  unsigned int* PC = (unsigned int*)C;
  for(unsigned i = 0; i < sizeA; i++) {
    PA[i] = i;
    PB[i] = 0;
    PC[i] = 0;
  }
}

bool set_args11(size_t globalSize, size_t localSize) {
  // set the arguments
  status = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*)&bufferA);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 0.", status);
    return 1;
  }
    
  status = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*)&bufferB);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 1.", status);
    return 1;
  }

  status = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*)&bufferC);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 2.", status);
    return 1;
  }
  
  int N = ARG_N;
  status = clSetKernelArg(kernel, 3, sizeof(cl_int), (void*)&N);
  if(status != CL_SUCCESS) {
    dump_error("Failed set arg 3.", status);
    return 1;
  }

  return 0;
}

static bool verify11(size_t globalSize, size_t localSize) { 

  unsigned int* PA = (unsigned int*)A;
  unsigned int* PB = (unsigned int*)B;
  unsigned int* PC = (unsigned int*)C;

  unsigned int refPA[ARG_N];
  for(unsigned i = 0; i < ARG_N; i++) refPA[i] = i;

  for(unsigned i = 0; i < ARG_N - 1; i++) {
    unsigned sum = 0;
    for(unsigned j = i; j < ARG_N; j++) { 
      sum += refPA[j];
    }

    if(sum != PB[i]) {
      printf("PB[%d]=%d, sum=%d\n", i, PB[i], sum);
      return false;
    }

    PC[i+1] = PA[i];
  }

  for(unsigned i = 0; i < ARG_N; i++) {
    if(PA[i] != refPA[i]) {
      printf("refPA[%d]=%d, PA[%d]=%d\n", refPA[i], PA[i]);
      return false;
    }
  }

  return true;
}


#define MAX_KERNELNAME_SIZE 40
typedef struct {
  
  TestType type;
  
  char name[MAX_KERNELNAME_SIZE];
  size_t globalSize;
  size_t localSize;

  bool (*set_args)(size_t globalSize, size_t localSize);
  void (*init)(size_t globalSize, size_t localSize);
  bool (*verify)(size_t globalSize, size_t localSize);
  
} kernel_info;

static const kernel_info test_kernels[] = { 
  { INT_TEST, "test6", 128, 16, set_args6, init6, verify6 },
  { INT_TEST, "test11", 1, 1, set_args11, init11, verify11 },
};

template <class HOST_TYPE, class CL_TYPE>
bool runtest(const char* kernel_name,
             const size_t globalSize,
             const size_t localSize,
             void (*init)(size_t, size_t),
             bool (*set_args)(size_t, size_t),
             bool (*verify)(size_t, size_t)) {

  (*init)(globalSize, localSize);
  
  // create a context
  context = clCreateContext(0, 1, &device, NULL, NULL, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateContext.", status);
    freeResources();
    return false;
  }

  // create a command queue
  queue = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateCommandQueue.", status);
    freeResources();
    return false;
  }
  
  const unsigned char* my_binary;
  size_t my_binary_len = 0;
  cl_int bin_status = 0;

  const char *aocx_name = "bin/example2.aocx";
  printf ("Loading %s ...\n", aocx_name);
  my_binary = load_file (aocx_name, &my_binary_len); 

  if ((my_binary == 0) || (my_binary_len == 0)) { 
   printf("Error: unable to read %s into memory or the file was not found!\n", aocx_name);
   exit(-1);
  }

  program = clCreateProgramWithBinary (context, 1, &device, &my_binary_len, &my_binary, &bin_status, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateProgramWithBinary.", status);
    freeResources();
    return false;
  }  
  
  // build the program
  status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed clBuildProgram.", status);
    freeResources();
    return false;
  }
    
  
  printf("Running %s\n", kernel_name);
  
  // create the kernel
  kernel = clCreateKernel(program, kernel_name, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateKernel.", status);
    freeResources();
    return false;
  }
  
  
  
  // create the input buffer
  bufferA = clCreateBuffer(context, flagBufferA, sizeof(CL_TYPE) * sizeA, NULL, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateBuffer.", status);
    freeResources();
    return false;
  }
    
  // create the input buffer
  bufferB = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(CL_TYPE) * sizeB, NULL, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateBuffer.", status);
    freeResources();
    return false;
  }

  // create the input buffer
  bufferC = clCreateBuffer(context, CL_MEM_READ_WRITE, sizeof(CL_TYPE) * sizeC, NULL, &status);
  if(status != CL_SUCCESS) {
    dump_error("Failed clCreateBuffer.", status);
    freeResources();
    return false;
  }
    
  status = clEnqueueWriteBuffer(queue, bufferA, CL_FALSE, 0, sizeof(CL_TYPE) * sizeA, A, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue write buffer bufferA.", status);
    freeResources();
    return false;
  }
    
  status = clEnqueueWriteBuffer(queue, bufferB, CL_FALSE, 0, sizeof(CL_TYPE) * sizeB, B, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue write buffer bufferB.", status);
    freeResources();
    return false;
  }

  status = clEnqueueWriteBuffer(queue, bufferC, CL_FALSE, 0, sizeof(CL_TYPE) * sizeC, C, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue write buffer bufferC.", status);
    freeResources();
    return false;
  }
   
  
  bool err = (*set_args)(globalSize, localSize);

  if( err ) return false;
        
  printf("Launching the kernel %s with globalsize=%d localSize=%d\n", 
         kernel_name, globalSize, localSize);
    
  // launch kernel
  status = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalSize, &localSize, 0, NULL, NULL);
  if (status != CL_SUCCESS) {
    dump_error("Failed to launch kernel.", status);
    freeResources();
    return false;
  }

  clFinish(queue);
    
  //printf("Kernel execution is complete.\n");

  status = clEnqueueReadBuffer(queue, bufferA, CL_TRUE, 0, sizeof(CL_TYPE) * sizeA, A, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue read buffer bufferB.", status);
    freeResources();
    return false;
  }

  status = clEnqueueReadBuffer(queue, bufferB, CL_TRUE, 0, sizeof(CL_TYPE) * sizeB, B, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue read buffer bufferB.", status);
    freeResources();
    return false;
  }

  status = clEnqueueReadBuffer(queue, bufferC, CL_TRUE, 0, sizeof(CL_TYPE) * sizeC, C, 0, NULL, NULL);
  if(status != CL_SUCCESS) {
    dump_error("Failed to enqueue read buffer bufferC.", status);
    freeResources();
    return false;
  }

  bool success = (*verify)(globalSize, localSize);
    
  // dump
  if(success == false) {
    for(unsigned i = 0; i < sizeA; i++) {
      std::cout << "A[" << i << "]=" << ((HOST_TYPE*)A)[i] << '\n';
    }
    for(unsigned i = 0; i < sizeB; i++) {
      std::cout << "B[" << i << "]=" << ((HOST_TYPE*)B)[i] << '\n';
    }
    for(unsigned i = 0; i < sizeC; i++) {
      std::cout << "C[" << i << "]=" << ((HOST_TYPE*)C)[i] << '\n';
    }
  }

  // free the resources allocated
  freeResources();

  return success;
}

int main() {

  cl_uint num_platforms;
  cl_uint num_devices;

  // get the platform ID
  status = clGetPlatformIDs(1, &platform, &num_platforms);
  if(status != CL_SUCCESS) {
    dump_error("Failed clGetPlatformIDs.", status);
    freeResources();
    return 1;
  }
  if(num_platforms != 1) {
    printf("Found %d platforms!\n", num_platforms);
    freeResources();
    return 1;
  }

  // get the device ID
  status = clGetDeviceIDs(platform, CL_DEVICE_TYPE_ALL, 1, &device, &num_devices);
  if(status != CL_SUCCESS) {
    dump_error("Failed clGetDeviceIDs.", status);
    freeResources();
    return 1;
  }
  if(num_devices != 1) {
    printf("Found %d devices!\n", num_devices);
    freeResources();
    return 1;
  }

  for(unsigned i = 0; i < sizeof(test_kernels) / sizeof(kernel_info); i++) {

    const TestType t = test_kernels[i].type;
    const char* kernel_name = test_kernels[i].name;
    const size_t globalSize = test_kernels[i].globalSize;
    const size_t localSize = test_kernels[i].localSize;
    void (*init)(size_t, size_t) = test_kernels[i].init;
    bool (*set_args)(size_t, size_t) = test_kernels[i].set_args;
    bool (*verify)(size_t, size_t) = test_kernels[i].verify;

    bool success = false;
    if( t == INT_TEST ) {
      success = runtest<int, cl_int> (kernel_name, globalSize, localSize, init, set_args, verify);
    }
    else if( t == FLOAT_TEST ) {
      success = runtest<float, cl_float> (kernel_name, globalSize, localSize, init, set_args, verify);
    }

    if(success == false) { 
      printf("FAILED\n");
      return -1;
    }
  }

  printf("PASSED\n");
  
  return 0;
}

// Needed to be defined by aocl_utils
void cleanup() { freeResources(); }

