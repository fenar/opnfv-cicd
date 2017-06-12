#!/bin/bash
#
set -ex

obnum=`hostname | cut -c 10- -`
NODE="node00vm1ob$obnum"

# check if ssh is up
while ! ssh $NODE.maas echo
do
    echo "Waiting for sshd on $NODE..."
    sleep 10s
done

# install cicd
install_plugins() {
    set -ex
    export DEBIAN_FRONTEND=noninteractive

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for apt lock..."
        sleep 3s
    done

    curl -O https://gist.githubusercontent.com/hoesler/ed289c9c7f18190b2411e3f2286e23c3/raw/f6da774fe06eaf0e761133618d37968b5a3e5f27/install_jenkins_plugin.sh && chmod a+x install_jenkins_plugin.sh
    # curl -O https://gist.githubusercontent.com/micw/e80d739c6099078ce0f3/raw/33a21226b9938382c1a6aa68bc71105a774b374b/install_jenkins_plugin.sh && chmod a+x install_jenkins_plugins.sh
    #mkdir ./plugins
    sudo ./install_jenkins_plugin.sh -a description-setter@1.10  envinject@2.1  build-blocker-plugin@1.7.3  nodelabelparameter@1.7.2  parameterized-trigger@2.33  throttle-concurrents@2.0.1
    # cd /home/ubuntu/plugins && sudo cp -R * /var/lib/jenkins/plugins
    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for apt lock..."
        sleep 3s
    done

    sleep 10s

    sudo service jenkins restart
}
typeset -f | ssh $NODE.maas "$(cat);install_plugins"
