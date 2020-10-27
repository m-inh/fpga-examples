#if 0
__kernel void sumOfElements( __global uint* restrict A, __global uint* restrict sum, uint N ) {
  uint global_id = get_global_id(0);
  for(unsigned i = global_id; i < N; i++) {
    sum[global_id] += A[i];
  }
}
#endif

uint sumOfElements( __global uint* A,
                           __global uint* sum,
                           uint N,
                           uint global_id,
                           uint local_id_3,
                           uint global_size,
                           uint workgroup_size) {

  for(unsigned i = global_id; i < N; i++) {
    sum[global_id] += A[i];
  }
  return local_id_3;
}
