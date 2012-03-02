#!/bin/sh

PKG_NAME="parcellite"
PKG_VER="1.0.2rc5"
PKG_REV="1"
PKG_DESC="Clipboard manager"
PKG_CAT="Utility"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://sourceforge.net/projects/parcellite/files/parcellite/$PKG_NAME-$PKG_VER/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# clean the sources
	make distclean
	[ $? -ne 0 ] && return 1

	# replace ALT with SHIFT, to avoid conflicts with other applications
	sed -i s/'<Ctrl><Alt>'/'<Ctrl><Shift>'/g src/preferences.h
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS
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

	# remove unneeded files and directories
	rm -rf $INSTALL_DIR/$CONF_DIR \
	       $INSTALL_DIR/$SHARE_DIR/pixmaps/parcellite.xpm \
	       $INSTALL_DIR/$SHARE_DIR/pixmaps/parcellite.svg\
	       $INSTALL_DIR/$SHARE_DIR/applications
	[ $? -ne 0 ] && return 1

	# move the icon to the right location
	if [ "$PIXMAP_DIR" != "$SHARE_DIR/pixmaps" ]
	then
		mkdir -p $INSTALL_DIR/$PIXMAP_DIR
		[ $? -ne 0 ] && return 1
		mv $INSTALL_DIR/$SHARE_DIR/pixmaps/parcellite.png \
		   $INSTALL_DIR/$PIXMAP_DIR
		[ $? -ne 0 ] && return 1
		rmdir $INSTALL_DIR/$SHARE_DIR/pixmaps
		[ $? -ne 0 ] && return 1
	fi

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
