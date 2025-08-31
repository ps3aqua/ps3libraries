#!/bin/sh -e

VER=0.5.1

## Download the source code.
if [ ! -f libmpeg2-${VER}.tar.gz ]; then wget --continue https://libmpeg2.sourceforge.io/files/libmpeg2-${VER}.tar.gz; fi

## Download an up-to-date config.guess and config.sub
if [ ! -f config.guess ]; then wget --continue https://cgit.git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
if [ ! -f config.sub ]; then wget --continue https://cgit.git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

## Unpack the source code.
rm -Rf libmpeg2-${VER} && tar xfz libmpeg2-${VER}.tar.gz && cd libmpeg2-${VER}

## Replace config.guess and config.sub
cp ../config.guess ../config.sub .

autoreconf -fi

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
CFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
../configure \
  --prefix="$PS3DEV/portlibs/ppu" \
  --host="powerpc64-ps3-elf" \
  --disable-shared \
  --disable-sdl

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -C libmpeg2 -j $PROCS && ${MAKE:-make} -C libmpeg2 install && ${MAKE:-make} -C include install
