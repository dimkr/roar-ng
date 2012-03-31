#!/bin/sh

PKG_NAME="libxfce4ui"
PKG_VER="4.9.1"
PKG_REV="1"
PKG_DESC="Widgets library for Xfce"
PKG_CAT="BuildingBlock"
PKG_DEPS="+gtk+,+libxfce4util,+xfconf"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://archive.xfce.org/src/xfce/$PKG_NAME/4.9/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-static \
	            --enable-shared \
	            --disable-startup-notification \
	            --enable-keyboard-library \
	            --disable-gladeui \
	            --disable-debug
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

	# install the list of authors and the credits
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 THANKS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/THANKS
	[ $? -ne 0 ] && return 1

	return 0
}
