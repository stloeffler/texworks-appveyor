#!/bin/sh

. ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/defs.sh
. ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/package_versions.sh

print_headline "Packaging TeXworks"

cd "${APPVEYOR_BUILD_FOLDER}/build"

make VERBOSE=1 install

strip -s "${APPVEYOR_BUILD_FOLDER}/artifact/TeXworks.exe"

# Copy Qt dlls
windeployqt --release "${APPVEYOR_BUILD_FOLDER}/artifact/TeXworks.exe"

print_info "Resolving DLL Dependencies"

python ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/resolve-dlls.py "${APPVEYOR_BUILD_FOLDER}/artifact/TeXworks.exe"
python ${APPVEYOR_BUILD_FOLDER}/ci/appveyor/resolve-dlls.py "${APPVEYOR_BUILD_FOLDER}/artifact/libTWLuaPlugin.dll"

# Copy poppler data
cp -r share "${APPVEYOR_BUILD_FOLDER}/artifact/"

# FIXME: DEBUG
#ls -lisaR "${APPVEYOR_BUILD_FOLDER}/artifact/"
ls -lisa "/c/msys64/mingw64/bin"
du -hd 1 "${APPVEYOR_BUILD_FOLDER}/artifact/"
