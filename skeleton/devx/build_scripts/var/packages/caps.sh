#!/bin/sh

PKG_NAME="caps"
PKG_VER="0.4.5"
PKG_REV="1"
PKG_DESC="An audio plugin suite" 
PKG_CAT="Multimedia"
PKG_DEPS=""

download() {
	[ -f ${PKG_NAME}_$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.quitte.de/dsp/${PKG_NAME}_$PKG_VER.tar.gz 
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf ${PKG_NAME}_$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	sed -e s~'^OPTS =.*'~"OPTS = $CFLAGS"~ \
	    -e s~'^LDFLAGS =.*'~"LDFLAGS = $LDFLAGS -nostartfiles -shared"~ \
	    -e s~'^PREFIX =.*'~"PREFIX = /$INSTALL_DIR"~ \
	    -e s~'^DEST =.*'~"DEST = \$(PREFIX)/$LIB_DIR/ladspa"~ \
	    -e s~'^RDFDEST =.*'~"RDFDEST = \$(PREFIX)/$SHARE_DIR/ladspa/rdf"~ \
	    -i Makefile
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

	# install the documentation 
	install -D -m644 caps.html $INSTALL_DIR/$DOC_DIR/$PKG_NAME/caps.html
	[ $? -ne 0 ] && return 1

	return 0
}
