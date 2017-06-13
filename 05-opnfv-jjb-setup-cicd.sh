#!/bin/bash
#
obnum=`hostname | cut -c 10- -`
NODE="node00vm1ob$obnum"
# install cicd
jjb() {
	mkdir ~/repos && cd ~/repos
	git clone https://gerrit.opnfv.org/gerrit/releng.git && cd releng
	git fetch https://gerrit.opnfv.org/gerrit/releng refs/changes/95/35895/1 && git checkout FETCH_HEAD
	git checkout -b test-jjb-setup
	cd jjb/releng
	jenkins-jobs update test-jjb-setup.yml
}
typeset -f | ssh jenkins@$NODE.maas "$(cat);jjb"
