#!/bin/sh

PKG_NAME="fbv"
PKG_VER="1.0b"
PKG_REV="1"
PKG_DESC="Framebuffer image viewer"
PKG_CAT="Graphic"
PKG_DEPS="+libjpeg,+libpng"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://s-tech.elsat.net.pl/$PKG_NAME/$PKG_NAME-$PKG_VER.tar.gz
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
	            --infodir=/$SHARE_DIR/info \
	            --mandir=/$MAN_DIR \
	            --without-libungif \
	            --without-bmp
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# create the installation directory
	mkdir -p $INSTALL_DIR/$BIN_DIR $INSTALL_DIR/$MAN_DIR/man1
	[ $? -ne 0 ] && return 1

	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# install the README
	install -D -m644 README $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/README
	[ $? -ne 0 ] && return 1

	return 0
}
