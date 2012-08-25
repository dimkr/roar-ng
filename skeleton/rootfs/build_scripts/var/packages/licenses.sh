#!/bin/sh

PKG_NAME="licenses"
PKG_VER="1"
PKG_REV="1"
PKG_DESC="The text of various free software licenses"
PKG_CAT="Help"
PKG_DEPS=""

LICENSES="http://www.gnu.org/licenses/gpl-3.0.txt,gpl-3.0.txt
          http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt,gpl-2.0.txt
          http://www.gnu.org/licenses/lgpl-3.0.txt,lgpl-3.0.txt
          http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt,lgpl-2.1.txt
          http://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt,lgpl-2.0.txt
          http://www.gnu.org/licenses/fdl-1.3.txt,fdl-1.3.txt
          http://www.gnu.org/licenses/old-licenses/fdl-1.2.txt,fdl-1.2.txt
          http://www.gnu.org/licenses/old-licenses/fdl-1.1.txt,fdl-1.1.txt
          http://www.debian.org/misc/bsd.license,bsd.txt
          http://www.apache.org/licenses/LICENSE-2.0.txt,apache-2.0.txt"
          
download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	
	# create a directory
	mkdir $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1
	
	cd $PKG_NAME-$PKG_VER
	
	# download all licenses
	for license in $LICENSES
	do
		download_file $(echo $license | sed s/,/\ /)
		[ $? -ne 0 ] && return 1
	
	
	done
	
	cd ..
	
	# create a tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 -e > $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1
	
	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1
	
	return 0
}

build() {
	# extract the tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER
		
	return 0
}

package() {
	# install all licenses
	mkdir -p $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	install -m644 * $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	
	return 0
}
