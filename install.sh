#!/bin/sh -e

SRC_DIR="$(cd "$(dirname "$0")"; pwd)/src"
BUILD_DIR="$(cd "$(dirname "$0")"; pwd)/build"

rm -rf "${BUILD_DIR}"
mkdir "${BUILD_DIR}"

osacompile -s -o "${BUILD_DIR}/GIPHY Anywhere.app" -l JavaScript -s "${SRC_DIR}/main.js"

/usr/libexec/PlistBuddy "${BUILD_DIR}/GIPHY Anywhere.app/Contents/Info.plist" -c "Add :LSUIElement bool YES"

open "${BUILD_DIR}/GIPHY Anywhere.app"
