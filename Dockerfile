FROM ubuntu:16.04

# Environmental vars. Please do not override these
ENV STEAM_USER steam
ENV STEAM_USER_HOME_DIR /home/${STEAM_USER}
ENV STEAM_ROOT_DIR ${STEAM_USER_HOME_DIR}/Steam
ENV STEAM_SCRIPT ${STEAM_ROOT_DIR}/steamcmd.sh
ENV ARK_ROOT_DIR ${STEAM_USER_HOME_DIR}/arkserver
ENV ARK_BACKUP_DIR ${STEAM_USER_HOME_DIR}/arkserver-backup
ENV ARKSERVER_SCRIPT ${STEAM_USER_HOME_DIR}/arkserver.sh
ENV ARKSERVER_BACKUP_SCRIPT ${STEAM_USER_HOME_DIR}/arkserver-backup.sh

# Overridable environmental vars.
ENV ARK_STEAM_PORT 27015
ENV ARK_GAME_PORT 7777
ENV ARK_GAME_PORT_1 7778
ENV PUID 1000
ENV PGID 1000
ENV ARK_UPDATE true
ENV ARK_BACKUP true
ENV ARK_NO_OF_BACKUPS_TO_KEEP 4
ENV ARK_SERVER_PARAMS TheIsland?listen?SessionName=ARKTEST?MaxPlayers=70?QueryPort=${ARK_STEAM_PORT}?Port=${ARK_GAME_PORT} -server -log

# Copying the entrypoint this early so as to chmod it correctly with the below RUN.
COPY entrypoint.sh /

# Install dependencies, create necessary user and chmod/chown folders.
RUN useradd --no-log-init -s /bin/bash -m -U ${STEAM_USER} && \
    mkdir -p ${STEAM_ROOT_DIR} \
            ${ARK_ROOT_DIR} \
            ${ARK_BACKUP_DIR}  && \
    chmod +x /entrypoint.sh && \
    apt-get update && \
    apt-get install -y lib32gcc1 \
                        curl \
                        bzip2 \
                        gzip \
                        unzip && \
    apt-get -y autoremove && \
    apt-get -y clean

COPY arkserver.sh ${ARKSERVER_SCRIPT}
COPY arkserver-backup.sh ${ARKSERVER_BACKUP_SCRIPT}

# Exposing ports and volumes
EXPOSE ${ARK_STEAM_PORT} ${ARK_GAME_PORT} ${ARK_GAME_PORT_1}
VOLUME ${STEAM_ROOT_DIR} ${ARK_ROOT_DIR} ${ARK_BACKUP_DIR}

ENTRYPOINT ["/entrypoint.sh"]