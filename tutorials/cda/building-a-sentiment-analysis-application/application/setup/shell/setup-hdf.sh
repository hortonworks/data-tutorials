#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Run script in HDF Sandbox CentOS7
# Sets up HDF Dev Environment, so User can focus on NiFi Flow Dev
##

HDF_AMBARI_USER="admin"
HDF_AMBARI_PASS="admin"
HDF_CLUSTER_NAME="Sandbox"
HDF_HOST="sandbox-hdf.hortonworks.com"
HDF="hdf-sandbox"
AMBARI_CREDENTIALS=$HDF_AMBARI_USER:$HDF_AMBARI_PASS

# Ambari REST Call Function: waits on service action completing

# Start Service in Ambari Stack and wait for it
# $1: HDF or HDP
# $2: Service
# $3: Status - STARTED or INSTALLED, but OFF
function wait()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    finished=0
    while [ $finished -ne 1 ]
    do
      ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
      AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
      str=$(curl -s -u $AMBARI_CREDENTIALS $ENDPOINT)
      if [[ $str == *"$3"* ]] || [[ $str == *"Service not found"* ]]
      then
        finished=1
      fi
        sleep 3
    done
  elif [[ $1 == "hdf-sandbox" ]]
  then
    finished=0
    while [ $finished -ne 1 ]
    do
      ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
      AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
      str=$(curl -s -u $AMBARI_CREDENTIALS $ENDPOINT)
      if [[ $str == *"$3"* ]] || [[ $str == *"Service not found"* ]]
      then
        finished=1
      fi
        sleep 3
    done
  else
    echo "ERROR: Didn't Wait for Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Start Service in Ambari Stack and wait for it
# $1: HDF or HDP
# $2: Service
function wait_for_service_to_start()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Start '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDP $2 "STARTED"
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Start '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDF $2 "STARTED"
  else
    echo "ERROR: Didn't Start Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Stop Service in Ambari Stack and wait for it
# $1: HDF or HDP
# $2: Service
function wait_for_service_to_stop()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Stop '"$2"' via REST"},
    "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' $ENDPOINT
    wait $HDP $2 "INSTALLED"
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Stop '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDF $2 "INSTALLED"
  else
    echo "ERROR: Didn't Stop Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

echo "Setting up HDF Sandbox Environment for NiFi flow development..."
echo "Synchronizing CentOS7 System Clock with UTC for GetTwitter Processor"
# Install Network Time Protocol
yum install -y ntp
service ntpd stop
# Use the NTPDATE to synchronize CentOS7 sysclock within few ms of UTC
ntpdate pool.ntp.org
service ntpd start

echo "Cleaning Up NiFi Canvas for NiFi Developer to build Sentiment Analysis Flow..."
echo "Stopping NiFi via Ambari"
#TODO: Check for status code for 400, then resolve issue
# List Services in HDF Stack
# curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X GET http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/
wait_for_service_to_stop $HDF NIFI

echo "Existing flow on NiFi canvas backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak

echo "Starting NiFi via Ambari"
wait_for_service_to_start $HDF NIFI

echo "Starting Kafka in case it is off"
wait_for_service_to_start $HDF KAFKA
echo "Creating and registering Kafka topic 'tweetsSentiment'"
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper sandbox-hdf.hortonworks.com:2181 --replication-factor 1 --partitions 10 --topic tweetsSentiment
