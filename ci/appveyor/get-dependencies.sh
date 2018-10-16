#!/bin/sh

export hunspell_VERSION=1.6.2
export hunspell_ARCHIVE=v${hunspell_VERSION}.tar.gz
export hunspell_DIRNAME=hunspell-${hunspell_VERSION}
export hunspell_URL=https://github.com/hunspell/hunspell/archive/$hunspell_ARCHIVE

export poppler_VERSION=0.64.0
export poppler_ARCHIVE=poppler-${poppler_VERSION}.tar.xz
export poppler_DIRNAME=poppler-${poppler_VERSION}
export poppler_URL=https://poppler.freedesktop.org/${poppler_ARCHIVE}


export popplerdata_VERSION=0.4.9
export popplerdata_ARCHIVE=poppler-data-${popplerdata_VERSION}.tar.gz
export popplerdata_DIRNAME=poppler-data-${popplerdata_VERSION}
export popplerdata_URL=https://poppler.freedesktop.org/${popplerdata_ARCHIVE}


pacman --noconfirm -S mingw-w64-i686-freetype mingw-w64-i686-openjpeg2 mingw-w64-i686-lcms2 mingw-w64-i686-libpng mingw-w64-i686-libtiff mingw-w64-i686-curl mingw-w64-i686-lua

echo "Downloading poppler-data"
mkdir -p /c/projects/poppler-data
cd /c/projects/poppler-data
curl -sSL -O ${popplerdata_URL}
# FIXME: Check checksum
echo "Extracting poppler-data"
7z x "${popplerdata_ARCHIVE}" -so | 7z x -si -ttar


echo "Downloading poppler"
mkdir -p /c/projects/poppler
cd /c/projects/poppler
curl -sSL -O ${poppler_URL}
# FIXME: Check checksum
echo "Extracting poppler"
7z x "${poppler_ARCHIVE}" -so | 7z x -si -ttar
cd ${poppler_DIRNAME}
echo "Patching poppler"
for PATCH in $(find ${APPVEYOR_BUILD_FOLDER}/travis-ci/mxe/ -iname 'poppler-*.patch'); do
	echo "Applying ${PATCH}"
	patch -p1 < "${PATCH}"
done
echo "Building poppler"
mkdir build && cd build && cmake -G"MSYS Makefiles" -DCMAKE_BUILD_TYPE="Release" -DBUILD_QT5_TESTS=OFF -DENABLE_CPP=OFF -DENABLE_UTILS=OFF -DENABLE_XPDF_HEADERS=ON -DCMAKE_INSTALL_PREFIX="/mingw32" .. && make && make install


echo "Downloading hunspell"
mkdir -p /c/projects/hunspell
cd /c/projects/hunspell
curl -sSL -O ${hunspell_URL}
# FIXME: Check checksum
echo "Extracting hunspell"
7z x "${hunspell_ARCHIVE}" -so | 7z x -si -ttar
echo "Building hunspell"
cd ${hunspell_DIRNAME}
autoreconf -i && ./configure && make && make install

