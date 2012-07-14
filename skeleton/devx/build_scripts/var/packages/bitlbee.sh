#!/bin/sh

PKG_NAME="bitlbee"
PKG_VER="3.0.5"
PKG_REV="1"
PKG_DESC="An IRC to other networks gateway"
PKG_CAT="Internet"
PKG_DEPS="+gnutls,+glib2"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://get.bitlbee.org/src/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# set the pkgconfig files directory
	sed -i s~"pcdir='\$prefix/lib/pkgconfig'"~"pcdir='/$LIB_DIR/pkgconfig'"~ \
	    configure
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure --prefix=/$BASE_INSTALL_PREFIX \
	            --bindir=/$BIN_DIR \
	            --sbindir=/$SBIN_DIR \
	            --etcdir=/$CONF_DIR \
	            --mandir=/$MAN_DIR \
	            --datadir=/$SHARE_DIR/$PKG_NAME \
	            --plugindir=/$LIB_DIR/$PKG_NAME \
	            --pidfile=/$VAR_DIR/run/$PKG_NAME \
	            --config=/$VAR_DIR/lib/$PKG_NAME \
	            --msn=1 \
	            --jabber=1 \
	            --oscar=1 \
	            --yahoo=1 \
	            --purple=0 \
	            --debug=0 \
	            --strip=0 \
	            --gcov=0 \
	            --plugins=1 \
	            --otr=0 \
	            --skype=0 \
	            --events=glib \
	            --ssl=gnutls
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
	make DESTDIR=$INSTALL_DIR install-etc
	[ $? -ne 0 ] && return 1
	make DESTDIR=$INSTALL_DIR install-dev
	[ $? -ne 0 ] && return 1

	# create the variable data directory
	mkdir -p $INSTALL_DIR/$VAR_DIR/lib/$PKG_NAME
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 doc/AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 doc/CREDITS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/CREDITS
	[ $? -ne 0 ] && return 1

	return 0
}
