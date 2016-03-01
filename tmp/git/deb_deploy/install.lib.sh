chkRoot() {
    if [ "$USER" != "root" ]; then
        errMsg "Run it as root."
    fi
}

chkPlatf() {
    if [ "i686" != "$(uname -m)" ]; then
        errMsg "Platforms other than x86 are not supported atm."
    fi
}

prepEnv() {
    cp ./on-login*.sh ../
    chmod 777 ../on-login*.sh
}

chRootPass() {
    until (passwd); do
        infoMsg "Root password change failed. Press Enter to repeat, or S + Enter to skip."
        read key
        if [ "$key" = "s" ] || [ "$key" = "S" ]; then
            break
        fi
    done
}

addGuest() {
    until (adduser guest); do
        infoMsg "Adding guest failed. Press Enter to repeat, or S + Enter to skip."
        read key
        if [ "$key" = "s" ] || [ "$key" = "S" ]; then
            break
        fi
    done
}

addMoreUsers() {
    while true; do
        infoMsg "Enter the new user name and press Enter. To skip the step press S + Enter."
        read newUserName
        if [ "$newUserName" = "s" ] || [ "$newUserName" = "S" ]; then
            break
        fi
        set +e
        adduser $newUserName
        set -e
    done
}

preBaseInst() {
    # add google chrome repository
    if (grep -r 'linux/chrome' "/etc/apt/sources.list*" 2>- 1>-); then
        infoMsg "sources.list* already contains Google Chrome repository"
    else 
        echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list 
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - 
    fi

    apt-get update 
    apt-get -fy install
    APT_LISTCHANGES_FRONTEND="none" apt-get -y upgrade
}

aptBaseInst() {
    apt-get -y install vlc htop linphone openssh-server flashplugin-nonfree \
    openssh-client openssh-server curl firmware-realtek google-chrome-stable \
    apt-file putty vim-gnome remmina 
}

manBaseInst() {
    # dpkg manual installation
    if ! [ -f "./teamviewer_i386.deb" ]; then
        wget "http://download.teamviewer.com/download/version_10x/teamviewer_i386.deb" 
    fi

    if ! [ -f "./ipscan_3.4_i386.deb" ]; then
        wget "http://github.com/angryziber/ipscan/releases/download/3.4/ipscan_3.4_i386.deb" 
    fi

    if ! [ -f "./IvideonClient_6.1.3.deb" ]; then
        wget "http://downloads-cdn77.iv-cdn.com/bundles/client/IvideonClient_6.1.3.deb"
    fi

    dpkg --force-depends -i ./*.deb

    apt-get --force-yes install libqt54-ivideon 

    # install ivideon-server via script
    if ! [ -f "./install-ivideon-server.sh" ]; then
        wget http://downloads-cdn77.iv-cdn.com/bundles/server/install-ivideon-server.sh
    fi

    chmod +x ./install-ivideon-server.sh
    ./install-ivideon-server.sh
}

postBaseInst() {
    # resolve dependencies and clean
    apt-get -fy install 
    # apt-get autoremove 
    apt-file update 
}

instSudo() {
    apt-get -y install sudo
    for i in $usrList; do
        adduser $i sudo
    done
}

instWineWoScr() {
    # install wine without scripts (full access)
    apt-get -y install wine
    mkdir -p /tmp/content
    warnPrompt "User input required. Press Enter to continue."
    until (scp -r user1@deb51.local:/home/user1/content/Mango-Call-Center.exe /tmp/content/Mango-Call-Center.exe); do
        infoMsg "Copy from deb51 failed. Press Enter to repeat, or S + Enter to skip."
        read key
        if [ "$key" = "s" ] || [ "$key" = "S" ]; then
            break
        fi
    done
    chmod -R 777 /tmp/content/
}

instWineWScr() {
    # install wine with scripts
    warnPrompt "User input required. Press Enter to continue."
    until (scp -r user1@deb51.local:/home/user1/content/ /tmp/); do
        infoMsg "Copy from deb51 failed. Press Enter to repeat, or S + Enter to skip."
        read key
        if [ "$key" = "s" ] || [ "$key" = "S" ]; then
            break
        fi
    done
    chmod -R 777 /tmp/content/
    # TODO
    /tmp/content/prepare.sh -f
}

# instWineMang() {
    # for i in $usrList; do
        # autostartDir="/home/$i/.config/autostart"
        # mkdir -p $autostartDir
        # # rm -rf $autostartDir/on-login-mango.desktop
# cat <<- EOF > $autostartDir/on-login-mango.desktop
# [Desktop Entry]
# Name=onloginmango
# Exec=$gitDir/../on-login-mango.sh
# Terminal=true
# Type=Application
# EOF
        # chown -R $i:$i "$autostartDir"
    # done
# }

postUserCfg() {
    for i in $usrList; do
        if ! (grep "export PATH=" "/home/$i/.bashrc" 2>- 1>-); then
            echo "export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr:/usr/games:/usr/local/games" \
                >> /home/$i/.bashrc 
        fi
    done
}

# mkUsrLoginScr() {
    # for i in $usrList; do
        # autostartDir="/home/$i/.config/autostart"
        # mkdir -p $autostartDir
        # # rm -rf $autostartDir/on-login-postconf.desktop
# cat <<- EOF > $autostartDir/on-login-postconf.desktop
# [Desktop Entry]
# Name=onloginpostconf
# Exec=$gitDir/../on-login-postconf.sh
# Terminal=true
# Type=Application
# EOF
        # chown -R $i:$i "$autostartDir"
    # done
# }

