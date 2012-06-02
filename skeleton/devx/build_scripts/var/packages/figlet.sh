#!/bin/sh

PKG_NAME="figlet"
PKG_VER="2.2.5"
PKG_REV="1"
PKG_DESC="A program for making large letters out of text" 
PKG_CAT="Utility"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file ftp://ftp.figlet.org/pub/figlet/program/unix/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# build the package
	make -j $BUILD_THREADS CC=cc LD=cc \
	                       CFLAGS="$CFLAGS" \
	                       DEFAULTFONTDIR=/$SHARE_DIR/$PKG_NAME/fonts \
	                       all
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR \
	     prefix=/$BASE_INSTALL_PREFIX \
	     BINDIR=/$BIN_DIR \
	     MANDIR=/$MAN_DIR \
	     DEFAULTFONTDIR=/$SHARE_DIR/$PKG_NAME/fonts \
	     install
	[ $? -ne 0 ] && return 1

	# install the README 
	install -D -m644 README $INSTALL_DIR/$DOC_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1

	# install the license 
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
