#!/bin/sh -e
# sdl2_psl1ght.sh by Naomi Peori (naomi@peori.ca)

SDL2_PSL1GHT_VERSION=${SDL2_PSL1GHT_VERSION:="8eced77f03cc0e753285a577274582964cbc98d6"}

## Download the source code.
wget "https://github.com/ps3aqua/SDL2_PSL1GHT/archive/${SDL2_PSL1GHT_VERSION}.tar.gz" -O sdl2_psl1ght-${SDL2_PSL1GHT_VERSION}.tar.gz

## Unpack the source code.
rm -Rf sdl2_psl1ght && mkdir sdl2_psl1ght && tar --strip-components=1 --directory=sdl2_psl1ght -xzf sdl2_psl1ght-${SDL2_PSL1GHT_VERSION}.tar.gz

## Create the build directory.
cd sdl2_psl1ght

./autogen.sh

if [ -f Makefile ]
then
	make clean
fi

## Configure the build.
CFLAGS="-O2 -Wall -I$PSL1GHT/ppu/include" LDFLAGS="-L$PSL1GHT/ppu/lib -lrt -llv2" ./configure \
	--prefix="$PS3DEV/portlibs/ppu" --host=powerpc64-ps3-elf \
	--enable-atomic=yes --enable-video-psl1ght=yes --enable-joystick=yes --enable-audio=yes \
	|| { exit 1; }

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
