FROM ubuntu:16.04
# Install dependencies, create necessary user and chmod/chown folders.
RUN apt-get update && \
    apt-get install -y lib32gcc1 \
                        curl \
                        bzip2 \
                        gzip \
                        unzip && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    curl -LO https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb && \
    dpkg -i dumb-init_*.deb && \
    useradd --no-log-init -s /bin/bash -m -U steam && \
    mkdir -p /Steam /arkserver /arkserver-backups

COPY bin/ /usr/bin    
VOLUME /Steam /arkserver /arkserver-backups

ENTRYPOINT ["/usr/bin/dumb-init", "--", "entrypoint.sh"]