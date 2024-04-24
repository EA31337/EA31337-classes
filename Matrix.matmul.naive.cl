#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void matmul(
  __global double* A,
  __global double* B,
  __global double* C,
  int rowsA,
  int colsA,
  int colsB
  )
{
  int row = get_global_id(0);
  int col = get_global_id(1);
  
  double sum = 0.0;
  
  for(int k = 0; k < colsA; ++k) {
    sum += A[row * colsA + k] * B[k * colsB + col];
    //sum += col;
  }
  
  C[row * colsB + col] = sum;
}