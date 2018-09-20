#!/bin/bash

##
# Script sets up HDP services used in Building an HVAC System Analysis Application
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users

su hdfs
hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/ /sandbox/sensor/hvac_machine
hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/ /sandbox/sensor/hvac_machine
exit
