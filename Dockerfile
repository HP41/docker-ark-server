FROM ubuntu:16.04
ENV PATH "/home/steam/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN apt-get update && \ 
    apt-get -y install perl-modules \
                       curl \
                       lsof \
                       libc6-i386 \
                       lib32gcc1 \
                       bzip2 \
                       unzip \
                       vim \
                       sudo && \
    useradd -m steam

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]

WORKDIR /home/steam
VOLUME /home/steam
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh 
USER steam
