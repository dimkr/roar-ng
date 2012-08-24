#!/bin/sh

# on 64-bit systems, link /usr/lib/locale to /usr/lib64/locale
if [ -d ./usr/lib64/locale ] && [ ! -e ./usr/lib/locale ]
then
	ln -s ../lib64/locale ./usr/lib/locale
fi

# remove all generated locales
if [ -e ./usr/lib/locale ]
then
	echo "    removing generated locales"
	rm -rf ./usr/lib/locale/*
fi
