FROM debian:8
MAINTAINER Camilo Varela <ing.camilovarela@gmail.com>

# Dependences versions
ENV CURL_VERSION  7.38.0-4+deb8u2
ENV JDK_VERSION   7u75-2.5.4-2
ENV TAR_VERSION   1.27.1-2+b1
ENV UNZIP_VERSION 6.0-16
ENV WGET_VERSION  1.16-1

# Base Libs
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl=$CURL_VERSION \
        tar=$TAR_VERSION \
        lsb-release net-tools netcat

# JavaJRE Installation
RUN apt-get update && \
    apt-get install -y \
        openjdk-7-jre=$JDK_VERSION \
        openjdk-7-jre-headless=$JDK_VERSION
RUN rm -rf /var/lib/apt/lists/*

# Env variables
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
ENV MESOS_NATIVE_JAVA_LIBRARY /opt/marathon/lib

# Scripts copy
COPY inc/install_marathon.sh install_marathon.sh
COPY inc/entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

# Marathon config folder
RUN mkdir -p /etc/marathon/conf

# Marathon installation
RUN sh install_marathon.sh
RUN rm -rf install_marathon.sh

WORKDIR /opt/marathon

ENTRYPOINT ["/entrypoint.sh"]

