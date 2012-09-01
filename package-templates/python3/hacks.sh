#!/bin/sh

# create /usr/bin/python3, if it doesn't exist
cd ./usr/bin
[ ! -e python3 ] && ln -s python3.[0-9] python3
