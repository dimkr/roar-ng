#!/bin/sh

PKG_NAME="cmus"
PKG_VER="2.4.3"
PKG_REV="1"
PKG_DESC="Console music player"
PKG_CAT="Multimedia"
PKG_DEPS="+libmad,+libvorbis,+flac,+libav"

download() {
	[ -f $PKG_NAME-v$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://sourceforge.net/projects/cmus/files/$PKG_NAME-v$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-v$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-v$PKG_VER

	# configure the package
	./configure prefix=/$BASE_INSTALL_PREFIX \
	            libdir=/$LIB_DIR \
	            DEBUG=0 \
	            CONFIG_ROAR=n \
	            CONFIG_PULSE=n \
	            CONFIG_ALSA=y \
	            CONFIG_AO=n \
	            CONFIG_ARTS=n \
	            CONFIG_OSS=n \
	            CONFIG_SUN=n
	            CONFIG_WAVEOUT=n
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

	return 0
}
