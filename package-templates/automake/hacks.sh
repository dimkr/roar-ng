#!/bin/sh

# create symlinks to automake and aclocal
cd ./usr/bin
[ ! -e automake ] && ln -s automake-* automake
[ ! -e aclocal ] && ln -s aclocal-* aclocal
