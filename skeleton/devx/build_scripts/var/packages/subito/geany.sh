#!/bin/sh

PKG_NAME="geany"
PKG_VER="0.21"
PKG_REV="1"
PKG_DESC="Text editor with basic features of an IDE"
PKG_CAT="Document"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://download.geany.org/$PKG_NAME-$PKG_VER.tar.bz2
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
	            --enable-plugins \
	            --disable-gnu-regex \
	            --enable-socket \
	            --disable-vte \
	            --disable-the-force
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

	# remove the license
	rm -f $INSTALL_DIR/$DOC_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	# move the list of authors to its right location
	mkdir -p $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	mv $INSTALL_DIR/$DOC_DIR/$PKG_NAME/AUTHORS \
	   $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	mv $INSTALL_DIR/$DOC_DIR/$PKG_NAME/THANKS \
	   $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME

	return 0
}
