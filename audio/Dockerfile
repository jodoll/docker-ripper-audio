FROM ubuntu:noble

# Install dependencies
RUN apt-get update \
  && apt-get upgrade \
  && apt-get install -y \
    lsscsi \
    setcd \
    abcde \
    ccextractor \
    eject \
    eyed3 \
    flac \
    gddrescue \
    glyrc \
    id3 \
    id3v2 \
    lame \
    mkcue \
    python3 \
    python3-docopt \
    python3-flask \
    python3-waitress \
    speex \
    vorbis-tools \
    vorbisgain \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Move Files and set permissions
COPY root/ /
RUN chmod +x /etc/my_init.d/*.sh