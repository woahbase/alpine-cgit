# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        ca-certificates \
        cgit \
        git \
        lighttpd \
        openssh-server \
        py3-docutils \
        py3-markdown \
        py3-pygments \
    && adduser -h /home/git -D -s /usr/bin/git-shell git users  \
    && passwd -d -u git \
    # ensure lighttpd reads cgit.conf
    && echo 'include "cgit.conf"' >> /etc/lighttpd/lighttpd.conf \
    # cgit expects rst2html as rst2html.py
    && if [ ! -e "/usr/local/bin/rst2html.py" ]; then ln -sf $(which rst2html) /usr/local/bin/rst2html.py; fi \
    # move files to defaults/
    && mkdir -p /defaults \
    && mv /etc/ssh/sshd_config /defaults/sshd_config.default \
    && mv /etc/lighttpd/lighttpd.conf /defaults/lighttpd.conf.default \
    && rm -rf /var/cache/apk/* /tmp/*
#
ENV \
    S6_USER=git \
    CGIT_REPODIR=/home/git/repositories
#
COPY root/ /
#
VOLUME /var/www/ /home/git/
#
EXPOSE 80 22
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider \
    ${HEALTHCHECK_URL:-"http://localhost:80${CGIT_SUBPATH}/?p=about"} \
    || exit 1
#
ENTRYPOINT ["/init"]
