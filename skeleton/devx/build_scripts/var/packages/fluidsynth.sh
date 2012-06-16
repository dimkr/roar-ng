#!/bin/sh

PKG_NAME="fluidsynth"
PKG_VER="1.1.5"
PKG_REV="1"
PKG_DESC="A real-time software synthesizer"
PKG_CAT="Multimedia"
PKG_DEPS="+musescore-soundfont-gm"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/$PKG_NAME/$PKG_NAME-$PKG_VER/$PKG_NAME-$PKG_VER.tar.bz2
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
	            --enable-shared \
	            --disable-static \
	            --enable-double \
	            --disable-profiling \
	            --disable-ladspa \
	            --disable-trap-on-fpe \
	            --disable-fpe-check \
	            --disable-debug \
	            --disable-dbus-support \
	            --disable-libsndfile-support \
	            --disable-aufile-support \
	            --disable-pulse-support \
	            --enable-alsa-support \
	            --disable-portaudio-support \
	            --disable-oss-support \
	            --disable-midishare \
	            --disable-jack-support \
	            --disable-coreaudio \
	            --disable-coremidi \
	            --disable-dart \
	            --disable-lash \
	            --disable-ladcca \
	            --without-readline
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
