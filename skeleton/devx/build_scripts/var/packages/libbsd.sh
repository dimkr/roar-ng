#!/bin/sh

PKG_NAME="libbsd"
PKG_VER="0.3.0"
PKG_REV="1"
PKG_DESC="BSD functions library"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://libbsd.freedesktop.org/releases/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -e s~'^prefix.*=.*'~"prefix=/$BASE_INSTALL_PREFIX"~ \
	    -e s~'^exec_prefix.*=.*'~"exec_prefix=/$BASE_INSTALL_PREFIX"~ \
	    -e s~'^libdir.*=.*'~"libdir=/$LIB_DIR"~ \
	    -e s~'^usrlibdir.*=.*'~"usrlibdir=/$LIB_DIR"~ \
	    -i Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# remove the static library, to prevent packages from linking against it
	rm -f $INSTALL_DIR/$LIB_DIR/libbsd.a
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
