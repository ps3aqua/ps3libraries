#!/bin/sh -e
# flac.sh by dhewg (dhewg@wiibrew.org)

VER=1.2.1

## Download the source code.
wget --continue http://downloads.sourceforge.net/project/flac/flac-src/flac-${VER}-src/flac-${VER}.tar.gz

## Download an up-to-date config.guess and config.sub
if [ ! -f config.guess ]; then wget --continue http://git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
if [ ! -f config.sub ]; then wget --continue http://git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

## Unpack the source code.
rm -Rf flac-${VER} && tar xfz flac-${VER}.tar.gz && cd flac-${VER}

## Replace config.guess and config.sub
cp ../config.guess ../config.sub .

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
CFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
../configure --prefix="$PS3DEV/portlibs/ppu" --host="powerpc64-ps3-elf" --disable-shared --enable-altivec --disable-xmms-plugin --disable-ogg --disable-oggtest

## Compile (only parts to prevent failures in unrequired parts) and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -C src/libFLAC -j $PROCS && ${MAKE:-make} -C src/libFLAC install && ${MAKE:-make} -C include install
