#!/bin/sh -e
# libcurl.sh by KaKaRoTo
# modified by mhaqs

VER=8.7.1

## Download the source code.
wget --continue http://curl.haxx.se/download/curl-${VER}.tar.gz

wget https://curl.haxx.se/ca/cacert.pem
mv cacert.pem $PSL1GHT/

## Unpack the source code.
rm -Rf curl-${VER} && tar xfz curl-${VER}.tar.gz && cd curl-${VER}

## Replace config.guess and config.sub
cp ../../assets/config.guess ../../assets/config.sub .

## Patch the source code.
cat ../../patches/libcurl-${VER}.patch | patch -p1

## Create the build directory.
mkdir build-ppu && cd build-ppu

## Configure the build.
AR="ppu-ar" \
CC="ppu-gcc" \
RANLIB="ppu-ranlib" \
CFLAGS="-O2 -Wall" \
CXXFLAGS="-I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include" \
CPPFLAGS=" -I$PSL1GHT/ppu/include -I$PS3DEV/portlibs/ppu/include -I$PSL1GHT/ppu/include/net"  \
LDFLAGS="-L$PSL1GHT/ppu/lib -L$PS3DEV/portlibs/ppu/lib" \
LIBS="-lnet -lsysutil -lsysmodule -lm " \
PKG_CONFIG_LIBDIR="$PSL1GHT/ppu/lib/pkgconfig" \
PKG_CONFIG_PATH="$PS3DEV/portlibs/ppu/lib/pkgconfig" \
  ../configure --prefix="$PS3DEV/portlibs/ppu" \
    --host="powerpc64-ps3-elf" \
    --includedir="$PS3DEV/portlibs/ppu/include" \
    --libdir="$PS3DEV/portlibs/ppu/lib" \
    --with-mbedtls="$PS3DEV/portlibs/ppu/include/mbedtls" \
    --with-ca-bundle="/usr/ssl/certs/ca-bundle.crt" \
    --disable-threaded-resolver \
    --disable-ipv6 \
    --disable-ntlm \
    --disable-docs \
    --disable-ftp \
    --disable-file \
    --disable-ldap \
    --disable-ldaps \
    --disable-rtsp \
    --disable-proxy \
    --disable-dict \
    --disable-telnet \
    --disable-tftp \
    --disable-pop3 \
    --disable-imap \
    --disable-smb \
    --disable-smtp \
    --disable-gopher \
    --disable-mqtt \
    --disable-docs \
    --disable-manual

## Compile and install.
PROCS="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)" || ret=$?
if [ ! -z $ret ]; then PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"; fi
${MAKE:-make} -j $PROCS && ${MAKE:-make} install
