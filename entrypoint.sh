#!/bin/bash

echo "Modifying \"${STEAM_USER}\" group to ensure it has the right GID \"${PGID}\""
groupmod -o -g "$PGID" ${STEAM_USER}

echo "Modifying \"${STEAM_USER}\" user to ensure it has the right UID \"${PUID}\""
usermod -o -u "$PUID" ${STEAM_USER}

echo "Now the right UID:GID has been set, chown-ing and chmod-ing the appropriate dirs"
chown -R ${STEAM_USER}:${STEAM_USER} ${STEAM_ROOT_DIR} \
                                    ${ARK_ROOT_DIR} \
                                    ${ARK_BACKUP_DIR}

chmod -R 744 ${STEAM_ROOT_DIR} \
            ${ARK_ROOT_DIR} \
            ${ARK_BACKUP_DIR} && \

chmod +x ${ARKSERVER_SCRIPT} \
        ${ARKSERVER_BACKUP_SCRIPT}

echo "Starting Ark Server Script (${ARKSERVER_SCRIPT}) as ${STEAM_USER}"

su ${STEAM_USER} -c "${ARKSERVER_SCRIPT}"