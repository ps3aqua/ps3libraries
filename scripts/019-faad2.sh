#!/bin/sh -e
# faad2.sh by dhewg (dhewg@wiibrew.org)

## Download the source code.
wget --continue https://github.com/knik0/faad2/archive/refs/tags/2_10_0.tar.gz -O faad2-2.10.tar.gz

## Unpack the source code.
rm -Rf faad2-2.10 && tar xfz faad2-2.10.tar.gz && cd faad2-2_10_0

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub .

NOCONFIGURE=1 ./bootstrap

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
  --without-xmms \
  --without-drm \
  --without-mpeg4ip

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
