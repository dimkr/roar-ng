#!/bin/sh

# create /usr/bin/locate, a symlink to mlocate 
[ ! -e ./usr/bin/locate ] && ln -s mlocate ./usr/bin/locate

# create /usr/bin/updatedatedb, a symlink to updatedb.mlocate
if [ ! -e ./usr/bin/updatedb ] && [ -e ./usr/bin/updatedb.mlocate ]
then
	ln -s updatedb.mlocate ./usr/bin/updatedb
fi
