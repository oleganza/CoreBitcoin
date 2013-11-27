#!/bin/bash

# based on:
# https://gist.github.com/tmiz/1441111
# https://github.com/st3fan/ios-openssl/blob/master/build.sh

#set -x

OPENSSL_VERSION="1.0.1e"

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

IOS_SDK_VERSION="7.0"
OSX_SDK_VERSION="10.9"

WORKDIR=${PWD}

IPHONEOS_PLATFORM="${DEVELOPER}/Platforms/iPhoneOS.platform"
IPHONEOS_SDK="${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${IOS_SDK_VERSION}.sdk"
IPHONEOS_GCC="${DEVELOPER}/usr/bin/gcc"

IPHONESIMULATOR_PLATFORM="${DEVELOPER}/Platforms/iPhoneSimulator.platform"
IPHONESIMULATOR_SDK="${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/iPhoneSimulator${IOS_SDK_VERSION}.sdk"
IPHONESIMULATOR_GCC="${DEVELOPER}/usr/bin/gcc"

MACOS_PLATFORM="${DEVELOPER}/Platforms/MacOSX.platform"
MACOS_SDK="${MACOS_PLATFORM}/Developer/SDKs/MacOSX${OSX_SDK_VERSION}.sdk"
MACOS_GCC="${DEVELOPER}/usr/bin/gcc"


rm -rf openssl

# Instead of downloading an archive over insecure link, we'll just keep it in the repo.
# curl -O http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz

build()
{
   ARCH=$1
   GCC=$2
   SDK=$3
   rm -rf "openssl-${OPENSSL_VERSION}"
   tar xfz "openssl-${OPENSSL_VERSION}.tar.gz"
   mv "openssl-${OPENSSL_VERSION}" "openssl-${OPENSSL_VERSION}-${ARCH}"
   pushd .
   cd "openssl-${OPENSSL_VERSION}-${ARCH}"
   ./Configure BSD-generic32  &> "../openssl-${OPENSSL_VERSION}-${ARCH}.log"
   perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
   perl -i -pe "s|^CC= gcc|CC= ${GCC} -arch ${ARCH}|g" Makefile
   perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${SDK} \$1|g" Makefile
   make &> "../openssl-${OPENSSL_VERSION}-${ARCH}.log"
   popd
}

build "i386" "${IPHONESIMULATOR_GCC}" "${IPHONESIMULATOR_SDK}"
build "x86_64" "${IPHONESIMULATOR_GCC}" "${IPHONESIMULATOR_SDK}"
mv "openssl-${OPENSSL_VERSION}-x86_64" "openssl-${OPENSSL_VERSION}-x86_64-simulator"

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


#mkdir lib
#lipo \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/libcrypto.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/libcrypto.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/libcrypto.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-i386/libcrypto.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libcrypto.a" \
#	-create -output lib/libcrypto.a
#lipo \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/libssl.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/libssl.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/libssl.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-i386/libssl.a" \
#	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libssl.a" \
#	-create -output lib/libssl.a

mkdir lib
lipo \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64-simulator/libcrypto.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-i386/libcrypto.a" \
	-create -output lib/libcrypto-ios.a
	
cp "${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libcrypto.a" "lib/libcrypto-osx.a"

lipo \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-armv7s/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-arm64/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-i386/libssl.a" \
	"${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64-simulator/libssl.a" \
	-create -output lib/libssl-ios.a
	
cp "${WORKDIR}/openssl-${OPENSSL_VERSION}-x86_64/libssl.a" "lib/libssl-osx.a" 

cd ..

rm -rf openssl-${OPENSSL_VERSION}-*

# Do not remove archive: we keep it in the repository.
# rm -rf openssl-${OPENSSL_VERSION}.tar.gz

