#!/bin/bash

echo "cd-ing into ${STEAM_ROOT_DIR}"
cd ${STEAM_ROOT_DIR}

if [[ ! -f ${STEAM_SCRIPT} ]] && [[ ! -x ${STEAM_SCRIPT} ]]; then
    echo "Downloading Steam from https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz and un-tar-ing it"
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

    echo "Ensuring ${STEAM_SCRIPT} is executable"
    chmod +x ${STEAM_SCRIPT}
fi

echo "Downloading ARK Server and ensuring it's updated"
${STEAM_SCRIPT} +login anonymous +force_install_dir "${ARK_ROOT_DIR}" +app_update 376030 validate +quit

echo "Starting Ark server [[ ${ARK_ROOT_DIR}/ShooterGameServer ${ARK_SERVER_PARAMS} ]] "
${ARK_ROOT_DIR}/ShooterGame/Binaries/Linux/ShooterGameServer ${ARK_SERVER_PARAMS}