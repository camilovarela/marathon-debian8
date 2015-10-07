#!/bin/sh

# Setup
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Add the repository
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update

# Mesos dependences
sudo apt-get -y install mesos

cd /opt
curl -O http://downloads.mesosphere.com/marathon/v0.10.0/marathon-0.10.0.tgz
tar xzf marathon-0.10.0.tgz
mv marathon-0.10.0 marathon
rm -Rf marathon-0.10.0.tgz
mkdir /opt/marathon/lib

