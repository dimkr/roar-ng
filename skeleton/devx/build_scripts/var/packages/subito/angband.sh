#!/bin/sh

PKG_NAME="angband"
PKG_VER="3.3.2"
PKG_REV="1"
PKG_DESC="Single-player dungeon exploration game"
PKG_CAT="Fun"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-v$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://rephial.org/downloads/3.3/$PKG_NAME-v$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-v$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-v$PKG_VER

	autoconf
	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --with-configpath=/$CONF_DIR/$PKG_NAME \
	            --with-varpath=/$VAR_DIR/$PKG_NAMEl \
	            --disable-gtk \
	            --enable-curses \
	            --disable-x11 \
	            --disable-sdl \
	            --disable-test \
	            --disable-stats \
	            --disable-sdl-mixer \
	            --disable-sdltest \
	            --with-x
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	cp -p install-sh lib
	[ $? -ne 0 ] && return 1
	cp -p install-sh lib/xtra
	[ $? -ne 0 ] && return 1
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# remove unneeded stuff
	rm -rf $INSTALL_DIR/$SHARE_DIR/$PKG_NAME/xtra
	[ $? -ne 0 ] && return 1

	# install the license and the list of credits
	install -D -m644 copying.txt $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/copying.txt
	[ $? -ne 0 ] && return 1
	install -D -m644 thanks.txt $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/thanks.txt
	[ $? -ne 0 ] && return 1

	return 0
}
