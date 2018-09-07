#!/bin/bash

##
# Run script in HDF Sandbox CentOS7
# Sets up HDF Dev Environment, so User can focus on NiFi Flow Dev
# 1. Creates GeoFile directory and download in GeoFile DB
# 2. Backup existing NiFi flow on canvas
# 3. Uploads and Imports New NiFi flow onto canvas via NiFi Rest API
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

echo "Setting up HDF Sandbox Environment for NiFi flow development..."
echo "Downloading GeoLite DB for NiFi"
GEODB_NIFI_DIR="/sandbox/tutorial-files/200/nifi"
mkdir -p $GEODB_NIFI_DIR/input/GeoFile $GEODB_NIFI_DIR/templates
chmod 777 -R $GEODB_NIFI_DIR
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
-O $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
tar -zxvf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz \
-C $GEODB_NIFI_DIR/input/GeoFile/

echo "Stopping NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Stop NiFi"}, "ServiceInfo": {"state": "INSTALLED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "INSTALLED"

echo "Existing flow on NiFi canvas backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak
echo "Downloading NiFi WebServerLogs.xml Template and Importing NiFi flow"
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/cf9f67737c3f1677b595673fc685670b44d9890f/tutorials/hdp/hdp-2.5/refine-and-visualize-server-log-data/assets/WebServerLogs.xml \
-O $GEODB_NIFI_DIR/templates/WebServerLogs.xml
gzip $GEODB_NIFI_DIR/templates/WebServerLogs.xml
cp -f $GEODB_NIFI_DIR/templates/WebServerLogs.xml.gz /var/lib/nifi/conf/flow.xml.gz

echo "Starting NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "STARTED"
