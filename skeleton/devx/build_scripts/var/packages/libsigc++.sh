#!/bin/sh

PKG_NAME="libsigc++"
PKG_VER="2.2.10"
PKG_REV="1"
PKG_DESC="Callback system for C++"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources tarball
	download_file http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.2/$PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-static \
	            --enable-shared \
	            --disable-documentation
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
