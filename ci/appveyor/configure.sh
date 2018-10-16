#!/bin/sh

mkdir -p "${APPVEYOR_BUILD_FOLDER}/build"
cd "${APPVEYOR_BUILD_FOLDER}/build"

# Extract poppler-data (required by some tests)
mkdir -p share
cp -r /c/projects/poppler-data/${popplerdata_DIRNAME} share/poppler

# FIXME: DEBUG
ls -l share/poppler

cmake -G"MSYS Makefiles" -DTW_BUILD_ID='appveyor' -DDESIRED_QT_VERSION='5' -DCMAKE_BUILD_TYPE='Release' -DTEXWORKS_ADDITIONAL_LIBS="shlwapi" -DWITH_LUA=OFF ..
