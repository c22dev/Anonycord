#!/bin/bash

set -e

cd "$(dirname "$0")"

WORKING_LOCATION="$(pwd)"
APPLICATION_NAME=Anonycord
CONFIGURATION=Debug

# If the folder 'build' does not exist, create it
if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# remove already built tipa if present
if [ -e "$APPLICATION_NAME.tipa" ]; then
rm $APPLICATION_NAME.tipa
fi

# Build .app
xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme Anonycord \
    -configuration Debug \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedData" \
    -destination 'generic/platform=iOS' \
    ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGNING_ALLOWED="NO" \

DD_APP_PATH="$WORKING_LOCATION/build/DerivedData/Build/Products/$CONFIGURATION-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

# Package .ipa
rm -rf Payload
mkdir Payload
cp -r $APPLICATION_NAME.app Payload/$APPLICATION_NAME.app
zip -vr $APPLICATION_NAME.ipa Payload
zip -vr $APPLICATION_NAME.tipa Payload
rm -rf $APPLICATION_NAME.app
rm -rf Payload
