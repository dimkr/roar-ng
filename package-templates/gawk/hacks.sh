#!/bin/sh

# create /usr/bin/awk, a symlink to gawk 
[ ! -e ./usr/bin/awk ] && ln -s gawk ./usr/bin/awk
