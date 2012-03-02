#!/bin/sh

PKG_NAME="xpad"
PKG_VER="4.1"
PKG_REV="1"
PKG_DESC="A sticky notes application"
PKG_CAT="Personal"
PKG_DEPS=""

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://launchpad.net/xpad/trunk/$PKG_VER/+download/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# prevent the help message from showing on the first run
	echo "diff -rup xpad-4.1-orig//src/xpad-app.c xpad-4.1/src/xpad-app.c
--- xpad-4.1-orig//src/xpad-app.c	2012-01-05 18:01:14.345070651 +0200
+++ xpad-4.1/src/xpad-app.c	2012-01-05 18:01:53.372582691 +0200
@@ -95,7 +95,6 @@ static gboolean  xpad_app_open_proc_file
 static void
 xpad_app_init (int argc, char **argv)
 {
-	gboolean first_time;
 	gboolean have_gtk;
 /*	GdkVisual *visual;*/
 	
@@ -113,7 +112,6 @@ xpad_app_init (int argc, char **argv)
 	output = stdout;
 	
 	/* Set up config directory. */
-	first_time = !config_dir_exists ();
 	config_dir = make_config_dir ();
 	
 	/* create master socket name */
@@ -180,9 +178,6 @@ xpad_app_init (int argc, char **argv)
 	
 	g_idle_add ((GSourceFunc)xpad_app_first_idle_check, pad_group);
 	
-	if (first_time)
-		show_help ();
-	
 	g_free (server_filename);
 	server_filename = NULL;
 }" | patch -p1
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --enable-debug=no
	[ $? -ne 0 ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	# generate a PNG logo
	rsvg-convert -w 48 -h 48 -o xpad.png images/hicolor/scalable/apps/xpad.svg
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make DESTDIR=$INSTALL_DIR install
	[ $? -ne 0 ] && return 1

	# remove the SVG icon
	rm -rf $INSTALL_DIR/$SHARE_DIR/icons
	[ $? -ne 0 ] && return 1

	# install the menu entry
	install -D -m644 xpad.desktop $INSTALL_DIR/$DESKTOP_DIR/xpad.desktop
	[ $? -ne 0 ] && return 1

	# install the icon
	install -D -m644 xpad.png $INSTALL_DIR/$PIXMAP_DIR/xpad.png
	[ $? -ne 0 ] && return 1

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1
	install -D -m644 THANKS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/THANKS
	[ $? -ne 0 ] && return 1
	return 0
}
