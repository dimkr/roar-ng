#!/bin/sh

PKG_NAME="rtorrent"
PKG_VER="0.8.9"
PKG_REV="1"
PKG_DESC="BitTorrent client"
PKG_CAT="Internet"
PKG_DEPS="+libtorrent"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://libtorrent.rakshasa.no/downloads/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-debug \
	            --disable-extra-debug \
	            --enable-ipv6 \
	            --without-xmlrpc-c
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

	# install the man page
	install -D -m644 doc/rtorrent.1 $INSTALL_DIR/$MAN_DIR/man1/rtorrent.1
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
