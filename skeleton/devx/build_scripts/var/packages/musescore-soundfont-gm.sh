#!/bin/sh

PKG_NAME="musescore-soundfont-gm"
PKG_VER="1.2"
PKG_REV="1"
PKG_DESC="A GM SoundFont from MuseScore"
PKG_CAT="Multimedia"
PKG_DEPS=""

download() {
	[ -f mscore-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/mscore/mscore/MuseScore-$PKG_VER/mscore-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf mscore-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd mscore-$PKG_VER/mscore

	return 0
}

package() {
	# install the sound font 
	install -D -m644 share/sound/TimGM6mb.sf2 $INSTALL_DIR/$SHARE_DIR/sounds/sf2/TimGM6mb.sf2
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/musescore/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
