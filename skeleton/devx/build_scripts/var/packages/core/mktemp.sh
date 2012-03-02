#!/bin/sh

PKG_NAME="mktemp"
PKG_VER="1.7"
PKG_REV="1"
PKG_DESC="Tool for creation of temporary files and directories"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file ftp://ftp.mktemp.org/pub/mktemp/$PKG_NAME-$PKG_VER.tar.gz
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
	            --with-libc
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

	# create a backwards-compatibility symlink
	if [ "bin" != "$BIN_DIR" ]
	then
		mkdir $INSTALL_DIR/bin
		[ $? -ne 0 ] && return 1
		ln -s ../$BIN_DIR/mktemp $INSTALL_DIR/bin/mktemp
		[ $? -ne 0 ] && return 1
	fi

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
