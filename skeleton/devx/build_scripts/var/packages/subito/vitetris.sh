#!/bin/sh

PKG_NAME="vitetris"
PKG_VER="0.57"
PKG_REV="1"
PKG_DESC="Tetris clone"
PKG_CAT="Fun"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://victornils.net/tetris/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure --prefix=/$BASE_INSTALL_PREFIX \
	            --bindir=/$BIN_DIR \
	            --datarootdir=/$SHARE_DIR \
	            --docdir=/$DOC_DIR/$PKG_NAME \
	            --pixmapdir=/$PIXMAP_DIR \
	            --desktopdir=/$DESKTOP_DIR \
	            --disable-2player \
	            --disable-joystick \
	            --disable-network \
	            --disable-xlib
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

	# create a symlink to the executable
	ln -s tetris $INSTALL_DIR/$BIN_DIR/vitetris
	[ $? -ne 0 ] && return 1
	
	# move the license to the right location
	mkdir -p $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	mv $INSTALL_DIR/$DOC_DIR/$PKG_NAME/licence.txt $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1

	return 0
}
