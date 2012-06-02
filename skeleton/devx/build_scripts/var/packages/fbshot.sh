#!/bin/sh

PKG_NAME="fbshot"
PKG_VER="0.3"
PKG_REV="1"
PKG_DESC="Screenshot taking utility for the framebuffer"
PKG_CAT="Graphic"
PKG_DEPS="+libpng"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.sfires.net/stuff/$PKG_NAME/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER
	
	# set the compiler flags
	sed -i s~'gcc'~"cc $CFLAGS"~ Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 fbshot $INSTALL_DIR/$BIN_DIR/fbshot
	[ $? -ne 0 ] && return 1
	install -D -m644 fbshot.1.man $INSTALL_DIR/$MAN_DIR/man1/fbshot.1
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 CREDITS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/CREDITS
	[ $? -ne 0 ] && return 1

	return 0
}
