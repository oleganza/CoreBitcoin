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

