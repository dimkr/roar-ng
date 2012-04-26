#!/bin/sh

PKG_NAME="terminus-font"
PKG_VER="4.36"
PKG_REV="1"
PKG_DESC="A monospace, bitmap font"
PKG_CAT="Desktop"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://sourceforge.net/projects/terminus-font/files/$PKG_NAME-$PKG_VER/$PKG_NAME-$PKG_VER.tar.gz
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
	            --x11dir=/$SHARE_DIR/fonts/misc \
	            --psfdir=/usr/share/kbd/consolefonts
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

	# add the post-install script
	echo -n "#!/bin/sh
	
mkfontscale ./$SHARE_DIR/fonts/misc
mkfontdir ./$SHARE_DIR/fonts/misc
[ \"\$(pwd)\" = \"/\" ] && fc-cache -fv" > $INSTALL_DIR/post_install.sh
	[ $? -ne 0 ] && return 1
	chmod 755 $INSTALL_DIR/post_install.sh
	[ $? -ne 0 ] && return 1

	# install the license and the list of authors
	install -D -m644 OFL.TXT $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/OFL.TXT
	[ $? -ne 0 ] && return 1
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
