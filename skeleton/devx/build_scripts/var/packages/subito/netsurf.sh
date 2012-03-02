#!/bin/sh

PKG_NAME="netsurf"
PKG_VER="2.8"
PKG_REV="1"
PKG_DESC="Web browser"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER-full-src.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.netsurf-browser.org/downloads/releases/$PKG_NAME-$PKG_VER-full-src.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER-full-src.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	echo -n "NETSURF_USE_HARU_PDF := NO
NETSURF_USE_MNG := NO
NETSURF_USE_NSSVG := NO
NETSURF_USE_ROSPRITE := NO
NETSURF_USE_WEBP := NO
NETSURF_USE_DRAW := NO
NETSURF_USE_ARTWORKS := NO
NETSURF_USE_PLUGINS := NO
NETSURF_USE_DRAW_EXPORT := NO
NETSURF_USE_SPRITE := NO" > $PKG_NAME-$PKG_VER/Makefile.config
	[ $? -ne 0 ] && return 1

	# set the compiler flags
	for i in $(find . -name Makefile.gcc)
	do
		sed -e s~'CCOPT := .*'~"CCOPT := $CFLAGS"~ \
		    -e s~'CXXOPT := .*'~"CXXOPT := $CXXFLAGS"~ \
		    -i $i
		[ $? -ne 0 ] && return 1
	done

	sed -i s~'-O2'~"-L$install_dir/$LIB_DIR -I$install_dir/$INCLUDE_DIR"~g \
	    $PKG_NAME-$PKG_VER/Makefile.defaults
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS PREFIX=/$BASE_INSTALL_PREFIX TARGET=gtk
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make PREFIX=/$BASE_INSTALL_PREFIX DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# remove the icon theme
	rm -rf $INSTALL_DIR/$SHARE_DIR/netsurf/themes/gtk+
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 $PKG_NAME-$PKG_VER/COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
