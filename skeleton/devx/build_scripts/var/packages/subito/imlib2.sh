#!/bin/sh

PKG_NAME="imlib2"
PKG_VER="1.4.5"
PKG_REV="1"
PKG_DESC="Image loading library, with extra loaders"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && [ -f imlib2_loaders-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarballs
	download_file http://downloads.sourceforge.net/project/enlightenment/$PKG_NAME-src/$PKG_VER/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	download_file http://downloads.sourceforge.net/project/enlightenment/$PKG_NAME-src/$PKG_VER/imlib2_loaders-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the imlib2 sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	# extract the imlib2_loaders sources tarball
	tar -xjvf imlib2_loaders-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the imlib2 package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --enable-shared \
	            --disable-static \
	            --without-id3
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	cd ../imlib2_loaders-$PKG_VER

	# configure the imlib2_loaders package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --enable-shared \
	            --disable-static
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	cd ../$PKG_NAME-$PKG_VER

	# install the imlib2 package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	cd ../imlib2_loaders-$PKG_VER

	# install the imlib2_loaders package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# install the license, the simple English license and the list of authors
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1
	install -D -m644 COPYING-PLAIN $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING-PLAIN
	[ $? -ne 0 ] && return 1
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
