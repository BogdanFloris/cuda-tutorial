#include <cassert>
#include <cuda_runtime_api.h>
#include <stdio.h>

#define N 10000000
#define MAX_ERR 1e-6

__global__ void vector_add(float *__restrict__ x, float *__restrict__ y,
                           int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = tid; i < n; i += stride) {
    y[tid] = x[tid] + y[tid];
  }
}

int main() {
  float *x, *y;
  cudaMallocManaged(&x, sizeof(float) * N);
  cudaMallocManaged(&y, sizeof(float) * N);
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }
  int deviceId;
  cudaGetDevice(&deviceId);
  // Prefetch the x and y arrays to the GPU
  cudaMemPrefetchAsync(x, N * sizeof(float), deviceId, 0);
  cudaMemPrefetchAsync(y, N * sizeof(float), deviceId, 0);

  int threadsPerBlock = 256;
  int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
  vector_add<<<blocksPerGrid, threadsPerBlock>>>(x, y, N);
  cudaError_t err = cudaGetLastError();
  if (err != cudaSuccess) {
    printf("cuda error: %s\n", cudaGetErrorString(err));
  }

  cudaDeviceSynchronize();
  cudaMemPrefetchAsync(y, N * sizeof(float), cudaCpuDeviceId, 0);
  // Synchronize the CPU stream to ensure prefetch completes before reading
  cudaStreamSynchronize(0);

  for (int i = 0; i < N; i++) {
    assert(fabs(y[i] - 3.0f) < MAX_ERR);
  }
  printf("out[0]=%f\n", y[0]);

  cudaFree(x);
  cudaFree(y);
  return 0;
}
