#!/bin/sh

PKG_NAME="sxiv"
PKG_VER="git$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="Simple imlib2-based image viewer"
PKG_CAT="Graphic"
PKG_DEPS="+imlib2"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources
	git clone --depth 1 git://github.com/muennich/sxiv.git $PKG_NAME-$PKG_VER
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
	sed -e s~'-O2'~"$CFLAGS"~ \
	    -e s~'/usr/local'~"/$BASE_INSTALL_PREFIX"~ \
	    -e s~'^LDFLAGS =.*'~"LDFLAGS = $LDFLAGS"~ \
	    -i Makefile
	[ $? -ne 0 ] && return 1

	# generate config.h
	make -j $BUILD_THREADS config.h
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

	return 0
}
