#!/bin/sh

PKG_NAME="bwm-ng"
PKG_VER="0.6"
PKG_REV="1"
PKG_DESC="Simple bandwidth monitor"
PKG_CAT="Network"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.gropp.org/bwm-ng/$PKG_NAME-$PKG_VER.tar.gz
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
	            --disable-html \
	            --disable-csv \
	            --enable-extededstats \
	            --enable-configfile \
	            --disable-netstatpath \
	            --disable-netstatbyte \
	            --disable-netstatlink \
	            --enable-time \
	            --without-disktats \
	            --without-partitions
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

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 THANKS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/THANKS
	[ $? -ne 0 ] && return 1

	return 0
}
