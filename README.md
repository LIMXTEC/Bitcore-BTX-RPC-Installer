# Bitcore-BTX-RPC-Installer
Docker Compose to running BitCore RPC node

## Allocating 2GB Swapfile
```sh
free -m
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap /swapfile
swapon /swapfile
chmod 600 /swapfile
free -m
```

## VPS Setup

1. Connect to your VPS via SSH 

2. Clone the GitHub

    ```sh
    git clone https://github.com/LIMXTEC/Bitcore-BTX-RPC-Installer.git
    ```

3. Create/Update Masternode information in .env (see example file env)

    ```sh
    EXTERNAL_IP=<IP>
    RPC_USER=<btx_user>
    RPC_PWD=<btx_pwd>
    ```

4. Start your masternode and wait until blockchain is syncronized

    ```sh
    docker-compose up -d
    ```

5. Check if blockchain is synchronised and masternode ready to be activated

    ```sh
    docker exec -it bitcore_rpc bitcore-cli -datadir=/data -conf=/data/bitcore.conf -rpcconnect=172.21.0.11 -rpcuser=btx_user -rpcpassword=btx_pwd -rpcport=8556 mnsync status
    {
      "AssetID": 1,
      "AssetName": "MASTERNODE_SYNC_WAITING",
      "AssetStartTime": 1586727148,
      "Attempt": 0,
      "IsBlockchainSynced": false,
      "IsMasternodeListSynced": false,
      "IsWinnersListSynced": false,
      "IsSynced": false,
      "IsFailed": false
    }

    #WAITING...
    
    docker exec -it bitcore_rpc bitcore-cli -datadir=/data -conf=/data/bitcore.conf -rpcconnect=172.21.0.11 -rpcuser=btx_user -rpcpassword=btx_pwd -rpcport=8556 mnsync status
    {
      "AssetID": 999,
      "AssetName": "MASTERNODE_SYNC_FINISHED",
      "AssetStartTime": 1587319491,
      "Attempt": 0,
      "IsBlockchainSynced": true,
      "IsMasternodeListSynced": true,
      "IsWinnersListSynced": true,
      "IsSynced": true,
      "IsFailed": false
    }
    ```

    PLEASE NOTE: It's very important to wait until IsSynced value is true!

