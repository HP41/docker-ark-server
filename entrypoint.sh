#!/bin/bash

ARK_SERVER_USER=${ARK_SERVER_USER:-"arkserver"}
ARK_SERVER_USER_HOME_DIR=${ARK_SERVER_USER_HOME_DIR:-"/home/${ARK_SERVER_USER}"}
ARK_SERVER_ROOT_DIR=${ARK_SERVER_ROOT_DIR:-"${ARK_SERVER_USER_HOME_DIR}/arkserver"}
ARK_SERVER_SCRIPT=${ARK_SERVER_SCRIPT:-"${ARK_SERVER_ROOT_DIR}/arkserver"}
ARK_SERVER_BACKUP_DIR=${ARK_SERVER_BACKUP_DIR:-"${ARK_SERVER_USER_HOME_DIR}/arkserver-backup"}
ARK_SERVER_LGSM_COMMON_CONFIG=${ARK_SERVER_LGSM_COMMON_CONFIG:-"${ARK_SERVER_ROOT_DIR}/lgsm/config-lgsm/arkserver/common.cfg"}

# chown-ing to ensure any user mounted volumes under these dirs are owned properly.
chown -R ${ARK_SERVER_USER}:${ARK_SERVER_USER} ${ARK_SERVER_ROOT_DIR} \
                                                ${ARK_SERVER_BACKUP_DIR}

# Simply running the LinuxGSM scripts to initialize the proper folders.
su ${ARK_SERVER_USER} -c "${ARK_SERVER_SCRIPT}"

# Adding the backupdir config if not present.
if ! grep -q "backupdir=${ARK_SERVER_BACKUP_DIR}" ${ARK_SERVER_LGSM_COMMON_CONFIG}; then
    echo "'backupdir' config not found at ${ARK_SERVER_LGSM_COMMON_CONFIG}, adding 'backupdir=${ARK_SERVER_BACKUP_DIR}' to it"
    echo "backupdir=${ARK_SERVER_BACKUP_DIR}" >> ${ARK_SERVER_LGSM_COMMON_CONFIG}
fi

# If serverfiles exists, the game has been downloaded.
if [[ -d "$ARK_SERVER_ROOT_DIR/serverfiles" ]]; then
    echo "Previous Ark server installation detected, performing a backup and an update"
    su ${ARK_SERVER_USER} -c "${ARK_SERVER_SCRIPT} backup"
    su ${ARK_SERVER_USER} -c "${ARK_SERVER_SCRIPT} update"
else 
    echo "No previous installations found, installing..."
    su ${ARK_SERVER_USER} -c "${ARK_SERVER_SCRIPT} auto-install"
fi

# https://github.com/GameServerManagers/LinuxGSM/wiki/debug
echo "Start the server in debug mode therefore not killing the container"
su ${ARK_SERVER_USER} -c "yes | ${ARK_SERVER_SCRIPT} debug"