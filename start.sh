#!/bin/bash
set -u

CONFIG=${CONFIG_PATH}/bitcore.conf
CONFIG_REUSE=${CONFIG_PATH}/.bitcore.conf

#
# Downloading bitcore.conf
#
cd /tmp/
wget https://raw.githubusercontent.com/LIMXTEC/Bitcore-BTX-RPC-Installer/master/bitcore.conf -O /tmp/bitcore.conf
chown bitcore:bitcore /tmp/bitcore.conf

#
# Configure bitcore.conf
#
printf "** Configure bitcore.conf ***\n"
mkdir -p ${CONFIG_PATH}	
chown -R bitcore:bitcore /home/bitcore/

if [ -f ${CONFIG_REUSE} ] ; then
	sudo -u bitcore mv ${CONFIG_REUSE} ${CONFIG}
else
	sudo -u bitcore cp /tmp/bitcore.conf ${CONFIG}
	sed -i "s#^\(rpcuser=\).*#rpcuser=btxrpcnode$(openssl rand -base64 32 | tr -d '[:punct:]')#g" ${CONFIG}
	sed -i "s#^\(rpcpassword=\).*#rpcpassword=$(openssl rand -base64 32 | tr -d '[:punct:]')#g" ${CONFIG}
	RPC_ALLOWIP=$(ip addr | grep 'global eth0' | xargs | cut -f2 -d ' ')
	sed -i "s#^\(rpcallowip=\).*#rpcallowip=${RPC_ALLOWIP}#g" ${CONFIG}
fi

#
# Downloading bootstrap file
#
printf "** Downloading bootstrap file ***\n"
cd ${CONFIG_PATH}
if [ ! -d ${CONFIG_PATH}/blocks ] && [ "$(curl -Is https://${WEB}/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitcore wget https://${WEB}/${BOOTSTRAP}; \
        sudo -u bitcore tar -xvzf ${BOOTSTRAP}; \
        sudo -u bitcore rm ${BOOTSTRAP}; \
fi

#
# Starting BitCore Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Starting BitCore Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
