#!/bin/sh -xv

wine /usr/lib/i386-linux-gnu/wine/bin/content/Mango-Call-Center.exe /verysilent /lang=ru

# HACK 
# kill mango and create gnome shortcut with installing mango again
sleep 7
killall -9 mpoint.exe
sleep 3
wine /usr/lib/i386-linux-gnu/wine/bin/content/Mango-Call-Center.exe /verysilent /lang=ru

# # prevent from running again at start
# rm -f $HOME/.config/autostart/on-login-mango.desktop
