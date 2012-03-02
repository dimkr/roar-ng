#!/bin/sh

# ensure /usr/share/pkgconfig is a directory
if [ -e ./usr/share/pkgconfig ]
then
	rm -rf ./usr/share/pkgconfig
	mkdir -p ./usr/share/pkgconfig
fi
