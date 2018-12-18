
#!/bin/bash
# This script will install all required stuff to run a BitCore RPC Server.
# BitCore Repo : https://github.com/LIMXTEC/BitCore/
# !! THIS SCRIPT NEED TO RUN AS ROOT !!
######################################################################
# Options and variables
# exit when any command fails
set -e
# keep track and echo an error message before exiting
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT
# Installation starts
clear
echo "*********** Welcome to the BitCore RPC Server Setup Script ***********"
echo 'This script will install all required updates & packages for Ubuntu 16.04 !'
echo 'Create specific user for the rpcserver, set firewall options and add bitcored as a service.'
echo '****************************************************************************'
echo 'Checking OS version.'
if [[ -r /etc/os-release ]]; then
		. /etc/os-release
		if [[ "${VERSION_ID}" != "16.04" ]]; then
			echo "This script only supports ubuntu 16.04 LTS, exiting."
			exit 1
		fi
fi
echo '*** Step 0/10 - User input ***'
echo -n "Enter new password for [bitcore] user and Hit [ENTER]: "
read BTXPASSWORD
echo '*** Step 1/10 - creating bitcore user ***'
adduser --disabled-password --gecos "" bitcore 
usermod -a -G sudo bitcore
echo bitcore:$BTXPASSWORD | chpasswd
echo '*** Done 1/10 ***'
echo '*** Step 2/10 - Allocating 2GB Swapfile ***'
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap /swapfile
swapon /swapfile
chmod 600 /swapfile
echo '*** Done 2/10 ***'
echo '*** Step 3/10 - Running updates and installing required packages ***'
apt-get update -y
apt-get dist-upgrade -y
apt-get install build-essential libtool autotools-dev autoconf automake pkg-config -y \
libssl-dev libboost-all-dev git software-properties-common libminiupnpc-dev libevent-dev ufw -y
add-apt-repository ppa:bitcoin/bitcoin -y
apt-get update -y
apt-get upgrade -y
apt-get install libdb4.8-dev libdb4.8++-dev -y
echo '*** Done 3/10 ***'
echo '*** Step 4/10 - Cloning and Compiling BitCore Wallet ***'
cd
git clone https://github.com/LIMXTEC/BitCore.git
cd BitCore
./autogen.sh
./configure --disable-dependency-tracking --enable-tests=no --without-gui --disable-hardening
make
cd
cd BitCore/src
strip bitcored
cp bitcored /usr/local/bin
strip bitcore-cli
cp bitcore-cli /usr/local/bin
chmod 775 /usr/local/bin/bitcore*
cd
rm -rf BitCore
echo '*** Done 4/10 ***'
echo '*** Step 5/10 - Adding firewall rules ***'
ufw logging on
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 8555/tcp
ufw default deny incoming 
ufw default allow outgoing 
yes | ufw enable
echo '*** Done 5/10 ***'
echo '*** Step 6/10 - Configure bitcore.conf ***'
sudo -u bitcore mkdir /home/bitcore/.bitcore
sudo -u bitcore echo -e "rpcuser=btxrpcnode$(openssl rand -base64 32) \nrpcpassword=$(openssl rand -base64 32) \nrpcallowip=127.0.0.1 \nrpcport=8555 \nserver=1 \nlisten=1 \ndaemon=1 \nlogtimestamps=1 \naddnode=101.109.203.46 \naddnode=103.10.228.137 \naddnode=109.111.1.162 \naddnode=112.201.86.135 \naddnode=175.140.212.205 \naddnode=188.63.72.64 \naddnode=51.15.207.197 \n" > /home/bitcore/.bitcore/bitcore.conf
cd /home/bitcore/.bitcore
echo '*** Done 6/10 ***'
echo '*** Step 7/10 - Adding bitcore daemoon as a service ***'
mkdir /usr/lib/systemd/system
echo -e "[Unit]\nDescription=BitCore's distributed currency daemon\nAfter=network.target\n\n[Service]\nUser=bitcore\nGroup=bitcore\n\nType=forking\nPIDFile=/home/bitcore/.bitcore/bitcored.pid\n\nExecStart=/usr/local/bin/bitcored -daemon -disablewallet -pid=/home/bitcore/.bitcore/bitcored.pid \\n          -conf=/home/bitcore/.bitcore/bitcore.conf -datadir=/home/bitcore/.bitcore/\n\nExecStop=-/usr/local/bin/bitcore-cli -conf=/home/bitcore/.bitcore/bitcore.conf \\n         -datadir=/home/bitcore/.bitcore/ stop\n\nRestart=always\nPrivateTmp=true\nTimeoutStopSec=60s\nTimeoutStartSec=2s\nStartLimitInterval=120s\nStartLimitBurst=5\n\n[Install]\nWantedBy=multi-user.target\n" > /usr/lib/systemd/system/bitcore.service
echo '*** Done 7/10 ***'
echo '*** Step 8/10 - Downloading bootstrap file***'
if [ "$(curl -Is https://bitcore.cc/bootstrap240318.tar.gz | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then
sudo -u bitcore wget https://bitcore.cc/bootstrap240318.tar.gz
sudo -u bitcore tar -xvzf bootstrap240318.tar.gz
sudo -u bitcore rm bootstrap240318.tar.gz
fi
echo '*** Done 8/10 ***'
echo '*** Step 9/10 - Starting BitCore Service ***'
systemctl enable bitcore
systemctl start bitcore
echo 'BitCore Server installed! Weeee!'
echo '*** Done 9/10 ***'
echo '*** Step 10/10 - Wait for wallet synchronization!***'
echo 'To make sure everything working properly you need to reboot server, i advice to wait until wallet synchronization ends.'
echo 'Easiest way to do it, is to catch new block message, where "height=***" is equal to "Current numbers of blocks" in local wallet (help>debug>information)'
sleep 5
echo 'Now go, and visit our telegram channel at t.me/bitcore_cc tell us how its going!'
echo ' '
read -p "Press enter to monitor debug.log"
tail -f debug.log
