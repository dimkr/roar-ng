#!/bin/sh

PKG_NAME="msmtp"
PKG_VER="1.4.27"
PKG_REV="1"
PKG_DESC="SMTP client"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://sourceforge.net/projects/msmtp/files/msmtp/$PKG_VER/$PKG_NAME-$PKG_VER.tar.bz2
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
	            --with-ssl=gnutls \
	            --without-libgsasl \
	            --without-libidn \
	            --without-gnome-keyring \
	            --without-macosx-keyring
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

	# create a symlink to sendmail
	ln -s msmtp $INSTALL_DIR/$BIN_DIR/sendmail
	[ $? -ne 0 ] && return 1

	# install the list of authors and the list of thanks
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 THANKS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/THANKS
	[ $? -ne 0 ] && return 1

	return 0
}
