#!/bin/sh

# Cleanup to start with a blank slate

rm -rf build
mkdir -p build

xcodebuild clean

# Update all headers to produce up-to-date combined headers.

./update_headers.rb

# Build iOS static libraries for simulator and for devices

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOSlib -configuration Release -sdk iphonesimulator
mv build/libCoreBitcoinIOS.a build/libCoreBitcoinIOS-simulator.a

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOSlib -configuration Release -sdk iphoneos
mv build/libCoreBitcoinIOS.a build/libCoreBitcoinIOS-device.a

# Merge simulator and device libs into one

lipo build/libCoreBitcoinIOS-device.a build/libCoreBitcoinIOS-simulator.a -create -output build/libCoreBitcoinIOS.a
rm build/libCoreBitcoinIOS-simulator.a
rm build/libCoreBitcoinIOS-device.a

# Build the iOS frameworks for simulator and for devices

rm -f build/CoreBitcoinIOS*.framework

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOS -configuration Release -sdk iphonesimulator
mv build/CoreBitcoinIOS.framework build/CoreBitcoinIOS-simulator.framework

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOS -configuration Release -sdk iphoneos

# Merge the libraries inside the frameworks

mv build/CoreBitcoinIOS-simulator.framework/CoreBitcoinIOS build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator
mv build/CoreBitcoinIOS.framework/CoreBitcoinIOS build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device

lipo build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device \
		-create -output build/CoreBitcoinIOS.framework/CoreBitcoinIOS
		
# Update openssl includes to match framework header search path

./postprocess_openssl_includes_in_framework.rb build/CoreBitcoinIOS.framework

# Delete the intermediate files
		
rm build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device
rm build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator
rm -rf build/CoreBitcoinIOS-simulator.framework

# Build for OS X

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinOSXlib -configuration Release
xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinOSX    -configuration Release

# Update openssl includes to match framework header search path

./postprocess_openssl_includes_in_framework.rb build/CoreBitcoinOSX.framework

# Clean up

rm -rf build/CoreBitcoin.build


# At this point all the libraries and frameworks are built and placed in the ./build 
# directory with names ending with -IOS and -OSX indicating their architectures. The 
# rest of the script renames them to have the same name without these suffixes. 

# If you build your project in a way that you would rather have the names differ, you 
# can uncomment the next line and stop the build process here.

#exit


# Moving the result to a separate location

BINARIES_TARGETDIR="binaries"

rm -rf ${BINARIES_TARGETDIR}

mkdir ${BINARIES_TARGETDIR}
mkdir ${BINARIES_TARGETDIR}/OSX
mkdir ${BINARIES_TARGETDIR}/iOS

# Move and rename the frameworks
mv build/CoreBitcoinOSX.framework ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework
mv ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework/CoreBitcoinOSX ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework/CoreBitcoin

mv build/CoreBitcoinIOS.framework ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework
mv ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework/CoreBitcoinIOS ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework/CoreBitcoin

# Move and rename the static libraries
mv build/libCoreBitcoinIOS.a ${BINARIES_TARGETDIR}/iOS/libCoreBitcoin.a
mv build/libCoreBitcoinOSX.a ${BINARIES_TARGETDIR}/OSX/libCoreBitcoin.a

# Move the headers
mv build/include ${BINARIES_TARGETDIR}/include

# Clean up
rm -rf build

# Remove +Tests.h headers from libraries and frameworks.
find ${BINARIES_TARGETDIR} -name '*+Tests.h' -print0 | xargs -0 rm


