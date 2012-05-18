#!/bin/sh

# include the distribution information file
. ./etc/distrorc

############
# branding #
############

# create /etc/hostname
echo -n "$DISTRO_NICKNAME" > ./etc/hostname

# add the machine itself to the hosts file
echo "127.0.0.1	$DISTRO_NICKNAME	localhost" >> ./etc/hosts

# replace DISTRO_NAME and DISTRO_VERSION with their values
echo "  creating /etc/motd and /etc/issue"
for i in issue motd
do
	sed -e s~DISTRO_NAME~"$DISTRO_NAME"~g \
	    -e s~DISTRO_VERSION~"$DISTRO_VERSION"~g \
	    -i ./etc/$i
done

#######################
# library directories #
#######################

# for 64-bit architectures, add lib64
case $DISTRO_ARCH in
	*64)
		for directory in $(cat ./etc/ld.so.conf)
		do
			mkdir -p .${directory}64
			sed -i s~"^$directory$"~"${directory}64\n$directory"~ \
			       ./etc/ld.so.conf
		done
		;;
esac

# set the libraries directory in rc.update
. ../../skeleton/devx/package_tools/etc/buildpkgrc
sed -i s~'LIB_DIR'~"/$LIB_DIR"~g ./etc/rc.d/rc.update

###################
# /dev population #
###################

echo "  populating /dev"

# create crucial device nodes
mknod -m 0622 ./dev/console c 5 1
mknod -m 666 ./dev/null c 1 3
mknod -m 666 ./dev/zero c 1 5
mkdir ./dev/pts ./dev/shm

# create loop devices
for n in `seq 0 7`
do
	mknod -m 664 ./dev/loop$n b 7 $n
done

# create virtual console devices
for n in `seq 0 9`
do
	mknod -m 666 ./dev/tty$n c 4 $n
done

# create input, output and error output pipes
ln -s /proc/self/fd/2 ./dev/stderr
ln -s /proc/self/fd/1 ./dev/stdin
ln -s /proc/self/fd/0 ./dev/stdout
