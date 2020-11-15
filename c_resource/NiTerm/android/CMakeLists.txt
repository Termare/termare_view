cmake_minimum_required (VERSION 2.6) # cmake version

project(term) # project name

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../../../android/app/src/main/jniLibs/$ENV{ABI}) # set output path

aux_source_directory(${PROJECT_SOURCE_DIR}/../src SRC_FILES) # scan source code files

add_library(term SHARED ${SRC_FILES}) # add source code files to library, and set build type to dynamic library.
