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

/******************************************************************************
** File: tdFir.c
**
** HPEC Challenge Benchmark Suite
** TDFIR Kernel Benchmark
**
** Contents: This file provides definitions for various functions in support
**           of the generic C TDFIR implementation.
**            Inputs: ./<dataset>-tdFir-input.dat
**                    ./<dataset>-tdFir-filter.dat
**            Outputs:./<dataset>-tdFir-output.dat
**                    ./<dataset>-tdFir-time.dat
**
** Author: Matthew A. Alexander
**         MIT Lincoln Laboratory
**
******************************************************************************/

#include "tdFir.h"
#include <stdlib.h>
#include <stdio.h>
#include "AOCLUtils/aocl_utils.h"

using namespace aocl_utils;

#define RUN_ON_FPGA 1
#define STRING_BUFFER_LEN 1024

// ACL runtime configuration
static cl_platform_id platform = NULL;
static cl_device_id device = NULL;
static cl_context context = NULL;
static cl_command_queue queue = NULL;
static cl_kernel kernel = NULL;
static cl_program program = NULL;
static cl_int status = 0;
#if USE_SVM_API == 0
cl_mem dev_datainput;
cl_mem dev_filterconst;
cl_mem dev_result;
#else
float *dev_filterconst;
#endif /* USE_SVM_API == 0 */
cl_event myEvent;

// Helper Function prototypes
bool initFPGA();
void cleanup();


int main(int argc, char **argv)
{
  struct tdFirVariables tdFirVars;

  tdFirVars.arguments = 1;
  tdFirVars.dataSet = 1;

  if(!setCwdToExeDir()) {
    return -1;
  }

  /*
    I need to declare some variables:
      -pointers to data, filter, and result
      -inputLength;
    These are all in the tdFirVariables structure in tdFir.h
    Along with the structure definition, I also instantiate an
    instanced called tdFirVars.  This is the same as doing:

    struct tdFirVaribles tdFirVars;
  */

  /*
    In tdFirSetup, I want to perform tasks that I do NOT want to include
    in my timing.  For example:
      -allocating space for data, filter, and result
	  The declarations for this function can be found in tdFir.h, while
    the definitions of these functions can be found in tdFir.c.
  */
  tdFirSetup(&tdFirVars);

  if (RUN_ON_FPGA)
  {
    // Perform FIR computation on FPGA
    if(!initFPGA()) {
      return -1;
    }
    tdFirFPGA(&tdFirVars);
  }
  else
  {
    // Perform FIR computation on CPU
    tdFirCPU(&tdFirVars);
  }

  /*
    In tdFirComplete(), I first want to output my result to output.dat.
    I then want to do any required clean up.
  */
  tdFirComplete(&tdFirVars);

  /*
    Run the verification routine to ensure that our results were correct.
  */
  tdFirVerify(&tdFirVars);
  tdFirVerifyComplete(&tdFirVars);

  return 0;
}


/*
  In tdFirSetup, I want to perform tasks that I do NOT want to include
  in my timing.  For example:
    -allocating space for data, filter, result
    -read in inputs and initalize the result space to 0.
  The declarations for this function can be found in tdFir.h, while
  the definitions of these functions can be found in tdFir.c.
*/
void tdFirSetup(struct tdFirVariables *tdFirVars)
{
  int inputLength, filterLength, resultLength;
  char dataSetString[100];
  char filterSetString[100];

  sprintf(  dataSetString,"./%d-tdFir-input.dat" ,tdFirVars->dataSet);
  sprintf(filterSetString,"./%d-tdFir-filter.dat",tdFirVars->dataSet);

  /*
    input read from file 'input.dat', and stored at:   tdFirVars->input.data
    fileter read from file 'filter.dat' and stored at: tdFirVars->filter.data
  */
  readFromFile(float, dataSetString, tdFirVars->input);
  readFromFile(float, filterSetString, tdFirVars->filter);

  pca_create_carray_1d(float, tdFirVars->time, 1, PCA_REAL);

  inputLength            = tdFirVars->input.size[1];
  filterLength           = tdFirVars->filter.size[1];
  resultLength           = inputLength + filterLength - 1;
  tdFirVars->numFilters   = tdFirVars->filter.size[0];
  tdFirVars->inputLength  = tdFirVars->input.size[1];
  tdFirVars->filterLength = tdFirVars->filter.size[1];
  tdFirVars->resultLength = resultLength;
  tdFirVars->time.data[0] = 0.0f;
  tdFirVars->time.data[1] = 0.0f;
  tdFirVars->time.data[2] = 0.0f;

  pca_create_carray_2d(float, tdFirVars->result, tdFirVars->numFilters, resultLength, PCA_COMPLEX);
  /*
    Make sure that the result starts out as 0.
  */
  zeroData(tdFirVars->result.data, resultLength, tdFirVars->numFilters);
}

/*
 * This is the original Time Domain FIR Filter implementation to be
 * executed on CPU
 */
void tdFirCPU(struct tdFirVariables *tdFirVars)
{
  int index;
  int filter;
  float * inputPtr  = tdFirVars->input.data;
  float * filterPtr = tdFirVars->filter.data;
  float * resultPtr = tdFirVars->result.data;
  float * inputPtrSave  = tdFirVars->input.data;
  float * filterPtrSave = tdFirVars->filter.data;
  float * resultPtrSave = tdFirVars->result.data;
  int  filterLength = tdFirVars->filterLength;
  int  inputLength  = tdFirVars->inputLength;
  int  resultLength = filterLength + inputLength - 1;
  double startTime = getCurrentTimestamp();
  double stopTime = 0.0f;

  for(filter = 0; filter < tdFirVars->numFilters; filter++)
  {
    inputPtr  = inputPtrSave  + (filter * (2*inputLength));
    filterPtr = filterPtrSave + (filter * (2*filterLength));
    resultPtr = resultPtrSave + (filter * (2*resultLength));

    /*
    	elCplxMul does an element wise multiply of the current filter element by
    	the entire input vector.
    	Input Parameters:
    	tdFirVars->input.data  - pointer to input
    	tdFirVars->filter.data - pointer to filter
    	tdFirVars->result.data - pointer to result space
    	tdFirVars->inputLength - integer value representing length of input
     */
    for(index = 0; index < filterLength; index++)
	  {
  	  elCplxMul(inputPtr, filterPtr, resultPtr, tdFirVars->inputLength);
  	  resultPtr+=2;
  	  filterPtr+=2;
  	}/* end for filterLength*/
  }/* end for each filter */

  /*
    Stop the timer.  Print out the
    total time in Seconds it took to do the TDFIR.
  */
  stopTime = getCurrentTimestamp();
  tdFirVars->time.data[0] = stopTime - startTime;

  printf("Done.\n  Latency: %f s.\n", tdFirVars->time.data[0]);
  printf("  Throughput: %.3f GFLOPs.\n", 268.44f / tdFirVars->time.data[0] / 1000.0f );
}

/*
  elCplxMul does an element wise multiply of the current filter element by
  the entire input vector.
 */
void elCplxMul(float *dataPtr, float *filterPtr, float *resultPtr, int inputLength)
{
  int index;
  float filterReal = *filterPtr;
  float filterImag = *(filterPtr+1);

  for(index = 0; index < inputLength; index++)
  {
    /*      COMPLEX MULTIPLY   */
    /* real  */
    *resultPtr += (*dataPtr) * filterReal - (*(dataPtr+1)) * filterImag;
    resultPtr++;
    /* imag  */
    *resultPtr += (*dataPtr) * filterImag + (*(dataPtr+1)) * filterReal;
    resultPtr++;
    dataPtr+=2;
  }
}

/*
  This routine sets up the TDFIR kernel parameters and runs it on the FPGA

  The filterLength here is obtained from the data file, and should be
  kept consistent with what the kernel is compiled with.
  By default, the kernel is compiled with 128 taps.

  To improve the efficiency of the kernel, we insert padding to the input data and the
  result data arrays.  Thus, we first allocate a larger data array

 */
void tdFirFPGA(struct tdFirVariables *tdFirVars)
{
  int err;
  double startTime, stopTime;

  // These are the pointers to original input data and filter constants provided
  float * inputPtr  = tdFirVars->input.data;
  float * filterPtr = tdFirVars->filter.data;
  // This is the pointer of the computed result
  float * resultPtr = tdFirVars->result.data;

  int  filterLength = tdFirVars->filterLength;
  int  inputLength  = tdFirVars->inputLength;
  int  resultLength = filterLength + inputLength - 1;

  // These are pointers to the padded input and result data.
  // We will copy data to and from the original arrays.
  float * paddedInputPtr = 0;
  float * paddedResultPtr = 0;

  // padded number of points per filter, 16 points of zero when we are loading
  // the filter coefficients and 127 points of zero at the end when we're
  // computing the tail end for the result
  unsigned paddedNumInputPoints = inputLength + 16 + (filterLength - 1);
  //each point is a complex, so need to multiply be 2 (for real, imag)
  unsigned paddedSingleInputLength = 2 * paddedNumInputPoints;
  //this is the size of the input data buffers we need to allocate
  unsigned totalDataInputLength = paddedSingleInputLength * tdFirVars->numFilters;
  //this is the number of total points we are computing
  unsigned totalDataInputLengthKernelArg = paddedNumInputPoints * tdFirVars->numFilters;
  // these are just 1 less than the padded single input points, used as a parameter
  // for the kernel to know when to start loading in the next set of filter
  // coefficients
  unsigned paddedSingleInputLengthMinus1KernelArg = paddedNumInputPoints - 1;
  unsigned paddedSingleInputLengthMinus1 = paddedSingleInputLength - 1;

  // we padd the beginning of the result buffer with 16 complex points of zero
  unsigned paddedNumResultLength = 2*(resultLength+16);

#if USE_SVM_API == 1
  dev_filterconst = (float*)clSVMAlloc(context, CL_MEM_READ_WRITE,
	  sizeof(float) * 2 * filterLength * tdFirVars->numFilters, 0);
  if (!dev_filterconst) {
    checkError(-1, "Failed to allocate filter const memory!");
  }
  status = clEnqueueSVMMap(queue, CL_TRUE, CL_MAP_WRITE,
      (void *)dev_filterconst, sizeof(float) * 2 * filterLength * tdFirVars->numFilters, 0, NULL, NULL);
  checkError(status, "Failed to map filter const");
  memcpy(dev_filterconst, filterPtr, sizeof(float) * 2 * filterLength * tdFirVars->numFilters);
  status = clEnqueueSVMUnmap(queue, (void *)dev_filterconst, 0, NULL, NULL);
  checkError(status, "Failed to unmap filter const");
#endif /* USE_SVM_API == 1 */

  startTime = getCurrentTimestamp();

  // this assumes that the inputLength is the same for each filter
#if USE_SVM_API == 0
  dev_datainput = clCreateBuffer(context, CL_MEM_READ_ONLY,
                        sizeof(float)*totalDataInputLength, NULL, &err);
  checkError(err, "Failed to allocate device memory!");
  dev_filterconst = clCreateBuffer(context,
                        CL_MEM_READ_ONLY | CL_CHANNEL_2_INTELFPGA,
                        sizeof(float)* 2 * filterLength * tdFirVars->numFilters,
                        NULL, &err);
  checkError(err, "Failed to allocate device memory!");
  dev_result = clCreateBuffer(context, CL_MEM_WRITE_ONLY | CL_CHANNEL_2_INTELFPGA,
                        sizeof(float) * paddedNumResultLength * tdFirVars->numFilters,
                        NULL, &err);
  checkError(err, "Failed to allocate device memory!");

  paddedInputPtr = (float* ) alignedMalloc(sizeof(float) * totalDataInputLength);
#else
  paddedInputPtr = (float*)clSVMAlloc(context, CL_MEM_READ_WRITE, sizeof(float) * totalDataInputLength, 0);
  if (!paddedInputPtr) {
    checkError(-1, "Failed to allocate padded input memory!");
  }
  status = clEnqueueSVMMap(queue, CL_TRUE, CL_MAP_WRITE,
      (void *)paddedInputPtr, sizeof(float) * totalDataInputLength, 0, NULL, NULL);
  checkError(status, "Failed to map padded input");
#endif /* USE_SVM_API == 0 */
  memset(paddedInputPtr, '\0', sizeof(float) * totalDataInputLength);

  // Need to copy the input data into the padded structure
  // (with an offset of 16 complex points)
  for (int filter = 0; filter < tdFirVars->numFilters; filter++)
  {
    memcpy(paddedInputPtr + filter * paddedSingleInputLength + 32,
           inputPtr + (filter * (2*inputLength)),
           sizeof(float) * 2 * inputLength);
  }

#if USE_SVM_API == 0
  paddedResultPtr = (float* ) alignedMalloc(
					sizeof(float) * paddedNumResultLength * tdFirVars->numFilters);
#else
  paddedResultPtr = (float*)clSVMAlloc(context, CL_MEM_READ_WRITE,
                  sizeof(float) * paddedNumResultLength * tdFirVars->numFilters, 0);
  if (!paddedResultPtr) {
    checkError(-1, "Failed to allocate padded result memory!");
  }
  status = clEnqueueSVMMap(queue, CL_TRUE, CL_MAP_WRITE,
      (void *)paddedResultPtr, sizeof(float) * paddedNumResultLength * tdFirVars->numFilters, 0, NULL, NULL);
  checkError(status, "Failed to map padded result");
#endif /* USE_SVM_API == 0 */
  memset(paddedResultPtr, '\0',
		 sizeof(float) * paddedNumResultLength * tdFirVars->numFilters);

#if USE_SVM_API == 0
  err = clEnqueueWriteBuffer(queue, dev_datainput, CL_TRUE, 0,
                     sizeof(float)*totalDataInputLength,
                     paddedInputPtr, 0, NULL, &myEvent);
  checkError(err, "Failed to write input buffer!");
  err = clEnqueueWriteBuffer(queue, dev_filterconst, CL_TRUE, 0,
                     sizeof(float) * 2 * filterLength * tdFirVars->numFilters,
                     filterPtr, 0, NULL, &myEvent);
  checkError(err, "Failed to write filterconst!");
  clFinish(queue);
#else
  status = clEnqueueSVMUnmap(queue, (void *)paddedInputPtr, 0, NULL, NULL);
  checkError(status, "Failed to unmap padded input");
  status = clEnqueueSVMUnmap(queue, (void *)paddedResultPtr, 0, NULL, NULL);
  checkError(status, "Failed to unmap padded result");
#endif /* USE_SVM_API == 0 */

  printf("tdFirVars: inputLength = %d, resultLength = %d, filterLen = %d\n",
         inputLength, resultLength, filterLength);

#if USE_SVM_API == 0
  err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &dev_datainput);
  err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &dev_filterconst);
  err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &dev_result);
#else
  err = clSetKernelArgSVMPointer(kernel, 0, (void *)paddedInputPtr);
  err |= clSetKernelArgSVMPointer(kernel, 1, (void *)dev_filterconst);
  err |= clSetKernelArgSVMPointer(kernel, 2, (void *)paddedResultPtr);
#endif /* USE_SVM_API == 0 */
  err |= clSetKernelArg(kernel, 3, sizeof(unsigned int),
                        &totalDataInputLengthKernelArg);
  err |= clSetKernelArg(kernel, 4, sizeof(unsigned int),
                        &paddedSingleInputLengthMinus1KernelArg);
  checkError(err, "Failed to set compute kernel arguments!");
  size_t my_size = 1;

  stopTime = getCurrentTimestamp();
  tdFirVars->time.data[1] += (float)(stopTime - startTime);

  startTime = getCurrentTimestamp();

  // This runs the actual TDFIR implementation on FPGA
  err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL,
                               &my_size, &my_size, 0, NULL, &myEvent);
  clFinish(queue);
  stopTime = getCurrentTimestamp();
  checkError(err, "Failed to execute tdfir kernel!");

  tdFirVars->time.data[0] = (float)(stopTime - startTime);

  startTime = getCurrentTimestamp();
#if USE_SVM_API == 0
  err = clEnqueueReadBuffer(queue, dev_result, CL_TRUE, 0,
                sizeof(float) * paddedNumResultLength * tdFirVars->numFilters,
                paddedResultPtr, 0, NULL, &myEvent);
  checkError(err, "Failed to read result array!");
#else
  status = clEnqueueSVMMap(queue, CL_TRUE, CL_MAP_WRITE,
      (void *)paddedResultPtr, sizeof(float) * paddedNumResultLength * tdFirVars->numFilters, 0, NULL, NULL);
  checkError(status, "Failed to map padded result");
#endif /* USE_SVM_API == 0 */
  clFinish(queue);

  // Copy the result into the original result array, by starting
  // at an offset of 16 complex points
  for (int filter = 0; filter < tdFirVars->numFilters; filter++)
  {
	  memcpy(resultPtr + 2*filter*resultLength,
	         paddedResultPtr + filter * paddedNumResultLength + 32,
	         sizeof(float) * 2 * resultLength);
  }

  stopTime = getCurrentTimestamp();
  tdFirVars->time.data[1] += (float)(stopTime - startTime);

#if USE_SVM_API == 0
  if (paddedInputPtr)
     alignedFree(paddedInputPtr);
  if (paddedResultPtr)
     alignedFree(paddedResultPtr);
#else
  status = clEnqueueSVMUnmap(queue, (void *)paddedResultPtr, 0, NULL, NULL);
  checkError(status, "Failed to unmap padded result");

  if(dev_filterconst)
	   clSVMFree(context, dev_filterconst);
  if (paddedInputPtr)
     clSVMFree(context, paddedInputPtr);
  if (paddedResultPtr)
     clSVMFree(context, paddedResultPtr);
#endif /* USE_SVM_API == 0 */
  cleanup();
  // Print out the total time and throughput for the TDFIR computation
  printf("Done.\n  Latency: %f s.\n", tdFirVars->time.data[0]);
  printf("  Buffer Setup Time: %f s.\n", tdFirVars->time.data[1]);
  printf("  Throughput: %.3f GFLOPs.\n",
		 0.26844f / tdFirVars->time.data[0] );
}


/////// HELPER FUNCTIONS ///////

bool initFPGA() {
  cl_int status;

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

#if USE_SVM_API == 1
  cl_device_svm_capabilities caps = 0;

  status = clGetDeviceInfo(
    device,
    CL_DEVICE_SVM_CAPABILITIES,
    sizeof(cl_device_svm_capabilities),
    &caps,
    0
  );
  checkError(status, "Failed to get device info");

  if (!(caps & CL_DEVICE_SVM_COARSE_GRAIN_BUFFER)) {
    printf("The host was compiled with USE_SVM_API, however the device currently being targeted does not support SVM.\n");
    // Free the resources allocated
    cleanup();
    return false;
  }
#endif /* USE_SVM_API == 1 */

  // Create the context.
  context = clCreateContext(NULL, 1, &device, &oclContextCallback, NULL, &status);
  checkError(status, "Failed to create context");

  // Create the command queue.
  queue = clCreateCommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE, &status);
  checkError(status, "Failed to create command queue");

  // Create the program.
  std::string binary_file = getBoardBinaryFile("tdfir", device);
  printf("Using AOCX: %s\n", binary_file.c_str());
  program = createProgramFromBinary(context, binary_file.c_str(), &device, 1);

  // Build the program that was just created.
  status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
  checkError(status, "Failed to build program");

  // Create the kernel - name passed in here must match kernel name in the
  // original CL file, that was compiled into an AOCX file using the AOC tool
  const char *kernel_name = "tdfir";  // Kernel name, as defined in the CL file
  kernel = clCreateKernel(program, kernel_name, &status);
  checkError(status, "Failed to create kernel");

  return true;
}

// Free the resources allocated during initialization
void cleanup() {
  if(kernel)
    clReleaseKernel(kernel);
  if(program)
    clReleaseProgram(program);
  if(queue)
    clReleaseCommandQueue(queue);
  if(context)
    clReleaseContext(context);
  if (myEvent)
    clReleaseEvent(myEvent);

#if USE_SVM_API == 0
  if(dev_datainput)
    clReleaseMemObject(dev_datainput);
  if(dev_filterconst) 
    clReleaseMemObject(dev_filterconst);
  if(dev_result)
    clReleaseMemObject(dev_result);
#endif
}

void printVector(float * dataPtr, int inputLength)
{
  int index;
  printf("Start of Vector: \n");
  for(index = 0; index < inputLength; index++)
  {
    printf("(%f,%fi) \n",*dataPtr, *(dataPtr+1));
    dataPtr = dataPtr + 2;
  }
  printf("End of Vector. \n");
}

void zeroData(float *dataPtr, int length, int filters)
{
  int index, filter;

  for(filter = 0; filter < filters; filter++)
  {
    for(index = 0; index < length; index++)
    {
      *dataPtr = 0;
      dataPtr++;
      *dataPtr = 0;
      dataPtr++;
    }
  }
}

/*
  In tdFirComplete, I want to do any required clean up.
    -...
*/
void tdFirComplete(struct tdFirVariables *tdFirVars)
{
  char timeString[100];
  char outputString[100];
  sprintf(timeString,"./%d-tdFir-time.dat",tdFirVars->dataSet);
  sprintf(outputString,"./%d-tdFir-output.dat",tdFirVars->dataSet);

  writeToFile(float, outputString, tdFirVars->result);
  writeToFile(float, timeString, tdFirVars->time);

  clean_mem(float, tdFirVars->input);
  clean_mem(float, tdFirVars->filter);
  clean_mem(float, tdFirVars->result);
  clean_mem(float, tdFirVars->time);
}

/* ----------------------------------------------------------------------------
Copyright (c) 2006, Massachusetts Institute of Technology
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the Massachusetts Institute of Technology nor
       the names of its contributors may be used to endorse or promote
       products derived from this software without specific prior written
       permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------- */
