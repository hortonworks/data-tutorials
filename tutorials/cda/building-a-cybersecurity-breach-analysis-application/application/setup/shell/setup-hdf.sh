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
echo "Creating File Path to GeoLite DB and NASALogs for NiFi"
GEODB_NIFI_DIR="/sandbox/tutorial-files/200/nifi"
mkdir -p $GEODB_NIFI_DIR/input/GeoFile
mkdir -p $GEODB_NIFI_DIR/input/NASALogs
mkdir -p $GEODB_NIFI_DIR/templates
chmod 777 -R $GEODB_NIFI_DIR
echo "Downloading and Extracting GeoLite DB for NiFi"
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
-O $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
tar -zxvf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz \
-C $GEODB_NIFI_DIR/input/GeoFile/
rm -rf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
echo "Downloading and Extracting NASALogs for month of August 1995"
wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Aug95.gz \
-O $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz
gunzip -c $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz \
> $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95
rm -rf $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz

echo "Stopping NiFi via Ambari"
#TODO: Check for status code for 400, then resolve issue
# List Services in HDF Stack
# curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X GET http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Stop NiFi"}, "ServiceInfo": {"state": "INSTALLED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "INSTALLED"

echo "Existing flow on NiFi canvas backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak

echo "Starting NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "STARTED"
