//
// Created by srq on 7/6/17.
//

#ifndef BGPARALLEL_CUDA_CODE_H_H
#define BGPARALLEL_CUDA_CODE_H_H
typedef unsigned char uchar;

#define WINDOW_SIZE 32

void cuda_binarize(uchar*data,uchar*data2, int rows, int cols, int rRows, int rCols);

#endif //BGPARALLEL_CUDA_CODE_H_H
