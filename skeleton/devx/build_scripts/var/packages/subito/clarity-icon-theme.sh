#!/bin/sh

PKG_NAME="clarity-icon-theme"
PKG_VER="0.3.2"
PKG_REV="1"
PKG_DESC="Icon theme"
PKG_CAT="Desktop"
PKG_DEPS=""

ICONS="devices/drive-optical.svg,optical48.png
       devices/drive-harddisk.svg,drive48.png
       devices/drive-removable-media.svg,usbdrv48.png
       devices/gnome-dev-floppy.svg,floppy48.png
       devices/gnome-dev-media-ms.svg,card48.png
       devices/gnome-dev-trash-empty.svg,trashcan_empty48.png
       devices/gnome-dev-trash-full.svg,trashcan_full48.png
       apps/gnome-terminal.svg,console48.png
       mimetypes/application-x-gzip.svg,archive48.png
       apps/browser.svg,www48.png
       apps/calendar.svg,date48.png
       apps/chat.svg,chat48.png
       apps/evolution-mail.svg,email48.png
       apps/gconfeditor.svg,configuration48.png
       apps/gedit.svg,edit48.png
       apps/gnome-help.svg,help48.png
       apps/gnome-home.svg,home48.png
       apps/multimedia.svg,multimedia48.png
       apps/gnome-package.svg,pet48.png
       apps/gnome-nettools.svg,connect48.png
       apps/password.svg,lock-screen48.png
       apps/preferences-desktop-theme.svg,x48.png
       places/folder.svg,folder48.png
       apps/kcalc.svg,spread48.png
       apps/mypaint.svg,paint48.png
       mimetypes/text-html.svg,webedit48.png
       mimetypes/image.svg,draw48.png
       mimetypes/application-vnd.oasis.opendocument.text.svg,word48.png"

download() {
	[ -f ${PKG_NAME}_$PKG_VER.tar.gz ] && return 0
	# download the sources tarball
	download_file http://www.fileden.com/files/2011/2/28/3088999/${PKG_NAME}_$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources tarball
	tar -xzvf ${PKG_NAME}_$PKG_VER.tar.gz
	[ $? -ne 0 ] && return 1

	cd ${PKG_NAME}_$PKG_VER

	# configure the package
	./configure
	[ $? -ne 0 ] && return 1

	# create the SVG icons
	make -j $BUILD_THREADS gen_canus scalable
	[ $? -ne 0 ] && return 1

	cd scalable

	# convert the icons to PNG format
	for i in $ICONS
	do
	echo $i
		rsvg-convert -w 48 -h 48 -o $(echo $i | cut -f 2 -d ,) $(echo $i | cut -f 1 -d ,)
		[ $? -ne 0 ] && return 1
	done

	return 0
}

package() {
	# install the converted icons
	for i in $ICONS
	do
		name="$(echo $i | cut -f 2 -d ,)"
		install -D -m644 $name $INSTALL_DIR/$PIXMAP_DIR/$name
		[ $? -ne 0 ] && return 1
	done

	# install the license
	mkdir -p $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME
	[ $? -ne 0 ] && return 1
	cat ../README | head -n 9 > $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1
	chmod 644 $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1

	return 0
}
