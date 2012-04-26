#!/bin/sh

PKG_NAME="fetchmail"
PKG_VER="6.3.21"
PKG_REV="1"
PKG_DESC="Mail retrieval tool"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources tarball
	download_file http://download.berlios.de/fetchmail/$PKG_NAME-$PKG_VER.tar.xz
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
	            --disable-POP2 \
	            --enable-POP3 \
	            --enable-IMAP \
	            --disable-ETRN \
	            --disable-ODMR \
	            --disable-RPA \
	            --enable-NTLM \
	            --disable-SDPS \
	            --without-socks \
	            --without-socks5 \
	            --without-kerberos \
	            --with-ssl \
	            --without-hesiod \
	            --without-gssapi
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

	# remove fetchmailconf
	rm -rf $INSTALL_DIR/$BIN_DIR/fetchmailconf \
	       $INSTALL_DIR/$MAN_DIR/man1/fetchmailconf.1 \
	       $INSTALL_DIR/$LIB_DIR
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
