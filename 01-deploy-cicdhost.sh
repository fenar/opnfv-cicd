#!/bin/bash
#
set -ex

obnum=`hostname | cut -c 10- -`
NODE="node00vm1ob$obnum"


# deploy node on maas
maas admin machines allocate name=$NODE
NODE_ID=$(maas admin nodes read hostname=$NODE | python -c "import sys, json;print json.load(sys.stdin)[0]['system_id']")
maas admin machine deploy "$NODE_ID"

# wait till the machine is up
while [ "$(maas admin nodes read hostname=$NODE | python -c "import sys, json;print json.load(sys.stdin)[0]['status_name']")" != "Deployed" ]
do
    echo "Waiting for ready on $NODE..."
    sleep 10s
done

# check if ssh is up
while ! ssh $NODE.maas echo
do
    echo "Waiting for sshd on $NODE..."
    sleep 10s
done

# copy over the used ssh-keypair
scp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub $NODE.maas:.ssh/

# install cicd
install_cicd() {
    set -ex
    export DEBIAN_FRONTEND=noninteractive

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)"  ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    while [ ! -z "$(sudo lsof /var/lib/dpkg/lists/lock)"  ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sudo apt-get update

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sudo -E apt-get install -y git python openjdk-8-jre 

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    curl https://bootstrap.pypa.io/get-pip.py | sudo python

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sudo pip install jenkins-job-builder 

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    git config --global user.email "fenar@yahoo.com"
    git config --global user.name "fenar"
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sleep 10s
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sleep 10s

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sudo apt-get update

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sudo apt-get install -y jenkins bash zip

    while [ ! -z "$(sudo lsof /var/lib/apt/lists/lock)" ]
    do
        echo "Waiting for dpkg/apt lock..."
        sleep 3s
    done
    sleep 10s

    #sudo adduser jenkins --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo "jenkins:jenkins" | sudo chpasswd
    sudo usermod -aG sudo jenkins

    password=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
    echo "Password: $password" 
}
typeset -f | ssh $NODE.maas "$(cat);install_cicd"
