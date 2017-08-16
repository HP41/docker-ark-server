#!/bin/bash
AST_VERSION="${AST_VERSION:-v1.6.33}"
CONFIG_BOOTSTRAP_DIR=/bootstrap
declare -A CONFIG_PATHS;CONFIG_PATHS[".arkmanager.cfg"]="~/.arkmanager.cfg"
                        CONFIG_PATHS["main.cfg"]="~/.config/arkmanager/instances/main.cfg"
                        CONFIG_PATHS["GameUserSetings.ini"]="~/ARK/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"

isASTInstalled() {
    [ $(which arkmanager) == "/home/user/steam/bin/arkmanager" ]
}

isASTVersionSameAs() {
    local version=$1
    [ $version =~  ^$(arkmanager --version | grep Version | awk '{print $2}') ]
}

installAST() {
    local version=$1
    local tempdir=$(mktemp -d)
    
    if [ -z "${tempdir}" ]; then
        2>& echo "ERROR: Couldn't create temp directory"
        exit 1
    fi

    cd "${tempdir}"
    curl -LO https://github.com/FezVrasta/ark-server-tools/archive/${AST_VERSION}.tar.gz | tar xvzf -
    cd ark-server-tools-*
    ./install.sh --me
    cd ~steam && rm -rf "${tempdir}"
}

bootstrapConfig() {
    # todo: lol    
}

main() {
    if [ $(whoami) != 'steam' ]; then
        2>& echo "ERROR: Must run as steam user."
    fi

    if [ ! isASTInstalled ] || [ ! isASTVersionSameAs "${AST_VERSION}" ]; then
        installAST "${AST_VERSION}"
    fi

    bootstrapConfig

    if [ ! isARKInstalled ]; then
        arkmanager install --verbose
        arkmanager update --verbose
        arkmanager updatemods --verbose
    fi

    exec arkserver start
}