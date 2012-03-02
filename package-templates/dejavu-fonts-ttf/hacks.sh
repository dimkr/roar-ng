#!/bin/sh

# remove files created by Slackware post-installation script, which uses 
# absolute paths and fails
rm -f fonts.*
