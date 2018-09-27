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
DATE=`date '+%Y-%m-%d %H:%M:%S'`
echo "Setting Up HDP Dev Environment for HVAC System Analysis App"

# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users
mkdir -p /var/log/cda-sb/310/
setup_hdfs()
{
  echo "$DATE INFO: Creating /sandbox/sensor/hvac_building and /sandbox/sensor/hvac_machine"
  sudo -u hdfs hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/
  sudo -u hdfs hdfs dfs -mkdir /sandbox/sensor/hvac_machine
  echo "$DATE INFO: Setting permissions for hvac_buildnig and hvac_machine to 777"
  sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/
  sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_machine
  echo "$DATE INFO: Checking both directories were created and permissions were set"
  sudo -u hdfs hdfs dfs -ls /sandbox/sensor
}
# Log everything, but also output to stdout
echo "$DATE INFO: Executing setup_hdfs bash function, logging to /var/log/cda-sb/310/setup-hdp.log"
setup_hdfs | tee -a /var/log/cda-sb/310/setup-hdp.log
