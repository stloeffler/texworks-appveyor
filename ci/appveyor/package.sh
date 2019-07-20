#!/bin/sh

echo "Packaging TeXworks"

cd "${APPVEYOR_BUILD_FOLDER}/build"

make VERBOSE=1 install

cp -r share "${APPVEYOR_BUILD_FOLDER}/artifact/"

# FIXME: DEBUG
ls -lisa "${APPVEYOR_BUILD_FOLDER}/artifact/"
