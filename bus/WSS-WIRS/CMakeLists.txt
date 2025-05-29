
cmake_minimum_required(VERSION 3.22)
project(DynamicSetSampling)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -march=native")

add_library(libWSSWIRS INTERFACE)
target_include_directories(libWSSWIRS INTERFACE include/)
add_executable(bench_sampling
	source/main.cpp)

target_link_libraries(libWSSWIRS INTERFACE)
target_include_directories(bench_sampling PRIVATE ${CMAKE_SOURCE_DIR}/include/WSSWIRS)

