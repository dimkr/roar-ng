#!/bin/sh

PKG_NAME="fbpdf"
PKG_VER="git$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="A small PDF viewer for the framebuffer console"
PKG_CAT="Document"
PKG_DEPS="+poppler"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# download the sources
	git clone --depth 1 git://repo.or.cz/fbpdf.git $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 -e > $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -i s~'^CFLAGS = .*'~"CFLAGS = $CFLAGS"~ Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS fbpdf2
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the executable
	install -D -m755 fbpdf2 $INSTALL_DIR/$BIN_DIR/fbpdf
	[ $? -ne 0 ] && return 1

	# install the README
	install -D -m644 README $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1

	return 0
}
