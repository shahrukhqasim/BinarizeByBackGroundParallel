#include <iostream>
#include <docproc/binarize/binarize.h>
#include "opencv2/core.hpp"
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <memory>
#include <docproc/utility/timer.h>
#include "cuda_code.h"
#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>


using namespace std;
using namespace cv;

double time1;
double time2;

void binarizeNew(Mat image) {
    int r = WINDOW_SIZE;

    docproc::utility::tic("cuda");
    Mat imgPadded;
    copyMakeBorder(image, imgPadded, r, r, r, r, BORDER_REFLECT_101);
    uchar*data=imgPadded.data;
    uchar*data2 ;//= new uchar[imgPadded.rows*imgPadded.cols];
    cuda_binarize(data,data2, image.rows, image.cols, imgPadded.rows, imgPadded.cols);
    for(int i=0;i<imgPadded.rows*imgPadded.cols;i++) {
//        cout<<((int)data2[i])<<" ";
    }
    Rect ROI(r, r, image.cols, image.rows);
    image = imgPadded(ROI).clone();
    Mat binary;
    threshold(image, binary, 0, 255, THRESH_BINARY | THRESH_OTSU);
    cout<<"Time taken by CUDA: "<<(time1=docproc::utility::toc("cuda"))<<" seconds"<<endl;

    imwrite("test.png", binary);
}


int main(int argc, char**argv) {
    // Read the image
    if(argc!=2) {
        cout<<"Improper arguments \n";
        return -1;
    }

    string imageFileName = argv[1];
    Mat image;
    image = imread(imageFileName, 0);
    Mat imageRgb = imread(imageFileName, 1);

    // Binarize the image
    Mat binarizedImage;
    Mat temp;

    binarizeNew(image);
    docproc::utility::tic("old");
    docproc::binarize::binarizeBG(image, temp, binarizedImage);
    cout<<"Time taken: "<<(time2=docproc::utility::toc("old"))<<" seconds"<<endl;
    imwrite("test2.png", binarizedImage);

    cout<<"Improvement: "<<time2/time1;
    return 0;
}