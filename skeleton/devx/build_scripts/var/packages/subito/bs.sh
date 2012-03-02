#!/bin/sh

PKG_NAME="bs"
PKG_VER="2.8"
PKG_REV="1"
PKG_DESC="Clone of the Battleships game"
PKG_CAT="Fun"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.catb.org/~esr/bs/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 bs $INSTALL_DIR/$BIN_DIR/bs
	[ $? -ne 0 ] && return 1
	install -D -m644 bs.6 $INSTALL_DIR/$MAN_DIR/man6/bs.6
	[ $? -ne 0 ] && return 1

	return 0
}
