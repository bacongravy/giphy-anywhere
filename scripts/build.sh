#!/bin/sh

PROJECT_NAME="giphy-anywhere.xcodeproj"
SCHEME_NAME="GIPHY Anywhere"

APP_NAME="GIPHY Anywhere.app"
VOLUME_NAME="GIPHY Anywhere"
DISK_IMAGE_NAME="GIPHY_Anywhere.dmg"

set -e -o pipefail

echo "Building project..."
xcodebuild -project "$PROJECT_NAME" -scheme "$SCHEME_NAME" install DSTROOT=build/root DEVELOPMENT_TEAM="$SIGNING_DEVELOPMENT_TEAM" CODE_SIGN_IDENTITY="$SIGNING_IDENTITY"

echo "Creating disk image..."
hdiutil create -fs HFS+ -srcfolder build/root/Applications/"$APP_NAME" -volname "$VOLUME_NAME" build/"$DISK_IMAGE_NAME"
