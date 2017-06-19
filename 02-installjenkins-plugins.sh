#!/bin/bash
#
set -ex

obnum=`hostname | cut -c 10- -`
NODE="node00vm0ob$obnum"

# check if ssh is up
while ! ssh $NODE.maas echo
do
    echo "Waiting for sshd on $NODE..."
    sleep 10s
done

scp jenkinsplugin.sh jenkinspluginlist.txt $NODE.maas:./

# install cicd
install_plugins() {
    set -ex
    export DEBIAN_FRONTEND=noninteractive

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for apt lock..."
        sleep 3s
    done

    sudo ./jenkinsplugin.sh --plugins jenkinspluginlist.txt --plugindir /var/lib/jenkins/plugins

    sudo service jenkins restart
}
typeset -f | ssh $NODE.maas "$(cat);install_plugins"
