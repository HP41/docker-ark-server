FROM ubuntu:16.04

# Environmental vars.
ENV ARK_SERVER_USER arkserver
ENV ARK_SERVER_USER_HOME_DIR /home/${ARK_SERVER_USER}
ENV ARK_SERVER_ROOT_DIR ${ARK_SERVER_USER_HOME_DIR}/arkserver
ENV ARK_SERVER_LGSM_SCRIPT_FILE_NAME linuxgsm.sh
ENV ARK_SERVER_LGSM_SCRIPT_URL https://gameservermanagers.com/dl/${ARK_SERVER_LGSM_SCRIPT_FILE_NAME}
ENV ARK_SERVER_LGSM_SCRIPT=${ARK_SERVER_ROOT_DIR}/${ARK_SERVER_LGSM_SCRIPT_FILE_NAME}
ENV ARK_SERVER_SCRIPT=${ARK_SERVER_ROOT_DIR}/arkserver
ENV ARK_SERVER_BACKUP_DIR ${ARK_SERVER_USER_HOME_DIR}/arkserver-backup

# Copying the entrypoint this early so as to chmod it correctly with the below RUN.
COPY entrypoint.sh /

# Install dependencies, create necessary user and chmod/chown folders.
RUN useradd --no-log-init -s /bin/bash -m ${ARK_SERVER_USER} && \
    mkdir -p ${ARK_SERVER_ROOT_DIR} \
            ${ARK_SERVER_BACKUP_DIR} && \
    chown -R ${ARK_SERVER_USER}:${ARK_SERVER_USER} ${ARK_SERVER_ROOT_DIR} \
                                                    ${ARK_SERVER_BACKUP_DIR} && \
    chmod -R 744 ${ARK_SERVER_ROOT_DIR} \
                ${ARK_SERVER_BACKUP_DIR} && \
    chmod 755 /entrypoint.sh && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y mailutils \
                        postfix \
                        curl \
                        wget \
                        binutils \
                        file \
                        bzip2 \
                        gzip \
                        unzip \
                        bsdmainutils \
                        python \
                        util-linux \
                        ca-certificates \
                        tmux \
                        lib32gcc1 \
                        libstdc++6 \
                        libstdc++6:i386 && \
    apt-get -y autoremove && \
    apt-get -y clean

# Running linuxgsm.sh script will create the arkserver script in PWD and therefore we've to cd into the necessary dir.
WORKDIR ${ARK_SERVER_ROOT_DIR}

# Switch to arkserver user just to install arkserver script as it won't allow it under root.
USER ${ARK_SERVER_USER}

# Downloading linuxgsm.sh and installing the arkserver script.
RUN wget -N --no-check-certificate ${ARK_SERVER_LGSM_SCRIPT_URL} && \
    chmod 755 ${ARK_SERVER_LGSM_SCRIPT} && \
    ${ARK_SERVER_LGSM_SCRIPT} arkserver

# Switching back as we need root privileges for entrypoint.sh 
USER root

# Exposing ports and volumes
EXPOSE 27015/udp 7777/udp 7778/udp
VOLUME ${ARK_SERVER_ROOT_DIR} ${ARK_SERVER_BACKUP_DIR}

ENTRYPOINT ["/entrypoint.sh"]

# Health check
HEALTHCHECK --interval=5m \
  CMD ${ARK_SERVER_SCRIPT} monitor || exit 1