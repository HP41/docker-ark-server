#!/bin/bash
SESSION_MAP=${SESSION_MAP:-"TheIsland"}
SESSION_MAX_PLAYERS=${SESSION_MAX_PLAYERS:-"70"}
STEAMCMD_LINUX_TAR=${STEAMCMD_LINUX_TAR:-"https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"}

STEAM_DIR=/Steam
ARK_DIR=/arkserver

if [[ "$(whoami)" != "steam" ]]; then
    echo "ERROR: Must be run as the steam user!"
    exit 1
fi

if [[ -n "${SERVER_PARAMS}" ]]; then
    echo "WARNING: Overridden server params. SESSION_MAP, and SESSION_MAX_PLAYERS will be discarded."
else 
    SERVER_PARAMS="${SESSION_MAP}?listen?MaxPlayers=${SESSION_MAX_PLAYERS} -server -log"
fi

cd ${STEAM_DIR}
if [[ ! -x steamcmd.sh ]]; then
    curl -sqL "${STEAMCMD_LINUX_TAR}" | tar zxvf -
    chmod +x steamcmd.sh
fi

echo "Downloading ARK Server and ensuring it's updated.."
./steamcmd.sh +login anonymous +force_install_dir ${ARK_DIR} +app_update 376030 validate +quit

echo "Starting Ark server [[ ${SERVER_PARAMS} ]] "
exec ${ARK_DIR}/ShooterGame/Binaries/Linux/ShooterGameServer ${SERVER_PARAMS}
