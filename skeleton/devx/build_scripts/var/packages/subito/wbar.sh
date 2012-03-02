#!/bin/sh

PKG_NAME="wbar"
PKG_VER="2.2.2"
PKG_REV="1"
PKG_DESC="Lightweight dock"
PKG_CAT="Desktop"
PKG_DEPS="+imlib2"

download() {
	[ -f $PKG_NAME-$PKG_VER.tbz2 ] && return 0
	# download the sources tarball
	download_file http://wbar.googlecode.com/files/$PKG_NAME-$PKG_VER.tbz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tbz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# patch the sources to make wbar set its window name, so it can be skipped
	# by window managers
	echo -n 'diff -rup wbar-2.2.2-orig//src/core/Main.cc wbar-2.2.2/src/core/Main.cc
--- wbar-2.2.2-orig//src/core/Main.cc	2011-05-08 22:21:07.000000000 +0200
+++ wbar-2.2.2/src/core/Main.cc	2011-12-24 16:04:28.775088026 +0200
@@ -162,6 +162,8 @@ int main(int argc, char **argv)
         INIT_IMLIB(barwin.getDisplay(), barwin.getVisual(), barwin.getColormap(),
                 barwin.getDrawable(), 2048*2048);

+        barwin.setName((char *) "wbar");
+
         /* check if double clicking, ms time */
         dblclk_tm = optparser.isSet(DBLCLK)?atoi(optparser.getArg(DBLCLK).c_str()):0;

' | patch -p1
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-wbar-config
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

	# remove an unneeded directory
	rm -rf $INSTALL_DIR/$SHARE_DIR/wbar/glade
	[ $? -ne 0 ] && return 1

	# remove XDG-related stuff
	rm -rf $INSTALL_DIR/$CONF_DIR/xdg
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
