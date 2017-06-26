#!/bin/bash
# Author: Fatih E. NAR
# 
obnum=`hostname | cut -c 10- -`
mkdir ~/repos && cd ~/repos
git clone https://gerrit.opnfv.org/gerrit/joid.git && cd joid
git checkout stable/danube
mkdir -p labconfig/vzw/"v4n-$obnum"
vi labconfig/vzw/"v4n-$obnum"/labconfig.yml
git add -A .
git commit -m 'add vzw v4n-$obnum config'
