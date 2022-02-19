#!/bin/sh -e

VER=acc2183fdcb9af2aca233bcfdafd5f657dce33f8

## Download the source code.
wget --continue https://github.com/divideconcept/FluidLite/archive/${VER}.tar.gz -O FluidLite-${VER}.tar.gz

## Unpack the source code.
rm -Rf FluidLite-${VER} && tar xzf FluidLite-${VER}.tar.gz && cd FluidLite-${VER}

rm -f src/fluid_dsp_simple.c src/fluidsynth.c

echo "
src = \$(wildcard *.c)
obj = \$(src:.c=.o)

%.o: %.c
	powerpc64-ps3-elf-gcc -c -o \$@ \$< -I../include -I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include -O2

libfluidlite.a: \$(obj)
	powerpc64-ps3-elf-ar rcu \$@ \$+
	powerpc64-ps3-elf-ranlib \$@

all: libfluidlite.a
" > src/Makefile

make -C src && cp src/libfluidlite.a $PS3DEV/portlibs/ppu/lib/ && cp -R include/* $PS3DEV/portlibs/ppu/include/ && echo "
prefix=$PS3DEV/portlibs/ppu
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: fluidlite
Description: Software SoundFont synth
Version: 1.2.1
Libs: -L\${libdir} -lfluidlite
Cflags: -I\${includedir}
" > $PS3DEV/portlibs/ppu/lib/pkgconfig/fluidlite.pc
