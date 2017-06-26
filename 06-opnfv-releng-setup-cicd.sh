#!/bin/bash
# Author: Fatih E. NAR
# 
obnum=`hostname | cut -c 10- -`
NODE="node00vm0ob$obnum"
# install cicd
releng() {
	cd ~/repos/releng
	git checkout master
	git pull
	git fetch https://gerrit.opnfv.org/gerrit/releng refs/changes/97/35897/1 && git checkout FETCH_HEAD
	git checkout -b joid-daily-jobs
	jenkins-jobs update jjb/global:jjb/joid/joid-daily-jobs.yml:jjb/functest/functest-daily-jobs.yml:jjb/yardstick/yardstick-daily-jobs.yml
}
typeset -f | ssh jenkins@$NODE.maas "$(cat);releng"
