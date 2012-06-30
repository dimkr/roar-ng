#!/bin/sh

PKG_NAME="subito-desktop"
PKG_VER="git$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="The Subito GNU/Linux desktop"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# download the sources
	git clone --depth 1 \
	          git://github.com/iguleder/subito.git \
	          $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# rename the skeleton directory
	mv subito-desktop $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 -e > ../$PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd ..

	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the skeleton
	cp -ar $PKG_NAME-$PKG_VER $INSTALL_DIR
	[ $? -ne 0 ] && return 1

	return 0
}
