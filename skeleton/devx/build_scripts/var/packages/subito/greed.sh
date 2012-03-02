#!/bin/sh

PKG_NAME="greed"
PKG_VER="3.7"
PKG_REV="1"
PKG_DESC="Strategy game"
PKG_CAT="Fun"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.catb.org/~esr/greed/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -e s~'SFILE=.*'~"SFILE=/$CONF_DIR/greed.hs"~ \
	    -e s~'-O3'~"$CFLAGS"~ \
	    -i Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 greed $INSTALL_DIR/$BIN_DIR/greed
	[ $? -ne 0 ] && return 1
	install -D -m644 greed.6 $INSTALL_DIR/$MAN_DIR/man6/greed.6
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 COPYING $INSTALL_DIR/$DOC_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
