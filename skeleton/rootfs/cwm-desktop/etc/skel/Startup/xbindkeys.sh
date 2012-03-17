#!/bin/dash

# ~/Startup/xbindkeys.sh: a startup script for XBindKeys

[ ! -f ~/.xbindkeysrc ] && xbindkeys --defaults > ~/.xbindkeysrc
exec xbindkeys