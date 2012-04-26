#!/bin/sh

PKG_NAME="snownews"
PKG_VER="1.5.12"
PKG_REV="1"
PKG_DESC="RSS news reader"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file https://kiza.kcore.de/media/software/snownews/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure --prefix=/$BASE_INSTALL_PREFIX
	[ $? -ne 0 ] && return 1
	sed -i s~'-O2'~"$CFLAGS"~ platform_settings
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

	# install the author name and the credits list
	install -D -m644 AUTHOR $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHOR
	[ $? -ne 0 ] && return 1
	install -D -m644 CREDITS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/CREDITS
	[ $? -ne 0 ] && return 1

	return 0
}
