#include <stdio.h>
#include "cuda_code.h"
#include <iostream>
#include <iomanip>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <cassert>
#include <algorithm>
#include <stdio.h>
#include <math_functions.h>

__global__ void bg_estimate(uchar*data,uchar*data_out, int rows, int cols, int rRows, int rCols, int numPixels) {
    __shared__ uchar sharedMemory[4096];

    int pixelLocation = blockIdx.x*1024+threadIdx.x;
    if(pixelLocation >= numPixels)
        return;
    data_out[pixelLocation] = 37;

    int posX = pixelLocation%rCols;
    int posY = pixelLocation/rCols;

    if (posX < WINDOW_SIZE || posY < WINDOW_SIZE )
        return;
    if ((posX > (WINDOW_SIZE + cols)) || (posY > (WINDOW_SIZE + rows)))
        return;



    __syncthreads();

    unsigned short histogram[256] = {};

    for (int i = posY - WINDOW_SIZE ; i <= posY + WINDOW_SIZE ; i++) {
        for (int j = posX - WINDOW_SIZE ; j <= posX + WINDOW_SIZE ; j++) {
//            histogram[data[i*rCols + j]]++;
            histogram[0]++;
        }
    }

    __syncthreads();

    int counter = 0;
    int limit = (int) (0.8 * (WINDOW_SIZE+1)*(WINDOW_SIZE+1));
    int mean = 0;

    for (int i = 255; counter < limit; i--) {
        mean += histogram[i] * i;
        counter += histogram[i];
    }
    mean /= counter < 1 ? 1 : counter;

//    data[pixelLocation] = 1*255;

    data_out[pixelLocation] = 37;//255.0 * min(1.0, double(data[pixelLocation]) / mean);
}

__global__ void bg_estimate2(uchar*data,uchar*data_out, int rows, int cols, int rRows, int rCols, int numPixels) {
    __shared__ uchar sharedMemory[4096];

}

void cuda_binarize(uchar*data, uchar*data2, int rows, int cols, int rRows, int rCols) {
    printf("Hello from cu file\n");

    uchar*d_data;
    uchar*d_data_out;

    const dim3 blockSize(1024,1,1);

    int N = rRows*rCols;
    const dim3 gridSize(N/1024+N%1024,1,1);

    cudaMalloc(&d_data, sizeof(uchar) * rRows * rCols);
    cudaMalloc(&d_data_out, sizeof(uchar) * rRows * rCols);
    cudaMemcpy(d_data, data , sizeof(uchar) * rRows * rCols ,cudaMemcpyHostToDevice);
    cudaDeviceSynchronize();
    printf("%d", rCols);
    bg_estimate2 <<<gridSize,blockSize, 4906 * sizeof(uchar)>>>(d_data, d_data_out, rows, cols, rRows, rCols, rRows*rCols);
    cudaDeviceSynchronize();
    cudaMemcpy(data, d_data_out , sizeof(uchar) * rRows * rCols ,cudaMemcpyDeviceToHost);
    printf("Second hello 2");
}