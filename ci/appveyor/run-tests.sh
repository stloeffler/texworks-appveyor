#!/bin/sh

cd "${APPVEYOR_BUILD_FOLDER}/build"

#objdump -x test_poppler-qt5.exe

test_poppler-qt5.exe

ctest -VV --output-on-failure
