cmake_minimum_required(VERSION 3.1)

project(TeXworksDependencyInstall)

find_package(Qt5 REQUIRED COMPONENTS Widgets)

# Adapted from https://github.com/Homebrew/homebrew-core/blob/e2c833d326c45d9aaf4e26af6dd8b2f31564dc04/Formula/fontconfig.rb
file(GLOB _font_dirs /System/Library/Assets*/com_apple_MobileAsset_Font*)
list(INSERT _font_dirs 0 /System/Library/Fonts /Library/Fonts ~/Library/Fonts)
string(REPLACE ";" "," _font_dirs "${_font_dirs}")

set(CONFIGURE_ENV CFLAGS=-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET} CXXFLAGS=-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET})
set(CONFIGURE_ARGS --prefix=${CMAKE_INSTALL_PREFIX})

set(CMAKE_ARGS -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} -DCMAKE_PREFIX_PATH="${CMAKE_INSTALL_PREFIX};${CMAKE_PREFIX_PATH}" -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE -DCMAKE_MACOSX_RPATH=TRUE -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX})

include(ExternalProject)

macro(ADD_GH_GROUP target)
	ExternalProject_Add_Step(${target} pre COMMENT "${target} start" COMMAND ${CMAKE_COMMAND} -E echo "::group::${target}" DEPENDERS mkdir ALWAYS TRUE)
	ExternalProject_Add_Step(${target} post COMMENT "${target} end" COMMAND ${CMAKE_COMMAND} -E echo "::endgroup::" DEPENDEES install ALWAYS TRUE)
endmacro(ADD_GH_GROUP)


ExternalProject_Add(libpng
	URL "https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz"
	URL_HASH SHA256=505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca
	CMAKE_ARGS ${CMAKE_ARGS}
)
ADD_GH_GROUP(libpng)

# TODO: harfbuzz?
ExternalProject_Add(freetype
	URL https://download.savannah.gnu.org/releases/freetype/freetype-2.11.1.tar.xz
	URL_HASH SHA256=3333ae7cfda88429c97a7ae63b7d01ab398076c3b67182e960e5684050f2c5c8
	CMAKE_ARGS ${CMAKE_ARGS} -DBUILD_SHARED_LIBS=TRUE
	DEPENDS libpng
)
ADD_GH_GROUP(freetype)

# Modeled after https://github.com/Homebrew/homebrew-core/blob/72ca636/Formula/gettext.rb
ExternalProject_Add(gettext
	URL https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz
	URL_HASH SHA256=d20fcbb537e02dcf1383197ba05bd0734ef7bf5db06bdb241eb69b7d16b73192
	CONFIGURE_COMMAND ${CONFIGURE_ENV} ./configure ${CONFIGURE_ARGS} --disable-dependency-tracking --disable-silent-rules --disable-debug --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-included-gettext --disable-java --disable-csharp --without-git --without-cvs --without-xz
	BUILD_IN_SOURCE TRUE
)
ADD_GH_GROUP(gettext)

ExternalProject_Add(hunspell
	URL "https://github.com/hunspell/hunspell/archive/refs/tags/v1.7.0.tar.gz"
	URL_HASH SHA256=bb27b86eb910a8285407cf3ca33b62643a02798cf2eef468c0a74f6c3ee6bc8a
	CONFIGURE_COMMAND autoreconf -vfi && ${CONFIGURE_ENV} CPPFLAGS=-I${CMAKE_INSTALL_PREFIX}/include LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib ./configure ${CONFIGURE_ARGS}
	BUILD_IN_SOURCE TRUE
	DEPENDS gettext
)
ADD_GH_GROUP(hunspell)

# fontconfig 2.13.94 is broken (configure.ac doesn't determine/handle default fonts correctly)
ExternalProject_Add(fontconfig
	URL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.93.tar.xz
	URL_HASH SHA256=ea968631eadc5739bc7c8856cef5c77da812d1f67b763f5e51b57b8026c1a0a0
	CONFIGURE_COMMAND ${CONFIGURE_ENV} CPPFLAGS=-I${CMAKE_INSTALL_PREFIX}/include LDFLAGS=-L${CMAKE_INSTALL_PREFIX}/lib ./configure ${CONFIGURE_ARGS} --with-add-fonts=${_font_dirs} --disable-docs
	BUILD_IN_SOURCE TRUE
	INSTALL_COMMAND make install RUN_FC_CACHE_TEST=false
	DEPENDS freetype gettext
)
ADD_GH_GROUP(fontconfig)

ExternalProject_Add(libjpeg
	URL https://ijg.org/files/jpegsrc.v9e.tar.gz
	URL_HASH SHA256=4077d6a6a75aeb01884f708919d25934c93305e49f7e3f36db9129320e6f4f3d
	CONFIGURE_COMMAND ${CONFIGURE_ENV} ./configure ${CONFIGURE_ARGS}
	BUILD_IN_SOURCE TRUE
)
ADD_GH_GROUP(libjpeg)

# jbig? Lzma?
ExternalProject_Add(libtiff
	URL "https://download.osgeo.org/libtiff/tiff-4.3.0.tar.gz"
	URL_HASH SHA256=0e46e5acb087ce7d1ac53cf4f56a09b221537fc86dfc5daaad1c2e89e1b37ac8
	CMAKE_ARGS ${CMAKE_ARGS}
	DEPENDS libjpeg
)
ADD_GH_GROUP(libtiff)

ExternalProject_Add(libopenjpeg
	URL https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.4.0.tar.gz
	URL_HASH SHA256=8702ba68b442657f11aaeb2b338443ca8d5fb95b0d845757968a7be31ef7f16d
	CMAKE_ARGS ${CMAKE_ARGS}
	DEPENDS libtiff
)
ADD_GH_GROUP(libopenjpeg)

ExternalProject_Add(lcms2
	URL "https://github.com/mm2/Little-CMS/archive/refs/tags/lcms2.12.tar.gz"
	URL_HASH SHA256=e90e77e43be35ec149d39f1ee7fe1c50c73309773a55b13839090f7138fbdcde
	CONFIGURE_COMMAND ${CONFIGURE_ENV} ./configure ${CONFIGURE_ARGS} --with-tiff="${CMAKE_INSTALL_PREFIX}" --with-jpeg="${CMAKE_INSTALL_PREFIX}"
	BUILD_IN_SOURCE TRUE
	DEPENDS libtiff libjpeg
)
ADD_GH_GROUP(lcms2)

# cairo?
ExternalProject_Add(poppler
	URL "https://poppler.freedesktop.org/poppler-22.01.0.tar.xz"
	URL_HASH SHA256=7d3493056b5b86413e5c693c2cae02c5c06cd8e618d14c2c31e2c84b67b2313e
	CMAKE_ARGS ${CMAKE_ARGS} -DENABLE_BOOST=FALSE -DENABLE_CPP=FALSE -DENABLE_UTILS=FALSE -DENABLE_UNSTABLE_API_ABI_HEADERS=TRUE
	DEPENDS fontconfig freetype lcms2 libjpeg libopenjpeg libpng libtiff
)
ADD_GH_GROUP(poppler)

ExternalProject_Add(poppler-data
	URL https://poppler.freedesktop.org/poppler-data-0.4.11.tar.gz
	URL_HASH SHA256=2cec05cd1bb03af98a8b06a1e22f6e6e1a65b1e2f3816cb3069bb0874825f08c
	CMAKE_ARGS ${CMAKE_ARGS}
)
ADD_GH_GROUP(poppler-data)

ExternalProject_Add(lua
	URL "https://www.lua.org/ftp/lua-5.4.3.tar.gz"
	URL_HASH SHA1=1dda2ef23a9828492b4595c0197766de6e784bc7
	CONFIGURE_COMMAND ""
	BUILD_COMMAND make MYCFLAGS="-mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}"
	BUILD_IN_SOURCE TRUE
	INSTALL_COMMAND make install INSTALL_TOP="${CMAKE_INSTALL_PREFIX}"
)
ADD_GH_GROUP(lua)
