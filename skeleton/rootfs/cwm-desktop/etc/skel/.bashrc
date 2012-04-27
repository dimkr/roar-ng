# ~/.bashrc: a startup script for Bash

# set the prompt
if [ 0 -eq "$(id -u)" ]
then
	prompt="#"
else
	prompt="\$"
fi
export PS1="[\u@\h \W]$prompt "
