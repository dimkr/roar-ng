#!/bin/sh

PKG_NAME="volumeicon"
PKG_VER="0.4.5"
PKG_REV="1"
PKG_DESC="Audio volume control tray icon"
PKG_CAT="Multimedia"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://softwarebakery.com/maato/files/volumeicon/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# set the default external mixer, turn the slider on by default and
	# make it horizonal
	sed -e s/"xterm -e 'alsamixer'"/'urxvt -title AlsaMixer -e alsamixer'/ \
	    -e s/'static gboolean m_lmb_slider = FALSE;'/'static gboolean m_lmb_slider = TRUE;'/ \
	    -e s/'static gboolean m_use_horizontal_slider = FALSE;'/'static gboolean m_use_horizontal_slider = TRUE;'/ \
	    -i src/config.c
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-oss \
	            --disable-notify
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

	# remove all icon themes
	rm -rf $INSTALL_DIR/$SHARE_DIR/$PKG_NAME/icons/*
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
