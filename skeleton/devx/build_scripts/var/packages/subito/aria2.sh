#!/bin/sh

PKG_NAME="aria2"
PKG_VER="1.14.2"
PKG_REV="1"
PKG_DESC="Multi-protoocol download tool"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/aria2/stable/$PKG_NAME-$PKG_VER/$PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-bittorrent \
	            --enable-metalink \
	            --with-gnutls \
	            --without-libnettle \
	            --without-libgmp \
	            --with-libgcrypt \
	            --without-openssl \
	            --without-sqlite3 \
	            --without-libxml2 \
	            --with-libexpat \
	            --without-libcares \
	            --with-libz
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

	# install the license and the list of authors
	install -D -m644 LICENSE.OpenSSL $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE.OpenSSL
	[ $? -ne 0 ] && return 1
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
