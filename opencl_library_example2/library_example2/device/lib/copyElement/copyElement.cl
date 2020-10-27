//__kernel void copyElement(__global uint* dst, __global uint* src) {
//  uint global_id = get_global_id(0);
//  dst[global_id] = src[global_id];
//}

uint copyElement(__global uint* dst,
                 __global uint *src,
                 uint global_id_0,
                 uint local_id_3,
                 uint global_size_0,
                 uint workgroup_size) {

  dst[global_id_0] = src[global_id_0];
  return local_id_3;
}

