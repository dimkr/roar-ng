#!/bin/sh

PKG_NAME="gpm"
PKG_VER="1.20.6"
PKG_REV="1"
PKG_DESC="A mouse server"
PKG_CAT="BuildingBlock"
PKG_DEPS="+ncurses"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://www.nico.schottelius.org/software/gpm/archives/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

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

	# install the README
	install -D -m644 README $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1

	return 0
}
