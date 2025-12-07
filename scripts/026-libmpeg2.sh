#!/bin/sh -e

VER=0.5.1

## Download the source code.
if [ ! -f mpeg2dec_${VER}.orig.tar.gz ]; then wget --continue http://deb.debian.org/debian/pool/main/m/mpeg2dec/mpeg2dec_${VER}.orig.tar.gz; fi

## Unpack the source code.
rm -Rf libmpeg2-${VER} && tar xfz mpeg2dec_${VER}.orig.tar.gz && cd libmpeg2-${VER}

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub .

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
