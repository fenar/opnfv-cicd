#!/bin/bash
#
set -ex


# configure jumphost for jenkins user
cj() {
    set -ex
    export DEBIAN_FRONTEND=noninteractive

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)"  ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    mkdir ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo "/home/jenkins/.ssh/id_rsa" | ssh-keygen -t rsa
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    mkdir ~/slave_root
    git config --global user.email "fenar@yahoo.com"
    git config --global user.name "fenar"
}
#sshpass -p 'jenkins' ssh jenkins@localhost "$(cat); cj"
typeset -f | ssh jenkins@localhost "$(cat);cj"
