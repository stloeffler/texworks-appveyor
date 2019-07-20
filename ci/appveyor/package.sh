#!/bin/sh

echo "Packaging TeXworks"

cd "${APPVEYOR_BUILD_FOLDER}/build"

make VERBOSE=1 install

windeployqt "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

cp -r share "${APPVEYOR_BUILD_FOLDER}/artifact/"

# FIXME: DEBUG
ls -lisaR "${APPVEYOR_BUILD_FOLDER}/artifact/"
