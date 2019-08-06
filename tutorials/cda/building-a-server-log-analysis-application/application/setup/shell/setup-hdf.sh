#!/bin/bash

##
# Sets up HDF Dev Environment, so User can focus on NiFi Flow Dev
# 1. Creates GeoFile directory and download in GeoFile DB
# 2. Backup existing NiFi flow on canvas
# 3. Uploads and Imports New NiFi flow onto canvas via NiFi Rest API
##
DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/200"
mkdir -p $LOG_DIR_BASE/hdf

setup_public_dns()
{
  echo "$DATE INFO: Adding Google Public DNS to /etc/resolve.conf"
  echo "# Google Public DNS" | tee -a /etc/resolve.conf
  echo "nameserver 8.8.8.8" | tee -a /etc/resolve.conf

  echo "$DATE INFO: Checking Google Public DNS added to /etc/resolve.conf"
  cat /etc/resolve.conf

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_public_dns() bash function, logging to $LOG_DIR_BASE/hdf/setup-public-dns.log"
}
setup_nifi()
{
  echo "$DATE INFO: Setting Up HDF Dev Environment for Server Log Analysis App"
  echo "$DATE INFO: Setting HDF_AMBARI_USER based on user input"
  HDF_AMBARI_USER="$1" # $1: Expects user to pass "Ambari User" into the file
  echo "$DATE INFO: Setting HDF_AMBARI_PASS based on user input"
  HDF_AMBARI_PASS="$2" # $2: Expects user to pass "Ambari Admin Password" into the file
  HDF_CLUSTER_NAME="Sandbox"
  HDF_HOST="sandbox-hdf.hortonworks.com"
  HDF="hdf-sandbox"
  AMBARI_CREDENTIALS=$HDF_AMBARI_USER:$HDF_AMBARI_PASS
  # Ambari REST Call Function: waits on service action completing

  # Start Service in Ambari Stack and wait for it
  # $1: HDF or HDP
  # $2: Service
  # $3: Status - STARTED or INSTALLED, but OFF
  wait()
  {
    if [[ $1 == "hdp-sandbox" ]]
    then
      finished=0
      while [ $finished -ne 1 ]
      do
        echo "$DATE INFO: Waiting for $1 $2 service action to finish"
        ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
        AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
        str=$(curl -s -u $AMBARI_CREDENTIALS $ENDPOINT)
        if [[ $str == *"$3"* ]] || [[ $str == *"Service not found"* ]]
        then
          echo "$DATE INFO: $1 $2 service state is now $3"
          finished=1
        fi
          echo "$DATE INFO: Still waiting on $1 $2 service action to finish"
          sleep 3
      done
    elif [[ $1 == "hdf-sandbox" ]]
    then
      finished=0
      while [ $finished -ne 1 ]
      do
        echo "$DATE INFO: Waiting for $1 $2 service action to finish"
        ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
        AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
        str=$(curl -s -u $AMBARI_CREDENTIALS $ENDPOINT)
        if [[ $str == *"$3"* ]] || [[ $str == *"Service not found"* ]]
        then
          echo "$DATE INFO: $1 $2 service state is now $3"
          finished=1
        fi
          echo "$DATE INFO: Still waiting on $1 $2 service action to finish"
          sleep 3
      done
    else
      echo "$DATE ERROR: Didn't Wait for Service, need to choose appropriate sandbox HDF or HDP"
    fi
  }

  echo "$DATE INFO: Creating File Path to GeoLite DB and NASALogs for HDF NiFi"
  GEODB_NIFI_DIR="/sandbox/tutorial-files/200/nifi"
  mkdir -p $GEODB_NIFI_DIR/input/GeoFile
  mkdir -p $GEODB_NIFI_DIR/input/NASALogs
  mkdir -p $GEODB_NIFI_DIR/templates
  chmod 777 -R $GEODB_NIFI_DIR
  echo "$DATE INFO: Downloading and Extracting GeoLite DB for NiFi to /sandbox/tutorial-files/200/nifi/input/GeoFile/"
  wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
  -O $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
  tar -zxvf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz \
  -C $GEODB_NIFI_DIR/input/GeoFile/
  echo "$DATE INFO: Removing GeoLite DB tar.gz file from /sandbox/tutorial-files/200/nifi/input/GeoFile/"
  rm -rf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
  echo "$DATE INFO: Downloading and Extracting NASALogs Aug1995 to /sandbox/tutorial-files/200/nifi/input/NASALogs/"
  wget ftp://ita.ee.lbl.gov/traces/NASA_access_log_Aug95.gz \
  -O $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz
  gunzip -c $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz \
  > $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95
  echo "$DATE INFO: Removing NASALogs gz file from /sandbox/tutorial-files/200/nifi/input/NASALogs/"
  rm -rf $GEODB_NIFI_DIR/input/NASALogs/NASA_access_log_Aug95.gz

  echo "$DATE INFO: Cleaning Up NiFi Canvas for NiFi Developer to build Cybersecurity Breach Analysis Flow..."
  echo "$DATE INFO: Stopping HDF NiFi Service via Ambari REST Call"
  #TODO: Check for status code for 400, then resolve issue
  # List Services in HDF Stack
  # curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X GET http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/
  curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
  {"context": "Stop NiFi"}, "ServiceInfo": {"state": "INSTALLED"}}' \
  http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
  echo "$DATE INFO: Waiting on HDF NiFi Service to STOP RUNNING via Ambari REST Call"
  wait $HDF NIFI "INSTALLED"
  echo "$DATE INFO: HDF NiFi Service STOPPED via Ambari REST Call"

  echo "$DATE INFO: Prebuilt HDF NiFi Flow removed from NiFi UI, but backed up"
  mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak

  echo "$DATE INFO: Starting HDF NiFi Service via Ambari REST Call"
  curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
  {"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
  http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
  echo "$DATE INFO: Waiting on HDF NiFi Service to START RUNNING via Ambari REST Call"
  wait $HDF NIFI "STARTED"
  echo "$DATE INFO: HDF NiFi Service STARTED via Ambari REST Call"

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_nifi() bash function, logging to $LOG_DIR_BASE/hdf/setup-nifi.log"
}

setup_public_dns | tee -a $LOG_DIR_BASE/hdf/setup-public-dns.log
setup_nifi $1 $2 | tee -a $LOG_DIR_BASE/hdf/setup-nifi.log
