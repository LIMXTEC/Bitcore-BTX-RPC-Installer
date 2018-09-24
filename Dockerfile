# BitCore RPC Server - Dockerfile (04-2018)
#
# This Dockerfile will install all required stuff to run a BitCore RPC Server and is based on script btxsetup.sh (see: https://github.com/dArkjON/Bitcore-BTX-RPC-Installer/blob/master/btxsetup.sh)
# BitCore Repo : https://github.com/LIMXTEC/BitCore/
# E-Mail: info@bitcore.cc
# 
# To build a docker image for btx-rpc-server from the Dockerfile the bitcore.conf is also needed.
# See BUILD_README.md for further steps.

# Use an official Ubuntu runtime as a parent image
FROM ubuntu:16.04

LABEL maintainer="Jon D. (dArkjON), David B. (dalijolijo)"
LABEL version="0.15.2.0.0"

# Make ports available to the world outside this container
# DefaultPort = 8555
# RPCPort = 8556
# TorPort = 9051
# DEPRECATED: Use 'docker run -p 8555:8555 -p 8556:8556 -p 9051:9051 ...'
#EXPOSE 8555 8556 9051

USER root

# Change sh to bash
SHELL ["/bin/bash", "-c"]

# Define environment variable
ENV BTXPWD "bitcore"

RUN echo '*** BitCore BTX RPC Server ***'

#
# Creating bitcore user
#
RUN echo '*** Creating bitcore user ***' && \
    adduser --disabled-password --gecos "" bitcore && \
    usermod -a -G sudo,bitcore bitcore && \
    echo bitcore:$BTXPWD | chpasswd

#
# Running updates and installing required packages
#
RUN echo '*** Running updates and installing required packages ***' && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y  apt-utils \
                        autoconf \
                        automake \
                        autotools-dev \
                        build-essential \
                        curl \
                        git \
                        libboost-all-dev \
                        libevent-dev \
                        libminiupnpc-dev \
                        libssl-dev \
                        libtool \
                        libzmq5-dev \
                        pkg-config \
                        software-properties-common \
                        sudo \
                        supervisor \
                        vim \
                        wget && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y  libdb4.8-dev \
                        libdb4.8++-dev

#
# Cloning and Compiling BitCore Wallet
#
RUN echo '*** Cloning and Compiling BitCore Wallet ***' && \
    cd && \
    echo "Execute a git clone of LIMXTEC/BitCore. Please wait..." && \
    git clone https://github.com/LIMXTEC/BitCore.git && \
    cd BitCore && \
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --enable-tests=no --without-gui --disable-hardening && \
    make && \
    cd && \
    cd BitCore/src && \
    strip bitcored && \
    cp bitcored /usr/local/bin && \
    strip bitcore-cli && \
    cp bitcore-cli /usr/local/bin && \
    chmod 775 /usr/local/bin/bitcore* && \
    cd && \
    rm -rf BitCore

#
# Configure bitcore.conf	
#	
COPY bitcore.conf /tmp	
RUN echo '*** Configure bitcore.conf ***' && \	
    chown bitcore:bitcore /tmp/bitcore.conf && \	
    sudo -u bitcore mkdir -p /home/bitcore/.bitcore && \	
    sudo -u bitcore cp /tmp/bitcore.conf /home/bitcore/.bitcore/bitcore.conf

#
# Copy Supervisor Configuration
#
COPY *.sv.conf /etc/supervisor/conf.d/

#
# Logging outside docker container
#
VOLUME /var/log

#
# Copy start script
#
RUN echo '*** Copy start script ***'
COPY start.sh /usr/local/bin/start.sh
RUN rm -f /var/log/access.log && mkfifo -m 0666 /var/log/access.log && \
    chmod 755 /usr/local/bin/*

ENV TERM linux
CMD ["/usr/local/bin/start.sh"]
