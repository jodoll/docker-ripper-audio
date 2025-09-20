FROM ubuntu:noble

# Install dependencies
RUN apt-get update \
  && apt-get upgrade -y \
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
    speex \
    vorbis-tools \
    vorbisgain \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Move Files and set permissions
COPY root/ /
RUN chmod +x /etc/my_init.d/*.sh

CMD [ "/etc/my_init.d/ripper.sh" ]