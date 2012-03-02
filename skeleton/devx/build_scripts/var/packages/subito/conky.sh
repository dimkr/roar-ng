#!/bin/sh

PKG_NAME="conky"
PKG_VER="1.8.1"
PKG_REV="1"
PKG_DESC="Lightweight system monitor"
PKG_CAT="Desktop"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/conky/conky/$PKG_VER/$PKG_NAME-$PKG_VER.tar.bz2
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
	            --disable-static \
	            --enable-shared \
	            --enable-config-output \
	            --enable-own-window \
	            --disable-ncurses \
	            --enable-audacious=no \
	            --disable-bmpx \
	            --disable-ibm \
	            --disable-hddtemp \
	            --disable-apcupsd \
	            --disable-iostats \
	            --disable-math \
	            --disable-mpd \
	            --disable-moc \
	            --disable-xmms2 \
	            --disable-curl \
	            --disable-eve \
	            --disable-rss \
	            --disable-weather-metar \
	            --disable-weather-xoap \
	            --enable-x11 \
	            --disable-argb \
	            --disable-imlib2 \
	            --disable-lua-imlib2 \
	            --disable-lua \
	            --disable-lua-cairo \
	            --disable-wlan \
	            --disable-portmon \
	            --enable-double-buffer \
	            --disable-xdamage \
	            --enable-xft \
	            --disable-nvidia \
	            --disable-alsa \
	            --disable-debug \
	            --disable-testing \
	            --disable-profiling
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

	# remove an unneeded configuration file
	rm -f $INSTALL_DIR/$CONF_DIR/conky/conky_no_x11.conf
	[ $? -ne 0 ] && return 1

	# install the license and the list of authors
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
