#!/bin/sh

PKG_NAME="aspell6-en"
PKG_VER="7.1-0"
PKG_REV="1"
PKG_DESC="English dictionary for Aspell"
PKG_CAT="BuildingBlock"
PKG_DEPS="+aspell"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file ftp://ftp.gnu.org/gnu/aspell/dict/en/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure PREZIP=/$BIN_DIR/prezip-bin
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# install the copyright statement
	install -D -m644 Copyright $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/Copyright
	[ $? -ne 0 ] && return 1

	return 0
}
