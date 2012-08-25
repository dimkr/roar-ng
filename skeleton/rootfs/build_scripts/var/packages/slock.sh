#!/bin/sh

PKG_NAME="slock"
PKG_VER="1.0"
PKG_REV="1"
PKG_DESC="A simple X server locking application"
PKG_CAT="Desktop"
PKG_DEPS="+xorg_base"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://dl.suckless.org/tools/$PKG_NAME-$PKG_VER.tar.gz
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
	make DESTDIR=$INSTALL_DIR PREFIX=/$BASE_INSTALL_PREFIX install
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
