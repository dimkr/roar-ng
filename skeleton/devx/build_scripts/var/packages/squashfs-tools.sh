#!/bin/sh

PKG_NAME="squashfs-tools"
PKG_VER="4.2"
PKG_REV="1"
PKG_DESC="Tools for the Squashfs file system"
PKG_CAT="BuildingBlock"
PKG_DEPS="+zlib,+xz,+lzo"

# choose the default compression - LZO for ARM, otherwise XZ
case $PKG_ARCH in
	arm*)
		DEFAULT_COMPRESSION="lzo"
		;;
	*)
		DEFAULT_COMPRESSION="xz"
		;;
esac

download() {
	[ -f squashfs$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://downloads.sourceforge.net/project/squashfs/squashfs/squashfs$PKG_VER/squashfs$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf squashfs$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd squashfs$PKG_VER/squashfs-tools

	# configure the package
	sed -e s~'^#XZ_SUPPORT = 1'~'XZ_SUPPORT = 1'~ \
	    -e s~'^#LZO_SUPPORT = 1'~'LZO_SUPPORT = 1'~ \
	    -e s~'^XATTR_SUPPORT = 1'~'XATTR_SUPPORT = 0'~ \
	    -e s~'^XATTR_DEFAULT = 1'~'XATTR_DEFAULT = 0'~ \
	    -e S~'^COMP_DEFAULT = gzip'~"COMP_DEFAULT = $DEFAULT_COMPRESSION"~ \
	    -i Makefile
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 mksquashfs $INSTALL_DIR/$BIN_DIR/mksquashfs
	[ $? -ne 0 ] && return 1
	install -D -m755 unsquashfs $INSTALL_DIR/$BIN_DIR/unsquashfs
	[ $? -ne 0 ] && return 1

	return 0
}
