#!/bin/sh

cd "${APPVEYOR_BUILD_FOLDER}/build"

make -j VERBOSE=1

# FIXME: DEBUG
ls -1
