#!/bin/sh

mkdir -p "${APPVEYOR_BUILD_FOLDER}/build"
cd "${APPVEYOR_BUILD_FOLDER}/build"

cmake -G"MSYS Makefiles" -DTW_BUILD_ID='appveyor' -DDESIRED_QT_VERSION='5' -DCMAKE_BUILD_TYPE='Release' -DTEXWORKS_ADDITIONAL_LIBS="shlwapi" ..
