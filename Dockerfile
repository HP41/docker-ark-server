FROM ubuntu:16.04
RUN apt-get update && \ 
    apt-get -y install perl-modules curl lsof libc6-i386 lib32gcc1 bzip2 unzip vim sudo && \
    useradd -m steam  
ENV TINI_VERSION v0.15.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

USER steam
WORKDIR /home/steam
ENV PATH "/home/steam/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
VOLUME /home/steam
CMD ["arkmanager", "run"]
