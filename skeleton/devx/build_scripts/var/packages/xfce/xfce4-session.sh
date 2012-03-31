#!/bin/sh

PKG_NAME="xfce4-session"
PKG_VER="4.9.0"
PKG_REV="1"
PKG_DESC="Session manager for Xfce"
PKG_CAT="BuildingBlock"
PKG_DEPS="+perl,+dbus-glib,+libxfce4ui,+libwnck"

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
	            --disable-libgnome-keyring \
	            --disable-debug	\
	            --disable-legacy-sm
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
