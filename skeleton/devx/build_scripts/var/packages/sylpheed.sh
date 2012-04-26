#!/bin/sh

PKG_NAME="sylpheed"
PKG_VER="3.1.4"
PKG_REV="1"
PKG_DESC="Lightweight and user-friendly e-mail client"
PKG_CAT="Internet"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://osdn.dl.sourceforge.jp/sylpheed/55683/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-static \
	            --enable-shared \
	            --disable-gpgme \
	            --disable-jpilot \
	            --disable-ldap \
	            --enable-ssl \
	            --disable-compface \
	            --disable-gtkspell \
	            --disable-oniguruma \
	            --enable-threads \
	            --enable-ipv6 \
	            --disable-updatecheck \
	            --disable-updatecheckplugin \
	            --with-manualdir=/$DOC_DIR/$PKG_NAME/manual \
	            --with-faqdir=/$DOC_DIR/$PKG_NAME/faq \
	            --with-plugindir=/$LIB_DIR/$PKG_NAME
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

	# create the plugin directory
	mkdir -p $INSTALL_DIR/$LIB_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
