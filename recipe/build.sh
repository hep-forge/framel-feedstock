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

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
