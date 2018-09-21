#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Run script in HDP Sandbox CentOS7
# Sets up HDP Dev Environment, so User can focus on Spark Data Analysis
# 1. Turns off Spark maintenance mode via Ambari
##

# Setup Spark Service on HDP Sandbox:
# Turn off Spark's maintenance mode via Ambari

HDP="hdp-sandbox"
HDP_AMBARI_USER="$1" # $1: Expects user to pass "Ambari User" into the file
HDP_AMBARI_PASS="$2" # $2: Expects user to pass "Ambari Admin Password" into the file
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS

echo "Setting up HDP Sandbox Development Environment"
tee -a /etc/resolv.conf << EOF
# Google's Public DNS
nameserver 8.8.8.8
EOF

echo "Create Directory for Zeppelin Notebooks"
mkdir -p /sandbox/tutorial-files/200/zeppelin/notebooks/
chmod -R 777 /sandbox/tutorial-files/200/zeppelin/notebooks/

echo "Create /sandbox/tutorial-files/200/nifi/"
echo "Allow read-write-execute permissions to any user, temp solution for nifi"
# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users

su hdfs
hdfs dfs -mkdir -p /sandbox/tutorial-files/200/nifi/
hdfs dfs -chmod -R 777 /sandbox/tutorial-files/200/nifi/
exit

# TODO: Check that service exists via ambari rest call
# TODO: Check if service is in maintenance mode via ambari rest call
echo "Turning off Spark's maintenance mode via Ambari"
curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
'{"RequestInfo": {"context":"Turn off Maintenance for SPARK"}, "Body":
{"ServiceInfo": {"maintenance_state":"OFF"}}}' \
http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/SPARK2
