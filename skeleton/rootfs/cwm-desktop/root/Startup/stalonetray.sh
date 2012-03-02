#!/bin/dash

# ~/Startup/stalonetray.sh: a startup script for stalonetray

exec stalonetray --vertical \
                 --transparent \
                 --window-layer bottom \
                 --kludges force_icons_size
