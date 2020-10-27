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

// To compile this kernel:
//    perl make_lib.pl, to make lib/mem_users.aoclib.
//    aoc -l lib/mem_users.aoclib -I lib example2.cl, to compile the kernel.


#include "mem_users.h"

// RTL module with NDRange
__kernel void test6( __global uint* restrict A,
                     __global uint* restrict B, 
                     __global uint* restrict C, 
                     uint N ) {
  uint global_id = get_global_id(0);
  uint workgroup_size = get_global_size(0);
  
  C[global_id] = copyElement( 
                               A, // dst
                               B, // src
                               global_id, // global_id
                               global_id, // local_id
                               workgroup_size, // global_size
                               workgroup_size  // workgroup_size
                                ) + 100;
}


// RTL module in a task.
__kernel void test11( __global uint* restrict A,
                      __global uint* restrict B, 
                      __global uint* restrict C, 
                      uint N ) {
  
  for(unsigned i = 0; i < N-1; i++) {
    sumOfElements( 
                  A, // A
                  B, // sum
                  N, // N
                  i, // global_id
                  i, // local_id 
                  N, // global_size
                  N  // workgroup_size
                   );
    C[i+1] = A[i];
  }
}

