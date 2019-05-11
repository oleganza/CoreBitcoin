#!/bin/sh

# Cleanup to start with a blank slate

rm -rf build
mkdir -p build

xcodebuild clean

# Update all headers to produce up-to-date combined headers.

./update_headers.rb

# Build iOS static libraries for simulator and for devices

xcodebuild -project EthCore.xcodeproj -target EthCoreIOSlib -configuration Release -sdk iphonesimulator
mv build/libEthCoreIOS.a build/libEthCoreIOS-simulator.a

xcodebuild -project EthCore.xcodeproj -target EthCoreIOSlib -configuration Release -sdk iphoneos
mv build/libEthCoreIOS.a build/libEthCoreIOS-device.a

# Merge simulator and device libs into one

lipo build/libEthCoreIOS-device.a build/libEthCoreIOS-simulator.a -create -output build/libEthCoreIOS.a
rm build/libEthCoreIOS-simulator.a
rm build/libEthCoreIOS-device.a

# Build the iOS frameworks for simulator and for devices

rm -f build/EthCoreIOS*.framework

xcodebuild -project EthCore.xcodeproj -target EthCoreIOS -configuration Release -sdk iphonesimulator
mv build/EthCoreIOS.framework build/EthCoreIOS-simulator.framework

xcodebuild -project EthCore.xcodeproj -target EthCoreIOS -configuration Release -sdk iphoneos

# Merge the libraries inside the frameworks

mv build/EthCoreIOS-simulator.framework/EthCoreIOS build/EthCoreIOS.framework/EthCoreIOS-simulator
mv build/EthCoreIOS.framework/EthCoreIOS build/EthCoreIOS.framework/EthCoreIOS-device

lipo build/EthCoreIOS.framework/EthCoreIOS-simulator build/EthCoreIOS.framework/EthCoreIOS-device \
		-create -output build/EthCoreIOS.framework/EthCoreIOS
		
# Update openssl includes to match framework header search path

./postprocess_openssl_includes_in_framework.rb build/EthCoreIOS.framework

# Delete the intermediate files
		
rm build/EthCoreIOS.framework/EthCoreIOS-device
rm build/EthCoreIOS.framework/EthCoreIOS-simulator
rm -rf build/EthCoreIOS-simulator.framework

# Build for OS X

xcodebuild -project EthCore.xcodeproj -target EthCoreOSXlib -configuration Release
xcodebuild -project EthCore.xcodeproj -target EthCoreOSX    -configuration Release

# Update openssl includes to match framework header search path

./postprocess_openssl_includes_in_framework.rb build/EthCoreOSX.framework

# Clean up

rm -rf build/EthCore.build


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
mv build/EthCoreOSX.framework ${BINARIES_TARGETDIR}/OSX/EthCore.framework
mv ${BINARIES_TARGETDIR}/OSX/EthCore.framework/EthCoreOSX ${BINARIES_TARGETDIR}/OSX/EthCore.framework/EthCore

mv build/EthCoreIOS.framework ${BINARIES_TARGETDIR}/iOS/EthCore.framework
mv ${BINARIES_TARGETDIR}/iOS/EthCore.framework/EthCoreIOS ${BINARIES_TARGETDIR}/iOS/EthCore.framework/EthCore

# Move and rename the static libraries
mv build/libEthCoreIOS.a ${BINARIES_TARGETDIR}/iOS/libEthCore.a
mv build/libEthCoreOSX.a ${BINARIES_TARGETDIR}/OSX/libEthCore.a

# Move the headers
mv build/include ${BINARIES_TARGETDIR}/include

# Clean up
rm -rf build

# Remove +Tests.h headers from libraries and frameworks.
find ${BINARIES_TARGETDIR} -name '*+Tests.h' -print0 | xargs -0 rm


