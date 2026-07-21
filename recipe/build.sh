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

# Separate issue, same root cause: C23 changed empty parens `()` in a
# function declarator to mean "takes zero arguments" (previously
# "unspecified arguments" in C89-C17). FrameL.c calls FrErrorHandler
# (declared `void (*FrErrorHandler)()`) with 2 real arguments -- a hard
# "too many arguments" error under C23's stricter semantics, not
# something -Wno-error=incompatible-pointer-types (a different
# diagnostic) can silence. Build as the pre-C23 standard this codebase
# was actually written against.
export CFLAGS="${CFLAGS} -std=gnu17"

# ${CMAKE_ARGS} carries conda-build's own -DCMAKE_BUILD_TYPE=Release
# (plus toolchain/strip paths) -- omitting it leaves CMAKE_BUILD_TYPE
# unset (this project's own CMakeLists.txt never defaults it either),
# producing an unoptimized, unstripped debug-info binary.
cmake .. ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
