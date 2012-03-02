#!/bin/sh

# remove everything except shared libraries
temp_dir="$(mktemp -d)"

for i in $(find . -mindepth 1 -name '*.so*')
do
	mv $i $temp_dir
done

rm -rf ./*
mkdir ./usr
mv $temp_dir ./usr/lib$LIBDIR_SUFFIX