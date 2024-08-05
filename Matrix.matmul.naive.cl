#pragma OPENCL EXTENSION cl_khr_fp64 : enable

__kernel void matmul(__global double* A, __global double* B, __global double* C, int rowsA, int colsA, int colsB) {
  int i = get_global_id(0);
  int j = get_global_id(1);

  if (i < rowsA && j < colsB) {
    float sum = 0.0f;
    for (int k = 0; k < colsA; ++k) {
      sum += A[i * colsA + k] * B[k * colsB + j];
    }
    C[i * colsB + j] = sum;
  }
}
