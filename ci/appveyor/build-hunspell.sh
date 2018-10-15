#!/bin/sh

hunspell_VERSION=1.6.2
hunspell_ARCHIVE=v${hunspell_VERSION}.tar.gz
hunspell_DIRNAME=hunspell-${hunspell_VERSION}

mkdir -p /c/projects/hunspell
cd /c/projects/hunspell

curl -sSL -O https://github.com/hunspell/hunspell/archive/$hunspell_ARCHIVE

# FIXME: Check checksum

#tar -xf $hunspell_ARCHIVE
7z x "$hunspell_ARCHIVE" -so | 7z x -si -ttar

cd $hunspell_DIRNAME

echo "OK4"
ls

autoreconf -i && ./configure && make
