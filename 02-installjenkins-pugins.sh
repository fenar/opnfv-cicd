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

    while [ ! -z "$(sudo lsof /var/lib/dpkg/lock)" ]
    do
        echo "Waiting for dpkg lock..."
        sleep 3s
    done
    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for apt lock..."
        sleep 3s
    done

    #curl -O https://gist.githubusercontent.com/fenar/2cbfecf435b177edf0ba130ba447927b/raw/3efdfe46cc95fa0e1f95f2b046ee196cad16c146/install_jenkins_plugin.sh && chmod a+x install_jenkins_plugin.sh    
    curl -O https://gist.githubusercontent.com/fenar/2cbfecf435b177edf0ba130ba447927b/raw/3efdfe46cc95fa0e1f95f2b046ee196cad16c146/install_jenkins_plugin.sh && chmod a+x install_jenkins_plugin.sh
    sleep 10s
    ./install_jenkins_plugin.sh -d ./plugins -a description-setter  envinject  build-blocker-plugin  nodelabelparameter  parameterized-trigger  throttle-concurrents
    while [ ! -z "$(sudo lsof /var/lib/dpkg/lock)" ]
    do
        echo "Waiting for dpkg lock..."
        sleep 3s
    done
    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for apt lock..."
        sleep 3s
    done
    sleep 10s
    sudo service jenkins restart
}
typeset -f | ssh $NODE.maas "$(cat);install_plugins"
