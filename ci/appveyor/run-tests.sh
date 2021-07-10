#!/bin/sh

cd "${APPVEYOR_BUILD_FOLDER}/build"

LD_LIBRARY_PATH=".:${LD_LIBRARY_PATH}" ctest -V
