#!/bin/sh

PKG_NAME="re-alpine"
PKG_VER="2.02"
PKG_REV="1"
PKG_DESC="E-mail client, continuation of Alpine"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://sourceforge.net/projects/$PKG_NAME/files/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# set the CFLAGS
	sed -i s~'^GCCCFLAGS=.*'~"GCCCFLAGS=$CFLAGS"~ \
	       imap/src/osdep/unix/Makefile
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-static \
	            --enable-shared \
	            --disable-debug \
	            --enable-mouse \
	            --disable-quotas \
	            --with-system-pinerc=/$CONF_DIR/$PKG_NAME/pine.conf \
	            --with-system-fixed-pinerc=/$CONF_DIR/$PKG_NAME/pine.conf.fixed \
	            --without-passfile \
	            --with-debug-level=0 \
	            --with-ssl \
	            --with-krb5 \
	            --without-tcl \
	            --with-smime \
	            --without-supplied-regex \
	            --with-ipv6
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

	# install the notice
	install -D -m644 NOTICE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/NOTICE
	[ $? -ne 0 ] && return 1

	return 0
}
