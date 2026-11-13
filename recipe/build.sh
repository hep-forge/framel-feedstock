#!/usr/bin/env bash
set -euxo pipefail

# --- Fr: library, tools, docs and the Python module (ctypes binding)
cmake -S fr -B build-fr ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_C=yes -DENABLE_PYTHON=yes -DENABLE_MATLAB=no -DENABLE_PACKAGING=no \
  -DPython3_EXECUTABLE="${PYTHON}"
cmake --build build-fr --parallel "${CPU_COUNT}" --verbose
cmake --install build-fr

# --- Frv, against the Fr just installed
cmake -S frv -B build-frv -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib
cmake --build build-frv --parallel "${CPU_COUNT}" --verbose
cmake --install build-frv

# --- Fd, against Fr, Frv and hep-forge's cfg/cm
# MESON_ARGS (conda-build) already sets the prefix, libdir and buildtype
meson setup build-fd fd ${MESON_ARGS} --wrap-mode=nofallback --backend=ninja
ninja -C build-fd -j"${CPU_COUNT}" -v
ninja -C build-fd install
