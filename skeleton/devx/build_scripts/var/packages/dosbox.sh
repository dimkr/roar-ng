#!/bin/sh

PKG_NAME="dosbox"
PKG_VER="0.74"
PKG_REV="1"
PKG_DESC="A MS-DOS Emulator"
PKG_CAT="Fun"
PKG_DEPS="+sdl"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/$PKG_NAME/$PKG_NAME/$PKG_VER/$PKG_NAME-$PKG_VER.tar.gz
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
	            --disable-debug \
	            --enable-core-inline \
	            --enable-dynamic-core \
	            --enable-dynamic-x86 \
	            --enable-dynrec \
	            --enable-fpu \
	            --enable-fpu-x86 \
	            --enable-opengl
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

	# install the documentation
	install -D -m644 README $INSTALL_DIR/$DOC_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1
	install -D -m644 docs/README.video $INSTALL_DIR/$DOC_DIR/$PKG_NAME/REAME.video
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 THANKS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/THANKS
	[ $? -ne 0 ] && return 1
	
	return 0
}
