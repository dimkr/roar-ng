#!/bin/sh

# the character maps to keep
REQUIRED_CHARMAPS="iso-8859-15.txt iso-8859-1.txt koi8-r.txt mac-roman.txt
                   iso-8859-16.txt iso-8859-2.txt koi8-u.txt"

# remove all unwanted character maps
echo "    removing unwanted character maps"
for charmap in ./usr/share/cups/charmaps/*
do
	keep=0
	for required_charmap in $REQUIRED_CHARMAPS
	do
		case "$charmap" in
			*/$required_charmap)
				keep=1
				break
				;;
		esac
	done

	[ 1 -eq $keep ] && continue
	rm -f "$charmap"
done

echo "    removing unneeded documentation"
for i in ./usr/share/cups/templates/*
do
	[ -d $i ] && rm -rf $i
done
