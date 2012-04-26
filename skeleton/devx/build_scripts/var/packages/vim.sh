#!/bin/sh

PKG_NAME="vim"
PKG_VER="7.3.486"
PKG_REV="1"
PKG_DESC="Improved implementation of the vi text editor"
PKG_CAT="Document"
PKG_DEPS=""

# the package major version
PKG_MAJOR_VER="$(echo $PKG_VER | cut -f 1-2 -d .)"

# the patch version
PKG_PATCH_VER="$(echo $PKG_VER | cut -f 3 -d .)"

download() {
	# download the sources tarball
	if [ ! -f $PKG_NAME-$PKG_MAJOR_VER.tar.bz2 ]
	then
		download_file ftp://ftp.vim.org/pub/vim/unix/$PKG_NAME-$PKG_MAJOR_VER.tar.bz2
		[ $? -ne 0 ] && return 1
	fi

	if [ ! -f $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER.tar.xz ]
	then
		# create a directory for the patches
		mkdir $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER
		[ $? -ne 0 ] && return 1

		cd $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER

		# download the patches
		for i in $(seq -w $PKG_PATCH_VER)
		do
			download_file ftp://ftp.vim.org/pub/vim/patches/$PKG_MAJOR_VER/$PKG_MAJOR_VER.$i
			[ $? -ne 0 ] && return 1
		done

		cd ..

		# create a patches tarball
		tar -c $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER | xz -9 > $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER.tar.xz
		[ $? -ne 0 ] && return 1ls

		# clean up
		rm -rf $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER
		[ $? -ne 0 ] && return 1
	fi

	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_MAJOR_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	# extract the patches tarball
	tar -xJvf $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME$(echo $PKG_MAJOR_VER | sed s/\\.//)

	# apply the patches
	for i in $(seq -w $PKG_PATCH_VER)
	do
		patch -p0 < ../$PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER/$PKG_MAJOR_VER.$i
		[ $? -ne 0 ] && return 1
	done

	# set the location of the vimrc file
	echo "#define SYS_VIMRC_FILE \"/$CONF_DIR/vimrc\"" >> src/feature.h
	[ $? -ne 0 ] && return 1

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-darwin \
	            --disable-selinux \
	            --disable-xsmp \
	            --disable-xsmp-interact \
	            --enable-luainterp=no \
	            --disable-mzschemeinterp \
	            --enable-perlinterp=no \
	            --enable-pythoninterp=no \
	            --enable-python3interp=no \
	            --disable-tclinterp \
	            --disable-rubyinterp \
	            --disable-cscope \
	            --disable-workshop \
	            --disable-netbeans \
	            --disable-sniff \
	            --enable-multibyte \
	            --disable-hangulinput \
	            --disable-xim \
	            --disable-fontset \
	            --enable-gui=no \
	            --disable-gtk2-check \
	            --disable-gnome-check \
	            --disable-motif-check \
	            --disable-athena-check \
	            --disable-nextaw-check \
	            --disable-carbon-check \
	            --disable-acl \
	            --disable-gpm \
	            --disable-sysmouse \
	            --with-features=normal \
	            --without-x \
	            --without-gnome
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

	# install the license
	install -D -m644 runtime/doc/uganda.txt $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/uganda.txt
	[ $? -ne 0 ] && return 1

	return 0
}
