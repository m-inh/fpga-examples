__kernel void vector_add(
    __global const float *x, 
    __global const float *y,
    __global float *restrict z
    ) 
{
  // get index of the work item
  int i = get_global_id(0);

  // add the vector elements
  z[i] = x[i] + y[i];
}