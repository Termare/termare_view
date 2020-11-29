#!/bin/bash
export NDK_HOME=/Users/nightmare/Library/Android/sdk/ndk/21.3.6528147 # or set to your ndk home

export MAKE_PATH=build/make-cache

export TARGET_ABI=$ABI

create_makefile() {
    cmake \
        -DANDROID_ABI=$TARGET_ABI \
        -DANDROID_PLATFORM=android-16 \
        -DCMAKE_BUILD_TYPE=release \
        -DANDROID_NDK=$NDK_HOME \
        -DCMAKE_TOOLCHAIN_FILE=$NDK_HOME/build/cmake/android.toolchain.cmake \
        -DANDROID_TOOLCHAIN=clang -B $MAKE_PATH -S .
}

create_makefile

cd $MAKE_PATH

make clean
make
