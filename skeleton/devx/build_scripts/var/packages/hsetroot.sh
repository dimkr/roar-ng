#!/bin/sh

PKG_NAME="hsetroot"
PKG_VER="1.0.2"
PKG_REV="1"
PKG_DESC="Desktop background utility"
PKG_CAT="Desktop"
PKG_DEPS="+imlib2"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://cdn.thegraveyard.org/releases/hsetroot/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# generate a new configure script
	autoconf
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS
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

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
