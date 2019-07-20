#!/bin/sh

echo "Packaging TeXworks"

cd "${APPVEYOR_BUILD_FOLDER}/build"

make VERBOSE=1 install

strip -s "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

windeployqt--release "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

cp -r share "${APPVEYOR_BUILD_FOLDER}/artifact/"

# FIXME: DEBUG
ls -lisaR "${APPVEYOR_BUILD_FOLDER}/artifact/"
du -hd 1 "${APPVEYOR_BUILD_FOLDER}/artifact/"
