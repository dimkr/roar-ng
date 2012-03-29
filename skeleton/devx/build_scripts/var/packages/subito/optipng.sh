#!/bin/sh

PKG_NAME="optipng"
PKG_VER="0.7.1"
PKG_REV="1"
PKG_DESC="A PNG optimizer"
PKG_CAT="Graphic"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://prdownloads.sourceforge.net/$PKG_NAME/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure --prefix=/$BASE_INSTALL_PREFIX
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

	# install the license
	install -D -m644 LICENSE.txt $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE.txt
	[ $? -ne 0 ] && return 1

	return 0
}
