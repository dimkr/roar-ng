#!/bin/sh

PKG_NAME="screen"
PKG_VER="4.0.3"
PKG_REV="1"
PKG_DESC="Terminal multiplexer"
PKG_CAT="Utility"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://ftp.gnu.org/gnu/$PKG_NAME/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# generate a new configure script
	autoconf
	[ $? -ne 0 ] && return 1

	# prevent the configure script from finding libelf, so the binary does not
	# link against it, eventually
	sed -i s/'-lelf'/'-lnot_exists'/ configure
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-pam \
	            --disable-telnet \
	            --enable-colors256 \
	            --enable-rxvt_osc \
	            --with-sys-screenrc=/$CONF_DIR/screenrc
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

	# keep only one file in the binaries directory
	rm -f $INSTALL_DIR/$BIN_DIR/screen.old \
	      $INSTALL_DIR/$BIN_DIR/screen-$PKG_VER.old \
          $INSTALL_DIR/$BIN_DIR/screen
	[ $? -ne 0 ] && return 1
	mv $INSTALL_DIR/$BIN_DIR/$PKG_NAME-$PKG_VER $INSTALL_DIR/$BIN_DIR/screen
	[ $? -ne 0 ] && return 1

	# install the sample configuration
	install -D -m644 etc/etcscreenrc $INSTALL_DIR/$CONF_DIR/screenrc
	[ $? -ne 0 ] && return 1

	return 0
}
