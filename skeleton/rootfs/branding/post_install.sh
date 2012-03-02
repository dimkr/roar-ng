#!/bin/sh

# generate PNG logos
for size in 16 24 32 48 64 96 256
do
	rsvg-convert -h $size -w $size \
				 -o ./usr/share/icons/hicolor/${size}x$size/apps/distro.png \
				 ./usr/share/icons/hicolor/scalable/apps/distro.svg
done

# create a symlink to the 48x48 logo under /usr/share/pixmaps
ln -s ../icons/hicolor/48x48/apps/distro.png ./usr/share/pixmaps/distro.png