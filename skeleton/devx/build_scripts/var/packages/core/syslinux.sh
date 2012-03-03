#!/bin/sh

PKG_NAME="syslinux"
PKG_VER="4.05"
PKG_REV="1"
PKG_DESC="Lightweight boot loaders"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# download the sources tarball
	download_file http://www.kernel.org/pub/linux/utils/boot/syslinux/$PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# do not build the DOS and Windows tools - it will fail
	sed -i s/'dos win32 win64 dosutil'// Makefile
	[ $? -ne 0 ] && return 1

	# change the installation paths
	sed -e s~'^SBINDIR.*=.*'~"SBINDIR = /$SBIN_DIR"~ \
	    -e s~'^LIBDIR.*=.*'~"LIBDIR = /$LIB_DIR"~ \
	    -e s~'^AUXDIR.*=.*'~"AUXDIR = /$LIB_DIR/syslinux"~ \
	    -e s~'^MANDIR.*=.*'~"MANDIR = /$MAN_DIR"~ \
	    -i mk/syslinux.mk
	[ $? -ne 0 ] && return 1

	# set the compiler flags
	sed -i s~'^OPTFLAGS.*=.*'~"OPTFLAGS = $CFLAGS"~ mk/build.mk
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make INSTALLROOT=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	return 0
}
