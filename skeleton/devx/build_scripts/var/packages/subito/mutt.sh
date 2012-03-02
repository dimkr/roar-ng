#!/bin/sh

PKG_NAME="mutt"
PKG_VER="1.5.21"
PKG_REV="1"
PKG_DESC="Mail client"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file ftp://ftp.mutt.org/mutt/devel/$PKG_NAME-$PKG_VER.tar.gz
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
	            --disable-gpgme \
	            --enable-pop \
	            --enable-imap \
	            --enable-smtp \
	            --disable-debug \
	            --enable-hcache \
	            --without-included-gettext \
	            --with-mailpath=/$VAR_DIR/mail
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

	# remove bug-reporting related stuff
	rm -f $INSTALL_DIR/$BIN_DIR/flea \
	      $INSTALL_DIR/$BIN_DIR/muttbug \
	      $INSTALL_DIR/$MAN_DIR/man1/flea.1 \
	      $INSTALL_DIR/$MAN_DIR/man1/muttbug.1
	[ $? -ne 0 ] && return 1

	# add the mail directory
	mkdir -p $INSTALL_DIR/$VAR_DIR/mail
	[ $? -ne 0 ] && return 1

	# move the copyright notice to the right location
	mkdir -p $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	mv $INSTALL_DIR/$DOC_DIR/$PKG_NAME/COPYRIGHT $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1

	return 0
}
