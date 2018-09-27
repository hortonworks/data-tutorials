#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Script sets up HDP services used in Building an HVAC System Analysis Application
# Author: James Medel
# Email: jamesmedel94@gmail.com
##
echo "Setting Up HDP Dev Environment for HVAC System Analysis App"

# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users
mkdir -p /var/log/cda-sb/310/
setup_hdfs()
{
  su hdfs
  echo "INFO: Creating /sandbox/sensor/hvac_building and /sandbox/sensor/hvac_machine"
  hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/
  hdfs dfs -mkdir /sandbox/sensor/hvac_machine
  hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/
  hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_machine
  echo "INFO: Checking both directories were created and permissions were set"
  hdfs dfs -ls /sandbox/sensor
  exit
}
# Log everything, but also output to stdout
setup_hdfs 2>&1 | tee -a /var/log/cda-sb/310/setup-hdp.log
