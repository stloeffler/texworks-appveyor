#!/bin/sh

cd "${APPVEYOR_BUILD_FOLDER}/build"

#objdump -x test_poppler-qt5.exe

pwd
ls
echo "$PATH"
test_poppler-qt5.exe

ctest -VV --output-on-failure
