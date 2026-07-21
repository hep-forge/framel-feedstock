#! /usr/bin/bash

mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

mkdir build
cd build

# src/FrameL.c assigns a concretely-typed error-handler function to a
# generic `void(*)(void)` callback pointer (a long-standing, harmless C
# idiom in this codebase) -- newer compilers (post gcc14/C23-leaning
# defaults) promote -Wincompatible-pointer-types from a warning to a
# hard error. Demote it back rather than patching upstream source.
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"

# ${CMAKE_ARGS} carries conda-build's own -DCMAKE_BUILD_TYPE=Release
# (plus toolchain/strip paths) -- omitting it leaves CMAKE_BUILD_TYPE
# unset (this project's own CMakeLists.txt never defaults it either),
# producing an unoptimized, unstripped debug-info binary.
cmake .. ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
