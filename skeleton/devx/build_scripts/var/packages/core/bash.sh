#!/bin/sh

PKG_NAME="bash"
PKG_VER="4.2.020"
PKG_REV="1"
PKG_DESC="A sh-compatible shell"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

# the package major version
PKG_MAJOR_VER="$(echo $PKG_VER | cut -f 1-2 -d .)"

# the patch version
PKG_PATCH_VER="$(echo $PKG_VER | cut -f 3 -d .)"

download() {
	# download the sources tarball
	if [ ! -f $PKG_NAME-$PKG_MAJOR_VER.tar.gz ]
	then
		download_file http://ftp.gnu.org/gnu/$PKG_NAME/$PKG_NAME-$PKG_MAJOR_VER.tar.gz
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
			file_name="$PKG_NAME$(echo $PKG_MAJOR_VER | sed s/'\.'//g)"-$i
			[ -f "$file_name" ] && continue
			download_file http://ftp.gnu.org/gnu/$PKG_NAME/$PKG_NAME-$PKG_MAJOR_VER-patches/$file_name
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
	tar -xzvf $PKG_NAME-$PKG_MAJOR_VER.tar.gz
	[ $? -ne 0 ] && return 1

	# extract the patches tarball
	tar -xJvf $PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_MAJOR_VER

	# apply all patches
	for i in $(seq -w $PKG_PATCH_VER)
	do
		file_name="$PKG_NAME$(echo $PKG_MAJOR_VER | sed s/'\.'//g)"-$i
		patch -p0 < ../$PKG_NAME-$PKG_MAJOR_VER.001-$PKG_PATCH_VER/$file_name
		[ $? -ne 0 ] && return 1
	done

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-debugger \
	            --disable-help-builtin \
	            --enable-multibyte \
	            --disable-restricted \
	            --enable-single-help-strings \
	            --disable-mem-scramble \
	            --disable-profiling \
	            --disable-static-link \
	            --without-afs \
	            --without-bash-malloc \
	            --with-curses \
	            --without-installed-readline
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

	# create backwards-compatibility symlinks
	if [ "bin" != "$BIN_DIR" ]
	then
		mkdir $INSTALL_DIR/bin
		[ $? -ne 0 ] && return 1
		ln -s ../$BIN_DIR/bash $INSTALL_DIR/bin/bash
		[ $? -ne 0 ] && return 1
	fi

	if [ "usr/bin" != "$BIN_DIR" ]
	then
		mkdir -p $INSTALL_DIR/usr/bin
		[ $? -ne 0 ] && return 1
		ln -s ../../$BIN_DIR/bash $INSTALL_DIR/usr/bin/bash
		[ $? -ne 0 ] && return 1
	fi

	# install the list of authors
	install -D -m644 AUTHORS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/AUTHORS
	[ $? -ne 0 ] && return 1

	return 0
}
