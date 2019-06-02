FROM lsiobase/nginx:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	fcgiwrap \
	mysql-client \
	netcat-openbsd \
	perl-sys-meminfo && \
 apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
	zoneminder

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80
VOLUME /config /data
