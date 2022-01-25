#!/bin/sh

cd "${APPVEYOR_BUILD_FOLDER}/build"

# Copy poppler dll to here it is looking for relevant data (e.g., poppler-data,
# fonts) relative to its location
cp /mingw64/bin/libpoppler*.dll .

ctest -V
