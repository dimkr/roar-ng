#!/bin/sh

# include the distribution information file
. ../../conf/distrorc

# put the distribution name and version in isolinux.cfg
echo -n "Configuring the boot loader ..."
for i in isolinux.cfg message.txt
do
	sed -e s~DISTRO_NAME~"$DISTRO_NAME"~g \
	    -e s~DISTRO_VERSION~"$DISTRO_VERSION"~g \
	    -e s~DISTRO_NICKNAME~"$DISTRO_NICKNAME"~g \
	    -i $i
done
echo " done"

# generate a color in the syslinux format
echo -n "Generating the boot loader logo ..."
pngtopnm -mix \
         -background white \
         ../rootfs/usr/share/icons/hicolor/256x256/apps/distro.png | \
pnmtoplainpnm | \
ppmtolss16 \#000000=0 \#ffffff=7 > logo.lss 2>/dev/null
echo " done"
