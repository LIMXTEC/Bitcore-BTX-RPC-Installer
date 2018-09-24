# Bitcore-BTX-RPC-Installer
## OPTION 1: Installation with script 
This script will install all required stuff to run a BitCore RPC Server.

Just 2 simple Steps and your Server is done!

***Only working for Linux Ubuntu 16.04 LTS***

### Download and start the script
Login as root, then do:

```
wget https://raw.githubusercontent.com/dArkjON/Bitcore-BTX-RPC-Installer/master/btxsetup.sh
chmod +x btxsetup.sh
./btxsetup.sh
```

To enable firewall, you have to manually reboot server when blockchain is fully loaded!

Its loaded when "height" in message:

```2018-03-24 21:58:33 UpdateTip: new best=0e18856d9315caa4e58045ec1581686de9076b916f2c791920aefad29fde6bd9 height=156975 version=0x20000000 log2_work=61.420326 tx=751075 date='2018-03-24 21:55:04' progress=0.877860 cache=10.7MiB(5039tx)```

Will be equal to "Current numbers of blocks" in local wallet (GUI - Help > Debug > Information).

### Switch User in Terminal
After install you can use `su bitcore` to switch the user and with `bitcore-cli getinfo` you will get all info.


## OPTION 2: Deploy as a docker container

Support for the following distribution versions:
* CentOS 7.4 (x86_64-centos-7)
* Fedora 26 (x86_64-fedora-26)
* Fedora 27 (x86_64-fedora-27) - tested
* Fedora 28 (x86_64-fedora-28) - tested
* Debian 7 (x86_64-debian-wheezy)
* Debian 8 (x86_64-debian-jessie) - tested
* Debian 9 (x86_64-debian-stretch) - tested
* Debian 10 (x86_64-debian-buster) - tested
* Ubuntu 14.04 LTS (x86_64-ubuntu-trusty) - tested
* Ubuntu 16.04 LTS (x86_64-ubuntu-xenial) - tested
* Ubuntu 17.10 (x86_64-ubuntu-artful)
* Ubuntu 18.04 LTS (x86_64-ubuntu-bionic) - tested

### Download and execute the docker-ce installation script

Download and execute the automated docker-ce installation script - maintained by the Docker project.

```
sudo curl -sSL https://get.docker.com | sh
```

### Download and execute the script
Login as root, then do:

```
sudo bash -c "$(curl -fsSL https://github.com/limxtec/Bitcore-BTX-RPC-Installer/raw/master/btx-docker.sh)"
```

### For more details to docker related stuff have a look at:
* Bitcore-BTX-RPC-Installer/BUILD_README.md
* Bitcore-BTX-RPC-Installer/RUN_README.md


## Useful Stuff

To generate a Account-Wallet just use : `bitcore getnewaddress <accoutname>`

Your config file is located in `cd /home/bitcore/.bitcore/bitcore.conf`

After changing rpcuser & rpcpassword please restart the bitcore server.


## **Visit us at [Telegram](https://t.me/bitcore_btx_official) // Special Thanks to : [wfthkttn](https://github.com/wfthkttn)**

Fork Source : https://github.com/dArkjON/BSD-Masternode-Setup-1604
