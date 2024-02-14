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
    && echo 'include "cgit.conf"' >> /etc/lighttpd/lighttpd.conf \
    && adduser -h /home/git -D -s /usr/bin/git-shell git users  \
    && passwd -d -u git \
    # cgit expects rst2html as rst2html.py
    && ln -sf $(which rst2html) /usr/local/bin/rst2html.py \
    && rm -rf /var/cache/apk/* /tmp/*
#
ENV S6_USER=git
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
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:80/git/"} || exit 1
#
ENTRYPOINT ["/init"]
