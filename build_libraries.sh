#!/bin/sh

#start with a clean sheet

rm -rf build/CoreBitcoin.build
rm -rf build/*.framework
rm -rf build/*.a


#build the iOS static libraries once for the simulator and once for the actual devices

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOSlib -configuration Release -sdk iphonesimulator
mv build/libCoreBitcoinIOS.a build/libCoreBitcoinIOS-simulator.a
xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOSlib -configuration Release -sdk iphoneos
mv build/libCoreBitcoinIOS.a build/libCoreBitcoinIOS-device.a

#merge them and clean up

lipo build/libCoreBitcoinIOS-device.a build/libCoreBitcoinIOS-simulator.a -create -output build/libCoreBitcoinIOS.a
rm build/libCoreBitcoinIOS-simulator.a
rm build/libCoreBitcoinIOS-device.a


#build the frameworks once for the simulator, once for the devices

rm -f build/CoreBitcoinIOS*.framework

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOS -configuration Release -sdk iphonesimulator
mv build/CoreBitcoinIOS.framework build/CoreBitcoinIOS-simulator.framework
xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinIOS -configuration Release -sdk iphoneos

#merge the libraries from the bundles

mv build/CoreBitcoinIOS-simulator.framework/CoreBitcoinIOS build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator
mv build/CoreBitcoinIOS.framework/CoreBitcoinIOS build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device

lipo build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device \
		-create -output build/CoreBitcoinIOS.framework/CoreBitcoinIOS
		
#delete the unnecessary remains
		
rm build/CoreBitcoinIOS.framework/CoreBitcoinIOS-device
rm build/CoreBitcoinIOS.framework/CoreBitcoinIOS-simulator
rm -rf build/CoreBitcoinIOS-simulator.framework



#build for OSX

xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinOSXlib -configuration Release
xcodebuild -project CoreBitcoin.xcodeproj -target CoreBitcoinOSX -configuration Release

#clean up
rm -rf build/CoreBitcoin.build



# At this point all the libraries and frameworks are built and placed in the ./build 
# directory with names ending with -IOS and -OSX indicating their architectures. The 
# rest of the script renames them to have the same name without these suffixes. 

# If you build your project in a way that you would rather have the names differ, you 
# can uncomment the next line and stop the build process here.

#exit


#moving the result to a separate location

BINARIES_TARGETDIR="binaries"

rm -rf ${BINARIES_TARGETDIR}

mkdir ${BINARIES_TARGETDIR}
mkdir ${BINARIES_TARGETDIR}/OSX
mkdir ${BINARIES_TARGETDIR}/iOS

#move and rename the frameworks
mv build/CoreBitcoinOSX.framework ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework
mv ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework/CoreBitcoinOSX ${BINARIES_TARGETDIR}/OSX/CoreBitcoin.framework/CoreBitcoin

mv build/CoreBitcoinIOS.framework ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework
mv ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework/CoreBitcoinIOS ${BINARIES_TARGETDIR}/iOS/CoreBitcoin.framework/CoreBitcoin

#move and rename the static libraries
mv build/libCoreBitcoinIOS.a ${BINARIES_TARGETDIR}/iOS/libCoreBitcoin.a
mv build/libCoreBitcoinOSX.a ${BINARIES_TARGETDIR}/OSX/libCoreBitcoin.a

#move the headers
mv build/include ${BINARIES_TARGETDIR}/include