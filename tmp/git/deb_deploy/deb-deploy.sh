#!/bin/sh -e

homeDirs="$(ls -d -i /home/*)"
usrList="$(grep -E ":[0-9]{4,6}:[0-9]{4,6}:" "/etc/passwd" |\
    grep -vi "nobody" |\
    cut -d: -f1)"
gitDir="/tmp/deb_deploy"
dirName="$(dirname "$0")" # MAGIC for correct source imports
# tempDir="$(mktemp -d /tmp/deb-dep.XXXX)"
# border="################################################################################"

###########################
# helper functions
###########################
pressEnt() {
    printf "%s\n" "Press Enter to continue"
    read Enter
}

prompt() {
    printf "%s\n" "${1:-"Unspecified message"} [${2}]"
}

infoMsg() {
    printf "%s\n" "${1:-"Unspecified message"}"
}

warnPrompt() {
    printf "%s\n" "<WARNING> ${1:-"Unspecified warning"}"
    pressEnt
}

errMsg() {
    printf "%s\n" "<ERROR> ${1:-"Unspecified error"} Abort" 1>&2
    exit 1
}

###########################
# getoptions
###########################
case $@ in
    --help) 
        printf "%s\n" "-d    Activate debug mode"
        exit
        ;;
    -d)
        set -x
        set -v
        ;;
esac

###########################
# prepare
###########################
cd $dirName
. $dirName/install.lib.sh

chkRoot
chkPlatf
prepEnv

###########################
# prompts
###########################

until [ "$chRootPass" = "y" ] || [ "$chRootPass" = "n" ]; do
    prompt "Change root password?" "Y/n"
    read chRootPass
done

until [ "$addGuest" = "y" ] || [ "$addGuest" = "n" ]; do
    prompt "Create guest user?" "Y/n"
    read addGuest
done

until [ "$addMoreUsers" = "y" ] || [ "$addMoreUsers" = "n" ]; do
    prompt "Create more than one user (except guest)?" "y/N"
    read addMoreUsers
done

until [ "$instBasicSys" = "y" ] || [ "$instBasicSys" = "n" ]; do
    prompt "Install basic system?" "Y/n"
    read instBasicSys
done

until [ "$instSudo" = "y" ] || [ "$instSudo" = "n" ]; do
    prompt "Install sudo?" "y/N"
    read instSudo
done

until [ "$instWine" = "y" ] || [ "$instWine" = "n" ]; do
    prompt "Install wine?" "Y/n"
    read instWine
done

until [ "$instWineScr" = "y" ] || [ "$instWineScr" = "n" ]; do
    prompt "Install wine scripts (restrict access)?" "Y/n"
    read instWineScr
done

# until [ "$instWineMang" = "y" ] || [ "$instWineMang" = "n" ]; do
    # prompt "Install wine Mango-Office?" "Y/n"
    # read instWineMang
# done

until [ "$postUserCfg" = "y" ] || [ "$postUserCfg" = "n" ]; do
    prompt "Perform post-configuration for each user?" "Y/n"
    read postUserCfg
done

###########################
# installing
###########################

if [ "$chRootPass" = "y" ]; then
    chRootPass
fi

if [ "$addGuest" = "y" ]; then
    addGuest
fi

if [ "$addMoreUsers" = "y" ]; then
    addMoreUsers
fi

if [ "$instBasicSys" = "y" ]; then
    preBaseInst &&\
    aptBaseInst &&\
    manBaseInst &&\
    postBaseInst
fi

if [ "$instSudo" = "y" ]; then
    instSudo
fi

if [ "$instWine" = "y" ]; then
    if [ "$instWineScr" = "n" ]; then
        instWineWoScr
        # if instWineWoScr && [ "$instWineMang" = "y" ]; then
            # instWineMang
        # fi
    else
        instWineWScr
        # if instWineWScr && [ "$instWineMang" = "y" ]; then
            # instWineMang
        # fi
    fi
fi

if [ "$postUserCfg" = "y" ]; then
    postUserCfg 
    # mkUsrLoginScr
fi

infoMsg "deb-deploy.sh completed successfully"
