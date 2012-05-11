#!/bin/sh

PKG_NAME="locale-gen"
PKG_VER="svn$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="A locale generation tool"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# create a directory for the sources
	mkdir $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# download the sources
	download_file http://projects.archlinux.org/svntogit/packages.git/plain/trunk/locale-gen?h=packages/glibc \
	              locale-gen
	[ $? -ne 0 ] && return 1

	download_file http://projects.archlinux.org/svntogit/packages.git/plain/trunk/locale.gen.txt?h=packages/glibc \
                      locale.gen
        [ $? -ne 0 ] && return 1

	cd ..

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -e -9 > $PKG_NAME-$PKG_VER.tar.xz
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

	return 0
}

package() {
	# install locale-gen
	install -D -m755 locale-gen $INSTALL_DIR/$SBIN_DIR/locale-gen
	[ $? -ne 0 ] && return 1
	
	# install locale.gen, the configuration file
	install -D -m644 locale.gen $INSTALL_DIR/$CONF_DIR/locale.gen
	[ $? -ne 0 ] && return 1

	# add English to the default configuration
	cat << EOF >> $INSTALL_DIR/$CONF_DIR/locale.gen

en_US.UTF-8 UTF-8
EOF
	[ $? -ne 0 ] && return 1
	
	return 0
}
