#!/bin/sh

PKG_NAME="subtlepatterns"
PKG_VER="1"
PKG_REV="1"
PKG_DESC="High quality, distributable patterns useful as desktop backgrounds"
PKG_CAT="Desktop"
PKG_DEPS=""

# the patterns to include in the package, by their ID
PATTERNS="641 695 845 750 676 573 820 907 826 1015 934 944 1024 1022 1083 1117 1119 1134"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.xz ] && return 0
	# create a directory
	mkdir $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# add the license
	echo -n 'This work is licensed under a Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
The patterns can be used freely in both personal and commercial projects with no attribution required, but always appreciated. Made by Atle Mo.' > LICENSE
	[ $? -ne 0 ] && return 1

	# download the patterns and list their authors
	for i in $PATTERNS
	do
		download_file http://www.subtlepatterns.com/?p=$i ../index.html
		[ $? -ne 0 ] && return 1
		name="$(cat ../index.html | grep '<h2>' | head -n 1 | cut -f 2 -d \> | cut -f 1 -d \<)"
		[ $? -ne 0 ] || [ -z "$name" ] && return 1
		author="$(cat ../index.html | grep '^<p>Made by' | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | cut -f 2- -d \ | head -c -2 | cut -f 2- -d \ )"
		[ $? -ne 0 ] || [ -z "$author" ] && return 1
		file_name="$(cat ../index.html  | grep Download | grep .png | head -n 2 | tail -n 1 | cut -f 4 -d \")"
		[ $? -ne 0 ] || [ -z "$file_name" ] && return 1
		rm -f ../index.html
		[ $? -ne 0 ] && return 1
		download_file http://www.subtlepatterns.com/$file_name
		[ $? -ne 0 ] && return 1
		echo "$name ($(echo $file_name | cut -f 2 -d /)) by $author" >> AUTHORS
		[ $? -ne 0 ] && return 1
	done

	chmod 644 *
	[ $? -ne 0 ] && return 1

	cd ..

	# create a patterns tarball
	tar -c $PKG_NAME-$PKG_VER | xz -9 > $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	# clean up
	rm -rf $PKG_NAME-$PKG_VER
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the patterns tarball
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	return 0
}

package() {
	# install the patterns
	for i in *.png
	do
		install -D -m644 $i $INSTALL_DIR/$SHARE_DIR/backgrounds/$i
		[ $? -ne 0 ] && return 1
	done

	# add the license the list of authors
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
