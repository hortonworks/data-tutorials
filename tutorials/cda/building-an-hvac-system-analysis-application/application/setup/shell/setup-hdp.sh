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

su hdfs
echo "Creating /sandbox/sensor/hvac_building and /sandbox/sensor/hvac_machine"
hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/
hdfs dfs -mkdir /sandbox/sensor/hvac_machine
hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/
hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_machine
echo "Checking both directories were created and permissions were set"
hdfs dfs -ls /sandbox/sensor
exit
