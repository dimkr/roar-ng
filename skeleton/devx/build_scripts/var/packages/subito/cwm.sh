#!/bin/sh

PKG_NAME="cwm"
PKG_VER="cvs$(date +%d%m%Y)"
PKG_REV="1"
PKG_DESC="Minimalistic window manager"
PKG_CAT="Desktop"
PKG_DEPS="+libbsd"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0

	# download the sources
	mkdir $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	# determine the list of source files
	download_file http://www.openbsd.org/cgi-bin/cvsweb/xenocara/app/cwm index.html
	[ $? -ne 0 ] && return 1
	files="$(cat index.html | grep href=\"./ | cut -f 10 -d \=  | cut -f 2 -d \> | cut -f 1 -d \<)"
	[ $? -ne 0 ] && return 1
	rm -f index.html
	[ $? -ne 0 ] && return 1

	# download the source files
	for i in $files
	do
		download_file "http://www.openbsd.org/cgi-bin/cvsweb/xenocara/app/cwm/$i?rev=HEAD;content-type=text%2Fplain" $PKG_NAME-$PKG_VER/$i
		[ $? -ne 0 ] && return 1
	done

	# create a sources tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 > $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	return 0
}

build() {
	# extract the sources
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# patch the package to link against libbsd instead of having the BSD C
	# library functions compiled in statically
	echo -n '--- cwm-cvs01122011-orig/calmwm.h	2011-12-01 11:46:46.034898678 +0200
+++ cwm-cvs01122011/calmwm.h	2011-12-01 11:47:41.445205948 +0200
@@ -31,6 +31,15 @@
 #include <X11/extensions/Xrandr.h>
 #include <X11/keysym.h>

+/* BSD C library functions, through libbsd */
+#include <bsd/stdio.h> /* fgetln() */
+#include <bsd/stdlib.h> /* strtonum() */
+#include <bsd/string.h> /* strlcat(), strlcpy() */
+
+/* two missing BSD C library definitions */
+#define TAILQ_END(head) NULL
+#define __dead
+
 #undef MIN
 #undef MAX
 #define MIN(x, y) ((x) < (y) ? (x) : (y))
' | patch calmwm.h
  	[ $? -ne 0 ] && return 1

	# add a missing header to xevents.c and kbfunc.c
	sed -i s/'#include <unistd.h>'/'&\n#include <signal.h>'/ xevents.c kbfunc.c
  	[ $? -ne 0 ] && return 1

	# replace the Shift key with Super, so key bindings of GTK+ or Qt do not
	# conflict with cwm
	sed -i s/'ShiftMask'/'Mod4Mask'/ conf.c
	[ $? -ne 0 ] && return 1

	# build the package
	bison parse.y
	[ $? -ne 0 ] && return 1
	cc $CFLAGS $(pkg-config --libs libbsd xft xinerama xrandr xcb xft x11 xau xdmcp fontconfig xext) -lexpat -lfreetype -lz -o cwm *.c
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	install -D -m755 cwm $INSTALL_DIR/$BIN_DIR/cwm
	[ $? -ne 0 ] && return 1
	install -D -m644 cwm.1 $INSTALL_DIR/$MAN_DIR/man1/cwm.1
	[ $? -ne 0 ] && return 1
	install -D -m644 cwmrc.5 $INSTALL_DIR/$MAN_DIR/man5/cwmrc.5
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
