#!/bin/bash
STEAM_USER=${STEAM_USER:-steam}
PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo "Fixing UID and GID .. "
groupmod -o -g "$PGID" ${STEAM_USER}
usermod -o -u "$PUID" ${STEAM_USER}

echo "Fixing ownership .. "
chown -R ${STEAM_USER}:${STEAM_USER} /Steam /arkserver /arkserver-backups

exec su ${STEAM_USER} -c "arkserver.sh"