#!/bin/sh

hunspell_VERSION=1.6.2
hunspell_ARCHIVE=v${hunspell_VERSION}.tar.gz
hunspell_DIRNAME=hunspell-${hunspell_VERSION}
hunspell_URL=https://github.com/hunspell/hunspell/archive/$hunspell_ARCHIVE

poppler_VERSION=0.64.0
poppler_ARCHIVE=poppler-${poppler_VERSION}.tar.xz
poppler_DIRNAME=poppler-${poppler_VERSION}
poppler_URL=https://poppler.freedesktop.org/${poppler_ARCHIVE}


#mkdir -p /c/projects/hunspell
#cd /c/projects/hunspell
#curl -sSL -O ${hunspell_URL}
## FIXME: Check checksum
#7z x "${hunspell_ARCHIVE}" -so | 7z x -si -ttar
#cd ${hunspell_DIRNAME}
#autoreconf -i && ./configure && make


mkdir -p /c/projects/poppler
cd /c/projects/poppler

pacman -Ss freetype
pacman --noconfirm -S mingw-w64-i686-freetype mingw-w64-i686-openjpeg2 mingw-w64-i686-lcms2 mingw-w64-i686-libpng mingw-w64-i686-libtiff
#jpeg

curl -sSL -O ${poppler_URL}
# FIXME: Check checksum
7z x "${poppler_ARCHIVE}" -so | 7z x -si -ttar
cd ${poppler_DIRNAME}
mkdir build && cd build && cmake -G"MSYS Makefiles" -DENABLE_CPP=OFF -DENABLE_UTILS=OFF -DENABLE_XPDF_HEADERS=ON .. && make

