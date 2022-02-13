#!/bin/sh -e

VER=5.2.1

## Download the source code.
if [ ! -f giflib-${VER}.tar.gz ]; then wget --continue http://download.sourceforge.net/giflib/giflib-${VER}.tar.gz; fi

## Unpack the source code.
rm -Rf giflib-${VER} && tar xf giflib-${VER}.tar.gz && cd giflib-${VER}

## Configure the build.
export CC="powerpc64-ps3-elf-gcc" \
export AR="powerpc64-ps3-elf-ar" \
export OFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
export LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} libgif.a -j $PROCS && ${MAKE:-make} install-include PREFIX="$PS3DEV/portlibs/ppu" && install -m 644 libgif.a "$PS3DEV/portlibs/ppu/lib//libgif.a"
