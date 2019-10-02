cmake_minimum_required(VERSION 3.1)

project(runner)

set(CMAKE_CXX_FLAGS "-g -Wall -O2 -pthread")
set(EXECUTABLE_OUTPUT_PATH "${PROJECT_SOURCE_DIR}/bin")

add_executable(runner src/main.cpp)