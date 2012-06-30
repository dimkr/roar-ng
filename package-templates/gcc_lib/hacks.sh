#!/bin/sh

# remove everything except shared libraries
for i in $(find . -mindepth 1 -type f -or -type l)
do
	case $i in
		*.so*)
			;;
		*)
			rm -rf $i
			;;
	esac
done
