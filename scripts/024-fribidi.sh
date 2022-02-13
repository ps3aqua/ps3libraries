#!/bin/sh -e

VER=1.0.11

## Download the source code.
wget --continue https://github.com/fribidi/fribidi/releases/download/v${VER}/fribidi-${VER}.tar.xz

## Download an up-to-date config.guess and config.sub
if [ ! -f config.guess ]; then wget --continue http://git.savannah.gnu.org/cgit/config.git/plain/config.guess; fi
if [ ! -f config.sub ]; then wget --continue http://git.savannah.gnu.org/cgit/config.git/plain/config.sub; fi

## Unpack the source code.
rm -Rf fribidi-${VER} && tar xf fribidi-${VER}.tar.xz && cd fribidi-${VER}

## Replace config.guess and config.sub
cp ../config.guess ../config.sub .

# Avoid compiling and installing doc, binaries and tests
sed -ie 's/^\(SUBDIRS.*\) bin doc test/\1/' Makefile.am

NOCONFIGURE=1 ./autogen.sh

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
