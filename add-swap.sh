#!/bin/bash

free -m
#Add 8GB swap file
dd if=/dev/zero of=/swapfile bs=1M count=8192
mkswap /swapfile
swapon /swapfile
chmod 600 /swapfile
free -m
