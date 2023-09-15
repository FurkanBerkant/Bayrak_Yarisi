#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "Runner.cuh"


__global__ void updateSpeedKernel(Runner* runners, curandState_t* states) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    runners[index].updateSpeedGPU(&states[index]);
}

__global__ void initCurand(curandState_t* states, unsigned long long seed) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(seed, index, 0, &states[index]);
}
__global__ void myKernel(Runner* d_runners, curandState_t* d_states, int teamIndex) {
    int j = threadIdx.x; // GPU iş parçacığının indeksi

    d_runners[teamIndex * 4 + j].updateSpeedGPU(&d_states[teamIndex * 4 + j]);
}