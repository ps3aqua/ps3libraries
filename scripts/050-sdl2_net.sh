#!/bin/sh
# SDL2_NET.sh by unknown (Updated by Spork Schivago)

SDL2_NET="SDL2_net-2.2.0"

## Download the source code.
if [ ! -f ${SDL2_NET}.tar.gz ]; then
  wget --continue http://www.libsdl.org/projects/SDL_net/release/${SDL2_NET}.tar.gz
fi

## Unpack the source code.
rm -Rf ${SDL2_NET} && tar -zxf ${SDL2_NET}.tar.gz && cd ${SDL2_NET}

## Patch the source code if a patch exists.
if [ -f ../../patches/${SDL2_NET}.patch ]; then
  echo "patching ${SDL2_NET}..."
  cat ../../patches/${SDL2_NET}.patch | patch -p1;
fi

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
CPPFLAGS="-I${PSL1GHT}/ppu/include" \
CFLAGS="-I${PSL1GHT}/ppu/include" \
LDFLAGS="-L${PSL1GHT}/ppu/lib -lnet -lnetctl -lsysmodule" \
../configure --prefix="$PS3DEV/portlibs/ppu" --host=powerpc64-ps3-elf \
	--with-sdl-exec-prefix="/no/path" \
	--disable-sdltest \
	--disable-examples \
	--disable-shared

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
