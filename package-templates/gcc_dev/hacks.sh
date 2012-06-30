#!/bin/sh

# keep everything except shared libraries
for i in $(find . -mindepth 1 -type f -or -type l)
do
	case $i in
		*.so*)
			rm -f $i
			;;
	esac
done
