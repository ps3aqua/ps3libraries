#!/bin/sh -e
# zlib.sh by Naomi Peori (naomi@peori.ca)

VER=1.2.13

## Download the source code.
wget --continue https://www.zlib.net/fossils/zlib-${VER}.tar.gz

## Unpack the source code.
rm -Rf zlib-${VER} && tar xfz zlib-${VER}.tar.gz && cd zlib-${VER}

## Patch the source code.
cat ../../patches/zlib-${VER}-PPU.patch | patch -p1

## Configure the build.
AR="powerpc64-ps3-elf-ar" CC="powerpc64-ps3-elf-gcc" RANLIB="powerpc64-ps3-elf-ranlib" \
./configure --prefix="$PS3DEV/portlibs/ppu" --static

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
