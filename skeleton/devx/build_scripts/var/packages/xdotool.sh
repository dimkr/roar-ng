#!/bin/sh

PKG_NAME="xdotool"
PKG_VER="2.20110530.1"
PKG_REV="1"
PKG_DESC="An X11 automation tool"
PKG_CAT="Utility"
PKG_DEPS="+xorg_base"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://semicomplete.googlecode.com/files/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# disable debugging
	sed -i s/'^CFLAGS\+='/'#CFLAGS+='/ Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR \
	     PREFIX=/$BASE_INSTALL_PREFIX \
	     INSTALLBIN=/$BIN_DIR \
	     INSTALLLIB=/$LIB_DIR \
	     INSTALLMAN=/$MAN_DIR \
	     INSTALLINCLUDE=/$INCLUDE_DIR \
	     install
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 COPYRIGHT $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYRIGHT
	[ $? -ne 0 ] && return 1

	return 0
}
