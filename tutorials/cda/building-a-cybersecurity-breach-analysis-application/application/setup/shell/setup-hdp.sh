#!/bin/bash

##
# Run script in HDP Sandbox CentOS7
# Sets up HDP Dev Environment, so User can focus on Spark Data Analysis
# 1. Turns off Spark maintenance mode via Ambari
##

# Setup Spark Service on HDP Sandbox:
# Turn off Spark's maintenance mode via Ambari

HDP="hdp-sandbox"
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS

echo "Setting up HDP Sandbox Development Environment"

# TODO: Check that service exists via ambari rest call
# TODO: Check if service is in maintenance mode via ambari rest call
echo "Turning off Spark's maintenance mode via Ambari"
curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
'{"RequestInfo": {"context":"Turn off Maintenance for SPARK"}, "Body":
{"ServiceInfo": {"maintenance_state":"OFF"}}}' \
http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/SPARK2
