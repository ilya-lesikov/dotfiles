#!/bin/sh -exv


# wait until on-login-mango.desktop is deleted
# while (ls $HOME/.config/autostart/on-login-mango.desktop 2>- 1>-); do
    # sleep 2
# done

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800 
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type suspend 
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false 
gsettings set org.gnome.desktop.session idle-delay 600 

set +e

if [ -x "/tmp/on-login-mango.sh" ]; then
    . /tmp/on-login-mango.sh
fi

<<<<<<< HEAD
killall -9 linphone
sleep 1
linphone &
sleep 1

pkill -f "bin/wineserver"
sleep 1
killall -9 "TeamViewer.exe"
sleep 1
teamviewer &
sleep 1
=======

>>>>>>> dccc971b423f0ec6d25547fbe39447aa31d77f02
iceweasel --private-window "gmail.com" &

set -e

# prevent from running again at start
# rm -f $HOME/.config/autostart/on-login-postconf.desktop
