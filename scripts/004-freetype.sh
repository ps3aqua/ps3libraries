#!/bin/sh -e
# freetype.sh by Naomi Peori (naomi@peori.ca)

VER=2.13.3

## Download the source code.
wget --continue https://download.savannah.gnu.org/releases/freetype/freetype-${VER}.tar.gz

## Unpack the source code.
rm -Rf freetype-${VER} && tar xfz freetype-${VER}.tar.gz && cd freetype-${VER}

patch -p1 < ../../patches/freetype-${VER}.patch

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub builds/unix/

## Create the build directory.
mkdir build-ppu && cd build-ppu

## freetype insists on GNU make
which gmake 1>/dev/null 2>&1 && MAKE=gmake

## Configure the build.
CFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib -lrt -llv2" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
GNUMAKE=$MAKE ../configure \
  --prefix="$PS3DEV/portlibs/ppu" \
  --host="powerpc64-ps3-elf" \
  --disable-shared \
  --with-brotli=no \
  --with-harfbuzz=no \
  --with-bzip2=no \
  --with-zlib=yes \
  --with-png=no \
  --with-librsvg=no

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
