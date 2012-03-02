#!/bin/sh

PKG_NAME="simpleburn"
PKG_VER="1.6.3"
PKG_REV="1"
PKG_DESC="A simple CD/DVD burning and ripping application"
PKG_CAT="Multimedia"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://simpleburn.tuxfamily.org/IMG/bz2/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	CFLAGS="$CFLAGS $(pkg-config --libs --cflags gtk+-2.0)" \
	cmake . \
	      -DCMAKE_INSTALL_PREFIX=/$BASE_INSTALL_PREFIX \
	      -DDETECTION=UDEV \
	      -DBURNING=CDRTOOLS
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

	# remove unneeded documentation
	rm -f $INSTALL_DIR/$DOC_DIR/$PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# install the license and the list of authors
	install -D -m644 doc/LICENSE-EN $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE-EN
	[ $? -ne 0 ] && return 1
	install -D -m644 doc/AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
