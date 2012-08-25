#!/bin/sh

PKG_NAME="fbset"
PKG_VER="2.1"
PKG_REV="1"
PKG_DESC="Framebuffer console configuration tool"
PKG_CAT="Utility"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://users.telenet.be/geertu/Linux/fbdev/$PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf $PKG_NAME-$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -i s~'^CC =.*'~"CC = $CC $CFLAGS"~ Makefile
	[ $? -ne 0 ] && return 1

	# set the path to fb.modes
	sed -i s~'#define DEFAULT_MODEDBFILE.*'~"#define DEFAULT_MODEDBFILE \"/$CONF_DIR/fb.modes\""~ fbset.c
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 fbset $INSTALL_DIR/$SBIN_DIR/fbset
	[ $? -ne 0 ] && return 1
	install -D -m644 fbset.8 $INSTALL_DIR/$MAN_DIR/man8/fbset.8
	[ $? -ne 0 ] && return 1
	install -D -m644 fb.modes.5 $INSTALL_DIR/$MAN_DIR/man5/fb.modes.5
	[ $? -ne 0 ] && return 1
	install -D -m644 etc/fb.modes.ATI $INSTALL_DIR/$CONF_DIR/fb.modes
	[ $? -ne 0 ] && return 1

	return 0
}
