#!/bin/sh

PKG_NAME="tty-clock"
PKG_VER="git$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="Digital clock"
PKG_CAT="Utility"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources
	git clone --depth 1 git://github.com/xorg62/tty-clock.git $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 > $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -e s~'^CFLAGS = .*'~"& $CFLAGS"~ \
	    -e s~'^INSTALLPATH = .*'~"INSTALLPATH = /$INSTALL_DIR/$BASE_INSTALL_PREFIX"~ \
	    -e s~'^LDFLAGS = .*'~"& $LDFLAGS"~ \
	    -i Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 tty-clock $INSTALL_DIR/$BIN_DIR/tty-clock
	[ $? -ne 0 ] && return 1

	return 0
}
