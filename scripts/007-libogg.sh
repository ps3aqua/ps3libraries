#!/bin/sh -e
# libogg.sh by Naomi Peori (naomi@peori.ca)

VER=1.3.5

## Download the source code.
wget --continue http://downloads.xiph.org/releases/ogg/libogg-${VER}.tar.gz

## Unpack the source code.
rm -Rf libogg-${VER} && tar xfz libogg-${VER}.tar.gz && cd libogg-${VER}

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub .

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
CFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
../configure --prefix="$PS3DEV/portlibs/ppu" --host="powerpc64-ps3-elf" --disable-shared

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
