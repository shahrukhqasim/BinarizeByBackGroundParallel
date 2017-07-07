cmake_minimum_required(VERSION 3.5)
project(BgParallel)

link_directories(/usr/local/lib/ /usr/lib/ ${Boost_LIBRARY_DIR})
include_directories(/usr/local/include/ DocProc/src/ ${Boost_INCLUDE_DIR})

set(CMAKE_CXX_STANDARD 14)

# Find boost packages
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
FIND_PACKAGE(Boost 1.40 COMPONENTS regex program_options REQUIRED )

# CUDA PACKAGE
find_package(CUDA REQUIRED)
list(APPEND CUDA_NVCC_FLAGS "-arch=sm_52;-std=c++11;-O2;-DVERBOSE")
SET(CUDA_PROPAGATE_HOST_FLAGS OFF)

cuda_add_executable(BgParallel src/main.cc src/cuda_code.cu src/cuda_code.h)
target_link_libraries(BgParallel lept tesseract opencv_core opencv_imgproc opencv_highgui opencv_imgcodecs pthread gomp ${Boost_LIBRARIES} docproc)
