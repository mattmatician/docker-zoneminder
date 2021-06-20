FROM ghcr.io/linuxserver/baseimage-ubuntu:focal as buildstage
############## build stage ##############

ARG ZONEMINDER_VERSION=1.36.4

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    cmake \
    libjpeg-turbo8-dev \
    libssl-dev \
    libmysqlclient-dev \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libavfilter-dev \
    libavdevice-dev \
    libswresample-dev \
    libswscale-dev \
    pkg-config \
    libwww-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libdate-manip-perl \
    libsys-mmap-perl \
    libpolkit-agent-1-dev \
    libcurl4-openssl-dev \
    libvncserver-dev \
    libvlc-dev \
    libjwt-gnutls-dev

RUN \
 echo "**** build zoneminder ****" && \
 git clone --depth 1 https://github.com/ZoneMinder/ZoneMinder -b ${ZONEMINDER_VERSION} /tmp/zoneminder && \
 cd /tmp/zoneminder && \
 git submodule update --init --recursive

RUN \
  mkdir -p /tmp/zoneminder/build && \
  cd /tmp/zoneminder/build && \
  cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DZM_CGIDIR=/usr/lib/zoneminder/cgi-bin \
    -DZM_CONFIG_DIR=/config/zm \
    -DZM_CONTENTDIR=/app/content \
    -DZM_LOGDIR=/app/log \
    -DZM_PATH_ARP=/usr/sbin/arp \
    -DZM_WEBDIR=/usr/share/zoneminder/www \
    -DZM_FONTDIR=/usr/share/zoneminder/fonts \
    -DZM_WEB_GROUP=abc \
    -DZM_WEB_USER=abc \
    -DZM_DB_HOST=mysql \
    .. && \
  make && \
  make DESTDIR=/tmp/zoneminder-build install

############## runtime stage ##############
FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Mattmatician version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mattmatician"

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    net-tools \
    apache2 \
    mysql-client \
    php \
    libapache2-mod-php \
    php-mysql \
    curl \
    libjpeg-turbo8 \
    libssl1.1 \
    libmysqlclient21 \
    ffmpeg \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libavfilter7 \
    libavdevice58 \
    libswresample3 \
    libswscale5 \
    libwww-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libdata-entropy-perl \
    libdate-manip-perl \
    libdigest-bcrypt-perl \
    libsys-mmap-perl \
    libsys-meminfo-perl \
    libpolkit-agent-1-0 \
    libcurl4 \
    libvncserver1 \
    libvlc5 \
    vlc-plugin-base \
    vlc-plugin-video-output \
    libjwt-gnutls0

# Run Apache2 as abc user
RUN \
  sed -i 's/www-data/abc/g' /etc/apache2/envvars

# copy buildstage and local files
COPY --from=buildstage /tmp/zoneminder-build/ /
COPY --from=buildstage /tmp/zoneminder/build/misc/apache.conf /etc/apache2/conf-available/zoneminder.conf
COPY root/ /

# Enable Apache2 modules and confs
RUN \
  a2enmod php7.4 cgi rewrite expires headers && \
  a2enconf zoneminder

# Workaround to fix CSS
RUN \
  ln -sf ../../../fonts /usr/share/zoneminder/www/skins/classic/css && \
  ln -sf ../../../skins /usr/share/zoneminder/www/skins/classic/css

# ports and volumes
EXPOSE 80
VOLUME /config /app
