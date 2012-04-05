#!/bin/sh

PKG_NAME="linux"
PKG_VER="3.0.27"
PKG_REV="1"
PKG_DESC="A monolithic kernel"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

# the major version
PKG_MAJOR_VER="$(echo $PKG_VER | cut -f 1-2 -d .)"

# the Aufs tarball name
AUFS_TARBALL_NAME="aufs3-$PKG_MAJOR_VER-git$(date +%d%m%Y)"

download() {
	# download the sources tarball
	if [ ! -f $PKG_NAME-$PKG_VER.tar.xz ]
	then
		download_file http://www.kernel.org/pub/linux/kernel/v$PKG_MAJOR_VER/$PKG_NAME-$PKG_VER.tar.xz
		[ $? -ne 0 ] && return 1
	fi

	# download the Aufs sources
	if [ ! -f $AUFS_TARBALL_NAME.tar.xz ]
	then
		# download the sources
		git clone --depth 1 git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git $AUFS_TARBALL_NAME
		[ $? -ne 0 ] && return 1

		# switch to the matching branch
		cd $AUFS_TARBALL_NAME
		git checkout origin/aufs$PKG_MAJOR_VER
		[ $? -ne 0 ] && return 1
		cd ..

		# create a sources tarball
		tar -c $AUFS_TARBALL_NAME | xz -9 > $AUFS_TARBALL_NAME.tar.xz
		[ $? -ne 0 ] && return 1

		# clean up
		rm -rf $AUFS_TARBALL_NAME
		[ $? -ne 0 ] && return 1
	fi

	return 0
}

build() {
	# extract the sources
	tar -xJvf $PKG_NAME-$PKG_VER.tar.xz
	[ $? -ne 0 ] && return 1

	# extract the Aufs sources
	tar -xJvf $AUFS_TARBALL_NAME.tar.xz
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# clean the kernel sources
	make clean
	[ $? -ne 0 ] && return 1
	make mrproper
	[ $? -ne 0 ] && return 1

	# apply the Aufs patches
	for patch in kbuild base proc_map
	do
		patch -p1 < ../$AUFS_TARBALL_NAME/aufs3-$patch.patch
		[ $? -ne 0 ] && return 1
	done

	# add the Aufs files
	for directory in fs Documentation
	do
		cp -r ../$AUFS_TARBALL_NAME/$directory .
		[ $? -ne 0 ] && return 1
	done

	# add the Aufs header
	cp ../$AUFS_TARBALL_NAME/include/linux/aufs_type.h \
	   include/linux
	[ $? -ne 0 ] && return 1

	# reset the minor version number, so the package is backwards-compatible
	# with previous bug-fix versions
	sed -i s/'^SUBLEVEL = .*'/'SUBLEVEL ='/ Makefile
	[ $? -ne 0 ] && return 1

	# reduce the kernel verbosity to make the boot sequence quiet
	sed -i s~'DEFAULT_CONSOLE_LOGLEVEL 7'~'DEFAULT_CONSOLE_LOGLEVEL 3'~ kernel/printk.c
	[ $? -ne 0 ] && return 1

	# add the configuration
	cp ../$PKG_NAME-config-$PKG_ARCH .config
	[ $? -ne 0 ] && return 1

	# build the kernel image and the modules
	make -j $BUILD_THREADS bzImage modules
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the kernel image
	install -D -m644 arch/$PKG_ARCH/boot/bzImage \
	                 $INSTALL_DIR/boot/vmlinuz
	[ $? -ne 0 ] && return 1

	# install System.map, required to generate module dependency files
	install -D -m644 System.map $INSTALL_DIR/boot/System.map
	[ $? -ne 0 ] && return 1

	# install the kernel modules
	make INSTALL_MOD_PATH=$INSTALL_DIR modules_install
	[ $? -ne 0 ] && return 1

	# remove the module dependency files
	rm -f $INSTALL_DIR/lib/modules/$PKG_MAJOR_VER/modules.*
	[ $? -ne 0 ] && return 1

	# create a symlink to the modules directory, named after the real kernel
	# version
	ln -s $PKG_MAJOR_VER $INSTALL_DIR/lib/modules/$PKG_VER
	[ $? -ne 0 ] && return 1

	# fix the symlinks to the kernel sources
	for i in build source
	do
		rm -f $INSTALL_DIR/lib/modules/$PKG_MAJOR_VER/$i
		[ $? -ne 0 ] && return 1
		ln -s ../../../usr/src/$PKG_NAME \
		      $INSTALL_DIR/lib/modules/$PKG_MAJOR_VER/$i
		[ $? -ne 0 ] && return 1
	done

	# install the kernel API headers
	make INSTALL_HDR_PATH=$INSTALL_DIR/$BASE_INSTALL_PREFIX headers_install
	[ $? -ne 0 ] && return 1

	# remove unneeded files from the kernel headers installation
	find $INSTALL_DIR/$BASE_INSTALL_PREFIX -name .install -or \
	                                       -name ..install.cmd | xargs rm -f
	[ $? -ne 0 ] && return 1

	# install the license, the list of authors and the list of maintainers
	install -D -m644 COPYING $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/COPYING
	[ $? -ne 0 ] && return 1
	install -D -m644 CREDITS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/CREDITS
	[ $? -ne 0 ] && return 1
	install -D -m644 MAINTAINERS $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/MAINTAINERS
	[ $? -ne 0 ] && return 1

	return 0
}
