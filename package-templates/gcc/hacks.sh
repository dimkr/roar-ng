#!/bin/sh

# create /usr/bin/cc, a symlink to GCC
[ ! -e ./usr/bin/cc ] && ln -s gcc ./usr/bin/cc
