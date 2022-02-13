#!/bin/sh -e
# zlib.sh by Naomi Peori (naomi@peori.ca)

VER=1.2.11

## Download the source code.
wget --continue http://zlib.net/zlib-1.2.11.tar.gz

## Unpack the source code.
rm -Rf zlib-1.2.11 && tar xfz zlib-1.2.11.tar.gz && cd zlib-1.2.11

## Patch the source code.
cat ../../patches/zlib-1.2.11-PPU.patch | patch -p1

## Configure the build.
AR="powerpc64-ps3-elf-ar" CC="powerpc64-ps3-elf-gcc" RANLIB="powerpc64-ps3-elf-ranlib" \
./configure --prefix="$PS3DEV/portlibs/ppu" --static

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install