#!/bin/sh

PKG_NAME="ncsplash"
PKG_VER="git$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="A small and fast POSIX-compliant shell"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# download the sources
	git clone --depth 1 \
	          git://github.com/iguleder/ncsplash.git \
	          $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -e -9 > $PKG_NAME-$PKG_VER.tar.xz
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

	# build the package
	make CFLAGS="$CFLAGS"
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make PREFIX=$INSTALL_DIR/usr install
	[ $? -ne 0 ] && return 1

	return 0
}
