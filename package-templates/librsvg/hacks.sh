#!/bin/sh

# remove the SVG viewer, rsvg and the GTK+ theme
rm -rf ./usr/bin/rsvg \
       ./usr/bin/rsvg-view \
       $(find . -name man -type d) \
       ./usr/share/pixmaps \
       ./usr/share/themes
