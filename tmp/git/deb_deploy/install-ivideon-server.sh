#!/bin/bash
#
# Install Ivideon Video Server

set -eu

REPOS_ADDR="http://packages.ivideon.com/ubuntu"
REPO="ivideon"
TARGET="ivideon-video-server"
NO_GUI_TARGET="ivideon-server-headless"
OPTIONS="thn"
APP="IvideonServer"

usage() {
	echo "Usage: $0 [OPTION]..." 1>&2
	echo "Install ${APP}" 1>&2
	echo "Options:" 1>&2
	echo "    -n    version without graphical interface" 1>&2
	echo "    -t    use testing repository" 1>&2
	echo "    -h    display this help and exit" 1>&2
	exit 1
}

fail_message() {
    local message="$1"
    echo "${message}" 1>&2
    echo "For more information visit http://www.ivideon.com/ivideon-server-linux/" 1>&2
    exit 1
}

is_root() {
	[[ "$(id -u)" = "0" ]] || return 1
}

install_repositories() {
    wget "${REPOS_ADDR}/keys/${REPO}.list" -O "/etc/apt/sources.list.d/${REPO}.list"
    wget -O - "${REPOS_ADDR}/keys/${REPO}.key" | apt-key add -
}

install_videoserver() {
    apt-get -qq update
    apt-get -ym install "${TARGET}"
}

main() {
    while getopts "${OPTIONS}" opt; do
        case "${opt}" in
            "t") REPO="${REPO}-testing" ;;
            "n") TARGET="${NO_GUI_TARGET}" ;;
            "h" | *) usage ;;
        esac
    done

    if ! is_root; then
        fail_message "Administrative privileges is required to run this script."
    fi

    if ! install_repositories; then
        fail_message "Failed to setup ${REPO} APT repository."
    fi

    if install_videoserver; then
        echo "${APP} is succesfully installed."
    else
        fail_message "Failed to install ${APP}."
    fi
}

main "$@"
