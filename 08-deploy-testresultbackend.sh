#!/bin/bash
#
# CICD TestResult Backend Deployment Kick-Starter
# Author:Fatih E. Nar (fenar)
#
model=`juju list-models |awk '{print $1}'|grep testbckdb`

if [[ ${model:0:9} == "testbckdb" ]]; then
	juju switch testbckdb
     	juju deploy testbckdb.yaml
else
	juju add-model testbckdb
	juju switch testbckdb
     	juju deploy testbckdb.yaml
fi

echo "Login to the juju-gui to see status or use juju status"
juju gui --no-browser --show-credentials
