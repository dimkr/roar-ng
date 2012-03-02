# ~/.bashrc: a startup script for Bash

# set the prompt
if [ 0 -eq "$(id -u)" ]
then
	PS1="[\u@\h \W]# "
else
	PS1="[\u@\h \W]$ "
fi
