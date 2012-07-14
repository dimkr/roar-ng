#!/bin/sh

PKG_NAME="movgrab"
PKG_VER="1.1.9"
PKG_REV="1"
PKG_DESC="Video downloader"
PKG_CAT="Internet"
PKG_DEPS="+zlib,+openssl"

download() {
	[ -f $PKG_NAME-$PKG_VER.tgz ] && return 0
	# download the sources tarball
	download_file http://sites.google.com/site/columscode/files/$PKG_NAME-$PKG_VER.tgz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tgz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# generate a new makefile for libUseful
	cd libUseful-2.0
	autoconf
	[ $? -ne 0 ] && return 1
	cd ..

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --enable-ssl
	[ $? -ne 0 ] && return 1

	# set the binary location
	sed -i s~'bindir=.*'~"bindir=/$BIN_DIR"~ Makefile
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

	# install the README
	install -D -m644 README $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1

	return 0
}
