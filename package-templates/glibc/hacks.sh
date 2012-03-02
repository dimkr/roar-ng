#!/bin/sh

# remove all generated locales
if [ -d ./usr/lib$LIBDIR_SUFFIX/locale ]
then
	echo "    removing generated locales"
	rm -rf ./usr/lib$LIBDIR_SUFFIX/locale/*
fi
