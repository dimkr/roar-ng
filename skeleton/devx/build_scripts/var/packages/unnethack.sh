#!/bin/sh

PKG_NAME="unnethack"
PKG_VER="4.0.0"
PKG_REV="1"
PKG_DESC="A variant of the roguelike game NetHack"
PKG_CAT="Fun"
PKG_DEPS=""

# the source package release date
PKG_DATE="20120401"

download() {
	[ -f $PKG_NAME-$PKG_VER-$PKG_DATE.tar.gz ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/unnethack/unnethack/$PKG_VER/$PKG_NAME-$PKG_VER-$PKG_DATE.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER-$PKG_DATE.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER-$PKG_DATE

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --docdir=/$DOC_DIR \
	            --disable-dummy-graphics \
	            --enable-curses-graphics \
	            --disable-tty-graphics \
	            --disable-mswin-graphics \
	            --enable-wizmode=root \
	            --with-compression="$(which xz)" \
	            --with-owner=root \
	            --with-group=root \
	            --with-gamesdir=/$SHARE_DIR/$PKG_NAME \
	            --with-bonesdir=/$VAR_DIR/$PKG_NAME/bones \
	            --with-savesdir=/$VAR_DIR/$PKG_NAME/saves \
	            --with-leveldir=/$VAR_DIR/$PKG_NAME/level
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1
	make -j $BUILD_THREADS manpages
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# install the man pages
	for i in doc/*.6
	do
		install -D -m644 $i $INSTALL_DIR/$MAN_DIR/man6/$(basename $i)
		[ $? -ne 0 ] && return 1
	done

	# install the license
	install -D -m644 dat/license $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/license
	[ $? -ne 0 ] && return 1

	return 0
}
