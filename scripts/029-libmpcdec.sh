#!/bin/sh -e

VER=1.2.6

## Download the source code.
wget --continue https://files.musepack.net/source/libmpcdec-${VER}.tar.bz2

## Unpack the source code.
rm -Rf libmpcdec-${VER} && tar xf libmpcdec-${VER}.tar.bz2 && cd libmpcdec-${VER}

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub .

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
CFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
CROSS=powerpc64-ps3-elf- \
../configure ac_cv_func_memcmp_working=1 --prefix="$PS3DEV/portlibs/ppu" --host="powerpc64-ps3-elf" --disable-shared

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
