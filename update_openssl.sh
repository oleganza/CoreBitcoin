#!/bin/bash

# based on:
# https://gist.github.com/tmiz/1441111
# https://github.com/st3fan/ios-openssl/blob/master/build.sh

set -x

OPENSSL_VERSION="1.0.1e"

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

IOS_SDK_VERSION="7.0"
OSX_SDK_VERSION="10.9"

WORKDIR=${PWD}

IPHONEOS_PLATFORM="${DEVELOPER}/Platforms/iPhoneOS.platform"
IPHONEOS_SDK="${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${IOS_SDK_VERSION}.sdk"
IPHONEOS_GCC="${DEVELOPER}/usr/bin/gcc"

MACOS_PLATFORM="${DEVELOPER}/Platforms/MacOSX.platform"
MACOS_SDK="${MACOS_PLATFORM}/Developer/SDKs/MacOSX${OSX_SDK_VERSION}.sdk"
MACOS_GCC="${DEVELOPER}/usr/bin/gcc"


rm -rf openssl
curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz

build()
{
   ARCH=$1
   GCC=$2
   SDK=$3
   rm -rf "openssl-${OPENSSL_VERSION}"
   tar xfz "openssl-${OPENSSL_VERSION}.tar.gz"
   pushd .
   cd "openssl-${OPENSSL_VERSION}"
   ./Configure BSD-generic32 --openssldir="${WORKDIR}/openssl-${OPENSSL_VERSION}-${ARCH}" &> "../openssl-${OPENSSL_VERSION}-${ARCH}.log"
   perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
   perl -i -pe "s|^CC= gcc|CC= ${GCC} -arch ${ARCH}|g" Makefile
   perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${SDK} \$1|g" Makefile
   make &> "../openssl-${OPENSSL_VERSION}-${ARCH}.log"
   make install &> "../openssl-${OPENSSL_VERSION}-${ARCH}.log"
   popd
   rm -rf "openssl-${OPENSSL_VERSION}"
}

build "arm64" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}"
build "armv7" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}"
build "armv7s" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}"


rm -rf "openssl-${OPENSSL_VERSION}"
tar xfz "openssl-${OPENSSL_VERSION}.tar.gz"
mv openssl-${OPENSSL_VERSION} openssl-${OPENSSL_VERSION}-x86_64
cd openssl-${OPENSSL_VERSION}-x86_64
./Configure darwin64-x86_64-cc -shared &> "../openssl-${OPENSSL_VERSION}-x86_64.log"
make &> "../openssl-${OPENSSL_VERSION}-x86_64.log"
cd ..

mkdir openssl
cd openssl
mkdir include
cp -r ${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/include/openssl include/


mkdir lib
lipo \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/lib/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/lib/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/lib/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libcrypto.a" \
	-create -output lib/libcrypto.a
lipo \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/lib/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/lib/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/lib/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libssl.a" \
	-create -output lib/libssl.a

cd ..

rm -rf openssl-${OPENSSL_VERSION}-*
rm -rf openssl-${OPENSSL_VERSION}.tar.gz

