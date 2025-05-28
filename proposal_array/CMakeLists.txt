cmake_minimum_required(VERSION 3.15)
project(sampling)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -march=native -ftemplate-depth=100000")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -W -Wall")

add_library(libsampling INTERFACE)
target_include_directories(libsampling INTERFACE include/)
add_executable(bench_sampling
    source/main.cpp
)
target_link_libraries(libsampling INTERFACE)
target_include_directories(bench_sampling PRIVATE ${CMAKE_SOURCE_DIR}/include/sampling)

