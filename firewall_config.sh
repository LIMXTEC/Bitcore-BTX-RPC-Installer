#!/bin/bash
# Copyright (c) 2018 The BitCore BTX Core Developers (dalijolijo)
#set -x

#
# Setup Firewall, install further packages...
#
printf "\nSetup Firewall"
printf "\n--------------\n"

# Configuration for Fedora
if [[ $OS =~ "Fedora" ]] || [[ $OS =~ "fedora" ]] || [[ $OS =~ "CentOS" ]] || [[ $OS =~ "centos" ]]; then
    FIREWALLD=0

    # Check if firewalld is installed
    which firewalld >/dev/null
    if [ $? -eq 0 ]; then
        printf "Found firewall 'firewalld' on your system.\n"
        printf "Automated firewall setup will open the following ports: 22"
        for PORT in "$@"
        do
            printf ", $PORT"
        done
        printf "\nDo you want to start automated firewall setup?\n"
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read FIRECONF

        if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then

            # Firewall settings
            printf "\nSetup firewall...\n"
            firewall-cmd --permanent --zone=public --add-port=22/tcp
            for PORT in "$@"
            do
                firewall-cmd --permanent --zone=public --add-port=${PORT}/tcp
            done
            firewall-cmd --reload
        fi
        FIREWALLD=1
    fi

    if [ $FIREWALLD -ne 1 ]; then

        # Check if ufw is installed
        which ufw >/dev/null
        if [ $? -ne 0 ]; then
            if [[ $OS =~ "CentOS" ]] || [[ $OS =~ "centos" ]]; then
                printf "${RED}Missing firewall (firewalld) on your system.${NO_COL}\n"
                printf "Automated firewall setup will open the following ports: 22"
                for PORT in "$@"
                do
                    printf ", $PORT"
                done
                printf "\nDo you want to install firewall (firewalld) and execute automated firewall setup?\n"
                printf "Enter [Y]es or [N]o and Hit [ENTER]: "
                read FIRECONF

                if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then
                    #Installation of ufw, if not installed yet
                    which ufw >/dev/null
                    if [ $? -ne 0 ];then
                        sudo yum install -y firewalld firewall-config
                        systemctl start firewalld.service
                        systemctl enable firewalld.service
                    fi

                    # Firewall settings
                    printf "\nSetup firewall...\n"
                    firewall-cmd --permanent --zone=public --add-port=22/tcp
                    for PORT in "$@"
                    do
                       firewall-cmd --permanent --zone=public --add-port=${PORT}/tcp
                    done
                    firewall-cmd --reload
                fi
            else
                printf "${RED}Missing firewall (ufw) on your system.${NO_COL}\n"
                printf "Automated firewall setup will open the following ports: 22"
                for PORT in "$@"
                do
                     printf ", $PORT"
                done
                printf "\nDo you want to install firewall (ufw) and execute automated firewall setup?\n"
                printf "Enter [Y]es or [N]o and Hit [ENTER]: "
                read FIRECONF
            fi
        else
            printf "Found firewall 'ufw' on your system.\n"
            printf "Automated firewall setup will open the following ports: 22"
            for PORT in "$@"
            do
                printf ", $PORT"
            done
            printf "\nDo you want to start automated firewall setup?\n"
            printf "Enter [Y]es or [N]o and Hit [ENTER]: "
            read FIRECONF
        fi

        if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then
            #Installation of ufw, if not installed yet
            which ufw >/dev/null
            if [ $? -ne 0 ];then
               sudo yum install -y ufw
            fi

            # Firewall settings
            printf "\nSetup firewall...\n"
            ufw logging on
            ufw allow 22/tcp
            ufw limit 22/tcp
            for PORT in "$@"
            do
                 ufw allow ${PORT}/tcp
            done
            # if other services run on other ports, they will be blocked!
            #ufw default deny incoming
            ufw default allow outgoing
            yes | ufw enable
            ufw reload
        fi
    fi

# Configuration for Ubuntu/Debian/Mint
elif [[ $OS =~ "Ubuntu" ]] || [[ $OS =~ "ubuntu" ]] || [[ $OS =~ "Debian" ]] || [[ $OS =~ "debian" ]] || [[ $OS =~ "Mint" ]] || [[ $OS =~ "mint" ]]; then

    # Check if firewall ufw is installed
    which ufw >/dev/null
    if [ $? -ne 0 ];then
        printf "${RED}Missing firewall (ufw) on your system.${NO_COL}\n"
        printf "Automated firewall setup will open the following ports: 22"
        for PORT in "$@"
        do
            printf ", $PORT"
        done
        printf "\nDo you want to install firewall (ufw) and execute automated firewall setup?\n"
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read FIRECONF
    else
        printf "Found firewall 'ufw' on your system.\n"
        printf "Automated firewall setup will open the following ports: 22"
        for PORT in "$@"
        do
            printf ", $PORT"
        done
        printf "\nDo you want to start automated firewall setup?\n"
        printf "Enter [Y]es or [N]o and Hit [ENTER]: "
        read FIRECONF
    fi

    if [[ $FIRECONF =~ "Y" ]] || [[ $FIRECONF =~ "y" ]]; then
        # Installation of ufw, if not installed yet
        which ufw >/dev/null
        if [ $? -ne 0 ];then
           apt-get update
           sudo apt-get install -y ufw
        fi

        # Firewall settings
        printf "\nSetup firewall...\n"
        ufw logging on
        ufw allow 22/tcp
        ufw limit 22/tcp
        for PORT in "$@"
        do
            ufw allow ${PORT}/tcp
        done
        # if other services run on other ports, they will be blocked!
        #ufw default deny incoming
        ufw default allow outgoing
        yes | ufw enable
        ufw reload
    fi
else
    printf "Automated firewall setup for $OS ($VER) not supported!\n"
    printf "Please open the following firewall ports manually: 22"
    for PORT in "$@"
    do
        printf ", $PORT"
    done
fi
