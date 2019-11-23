#!/bin/sh

mkdir -p .theos/arm64e
mkdir -p .theos/non-arm64e

# armv7 armv7s arm64
if [[ `xcodebuild -version | head -n 1` != "Xcode 9."* ]]; then
    echo "Will change to Xcode 9"
    sudo xcode-select -switch /Applications/Xcode9.app
fi

make clean; make FINALPACKAGE=1
mv .theos/obj/libcolorpicker.dylib .theos/non-arm64e/libcolorpicker.dylib

# arm64e
echo "Will change back to latest Xcode"
sudo xcode-select -switch /Applications/Xcode.app
make FINALPACKAGE=1 arm64e=1
mv .theos/obj/libcolorpicker.dylib .theos/arm64e/libcolorpicker.dylib

lipo .theos/arm64e/libcolorpicker.dylib .theos/non-arm64e/libcolorpicker.dylib -output .theos/obj/libcolorpicker.dylib -create

make package FINALPACKAGE=1
