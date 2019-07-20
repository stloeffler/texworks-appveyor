#!/bin/sh

. ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/defs.sh
. ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/package_versions.sh

print_headline "Packaging TeXworks"

cd "${APPVEYOR_BUILD_FOLDER}/build"

make VERBOSE=1 install

strip -s "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

# Copy Qt dlls
windeployqt --release "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

## Copy Hunspell dll
#cp /mingw64/lib/../bin/libhunspell-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#
## Copy Poppler dlls
#cp /mingw64/bin/libpoppler-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#
#cp /mingw64/bin/zlib1.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libcurl-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libfreetype-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libjpeg-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/liblcms2-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libpng16-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libtiff-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"
#cp /mingw64/bin/libopenjp2-*.dll "${APPVEYOR_BUILD_FOLDER}/artifact/bin/"

python ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/resolve-dlls.py "${APPVEYOR_BUILD_FOLDER}/artifact/bin/TeXworks.exe"

# Copy poppler data
cp -r share "${APPVEYOR_BUILD_FOLDER}/artifact/"

# FIXME: DEBUG
ls -lisaR "${APPVEYOR_BUILD_FOLDER}/artifact/"
du -hd 1 "${APPVEYOR_BUILD_FOLDER}/artifact/"
