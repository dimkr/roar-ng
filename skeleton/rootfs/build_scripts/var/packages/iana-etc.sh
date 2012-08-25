#!/bin/sh

PKG_NAME="iana-etc"
PKG_VER="2.30"
PKG_REV="1"
PKG_DESC="Lists of network protocols and services provided by IANA"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://www.sethwklein.net/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# download the latest files
	#make -j $BUILD_THREADS get
	#[ $? -ne 0 ] && return 1

	# configure the package
	sed -i s~'ETC_DIR=.*'~"ETC_DIR=/$CONF_DIR"~ Makefile
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

	# create backwards-compatibility symlinks
	if [ "etc" != "$CONF_DIR" ]
	then
		mkdir -p $INSTALL_DIR/etc
		[ $? -ne 0 ] && return 1
		ln -s ../$CONF_DIR/services $INSTALL_DIR/etc/services
		[ $? -ne 0 ] && return 1
		ln -s ../$CONF_DIR/protocols $INSTALL_DIR/etc/protocols
		[ $? -ne 0 ] && return 1
	fi

	# install the license and the list of authors
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1
	install -D -m644 CREDITS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/CREDITS
	[ $? -ne 0 ] && return 1

	return 0
}
