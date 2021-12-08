#!/bin/sh

if [[ "$target_platform" == "osx-64" ]]; then
  TOOLS_DIR=$(dirname $($FC --print-libgcc-file-name))
  if [[ ! -f "$TOOLS_DIR/ld" ]]; then
    ln -sf $LD $TOOLS_DIR/ld
    ln -sf $LD $BUILD_PREFIX/bin/ld
  fi
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  EXTRA_CMAKE="-DCDEFS=Add_"
  # https://github.com/Reference-ScaLAPACK/scalapack/issues/21
  export FFLAGS="${FFLAGS} -fallow-argument-mismatch"
fi

mkdir build && cd build
cmake ${CMAKE_ARGS} \
    $EXTRA_CMAKE \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DMPI_BASE_DIR="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    .. || (cat CMakeFiles/CMakeOutput.log && cat CMakeFiles/CMakeError.log && exit 1)

make install -j${CPU_COUNT}
