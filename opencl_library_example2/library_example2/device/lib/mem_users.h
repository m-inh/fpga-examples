// Copies src[global_id_0] to dst[global_id_0], returns local_id_3.
// Ignores other arguments.
uint copyElement(__global uint* dst, 
                 __global uint *src, 
                 uint global_id, 
                 uint local_id, 
                 uint global_size_0,
                 uint workgroup_size);
  
                 
// Equivalent to:
//
//  for(unsigned i = global_id; i < N; i++) {
//    sum[global_id] += A[i];
//  }
//  return local_id;
uint sumOfElements(__global uint* A,
                   __global uint* sum,
                   uint N,
                   uint global_id,
                   uint local_id,
                   uint global_size,
                   uint workgroup_size);

