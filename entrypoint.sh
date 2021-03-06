#!/bin/bash
AST_VERSION="${AST_VERSION:-v1.6.33}"
CONFIG_BOOTSTRAP_DIR=/bootstrap
declare -A CONFIG_PATHS;CONFIG_PATHS[".arkmanager.cfg"]="/home/steam/.arkmanager.cfg"
                        CONFIG_PATHS["main.cfg"]="/home/steam/.config/arkmanager/instances/main.cfg"
                        CONFIG_PATHS["GameUserSettings.ini"]="/home/steam/ARK/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"
                        CONFIG_PATHS["Game.ini"]="/home/steam/ARK/ShooterGame/Saved/Config/LinuxServer/Game.ini"
                        CONFIG_PATHS["Engine.ini"]="/home/steam/ARK/ShooterGame/Saved/LinuxServer/Engine.ini"

isASTInstalled() {
    [ "$(which arkmanager)" = "/home/steam/bin/arkmanager" ]
}

isASTVersionSameAs() {
    local version=$1
    echo "${version}" | grep -q "^v$(arkmanager --version | grep Version | awk '{print $2}')"
}

installAST() {
    local version=$1
    local tempdir=$(mktemp -d)

    if [ -z "${tempdir}" ]; then
        >&2 echo "ERROR: Couldn't create temp directory"
        exit 1
    fi

    cd "${tempdir}"
    curl -LO https://github.com/FezVrasta/ark-server-tools/archive/${version}.zip
    unzip "${version}.zip"
    cd ark-server-tools-*/tools
    ./install.sh --me
    cd ~steam && rm -rf "${tempdir}"
}

bootstrapConfig() {
    local bootstrap_dir=$1
    local dest_path=
    for file in $(find ${bootstrap_dir} -maxdepth 1 -type f); do
        dest_path="${CONFIG_PATHS[$(basename "$file")]}"
        ([ -f "${file}" ] && [ -n "${dest_path}" ]) || continue
        mkdir -p $(dirname ${dest_path})
        cp ${file} ${dest_path}
        ls -al $file
        ls -al $dest_path
    done
}

isARKInstalled() {
    [ -f "/home/steam/ARK/steamapps/appmanifest_376030.acf" ]
}

mustBeSteamUser() {
    if [ $(whoami) != 'steam' ]; then
        >2& echo "ERROR: Must run as steam user."
        exit 1
    fi
}

areModsInstalled() {
    ! arkmanager getpid 2>1 | grep -q 'install this mod'
}

checkForUpdates() {
    mustBeSteamUser
    arkmanager update --saveworld --update-mods --verbose --no-autostart --backup
}

trapSignals() {
    ripInPeace() {
      echo "Initializing graceful termination."
      arkmanager stop --saveworld
      exit 0
    }
    trap ripInPeace INT TERM
}

arkManager() {
    mustBeSteamUser

    if ! (isASTInstalled && isASTVersionSameAs "${AST_VERSION}"); then
        installAST "${AST_VERSION}"
    fi

    if [ -d "${CONFIG_BOOTSTRAP_DIR}" ]; then
        bootstrapConfig "${CONFIG_BOOTSTRAP_DIR}"
    fi

    if ! isARKInstalled; then
        arkmanager install --verbose
        checkForUpdates
    fi

    if ! areModsInstalled; then
        arkmanager installmods --verbose
    fi

    if [ -n "$1" ]; then
      echo "Executing: arkmanager $@"
      trapSignals
      arkmanager $@ &
      wait "$!"
    else
      echo "No arkmanager command. Idling indefinitely."
      sleep infinity
    fi
}

main() {
    case $1 in
    doUpdate)
        checkForUpdates
        ;;
    bash)
        exec /bin/bash
        ;;
    *)
        arkManager $@
        ;;
    esac
}

main $@
