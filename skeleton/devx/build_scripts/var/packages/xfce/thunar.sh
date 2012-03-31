#!/bin/sh

PKG_NAME="thunar"
PKG_VER="1.3.1"
PKG_REV="1"
PKG_DESC="File manager for Xfce"
PKG_CAT="System"
PKG_DEPS="+glib,+gtk+,+xfconf,+libxfce4ui,+exo"

download() {
	[ -f Thunar-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://archive.xfce.org/src/xfce/$PKG_NAME/1.3/Thunar-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf Thunar-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd Thunar-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-static \
	            --enable-shared \
	            --disable-dbus \
	            --disable-startup-notification \
	            --enable-gudev \
	            --disable-notifications \
	            --disable-debug \
	            --enable-apr-plugin \
	            --disable-exif \
	            --disable-sbr-plugin \
	            --disable-pcre \
	            --disable-tpa-plugin \
	            --enable-uca-plugin \
	            --disable-wallpaper-plugin
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
