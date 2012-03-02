#!/bin/sh

PKG_NAME="zathura"
PKG_VER="0.0.8.5"
PKG_REV="1"
PKG_DESC="PDF viewer"
PKG_CAT="Document"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://pwmt.org/download/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# build the package
	make -j $BUILD_THREADS PREFIX=/$BASE_INSTALL_PREFIX
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make PREFIX=/$BASE_INSTALL_PREFIX DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
