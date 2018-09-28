#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Sets up HDF services used in Building an HVAC System Analysis Application
##

DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/310"
echo "$DATE INFO: Setting Up HDF Dev Environment for HVAC System Analysis App"
mkdir -p $LOG_DIR_BASE/hdf
setup_public_dns()
{
  ##
  # Purpose of the following section of Code:
  # NiFi GetHTTP will run into ERROR cause it can't resolve S3 Domain Name Server (DNS)
  #
  # Potential Solution: Append Google Public DNS to CentOS7 /etc/resolve.conf
  # CentOS7 is the OS of the server NiFi runs on. Google Public DNS is able to
  # resolve S3 DNS. Thus, GetHTTP can download HVAC Sensor Data from S3.
  ##

  # Adding Public DNS to resolve msg: unable to resolv s3.amazonaws.com
  # https://forums.aws.amazon.com/thread.jspa?threadID=125056
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
  ##
  # Purpose of the following section of Code:
  # HDF Sandbox comes with a prebuilt NiFi flow, which causes user to be
  # pulled away from building the HVAC System Analysis Application.
  #
  # Potential Solution: Backup prebuilt NiFi flow and call it a different name.
  ##

  echo "$DATE INFO: Setting HDF_AMBARI_USER based on user input"
  HDF_AMBARI_USER="$1"  # $1: Expects user to pass "Ambari User" into the file
  echo "$DATE INFO: Setting HDF_AMBARI_PASS based on user input"
  HDF_AMBARI_PASS="$2"  # $2: Expects user to pass "Ambari Admin Password" into the file
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
      echo "$DATE ERROR: Didn't Wait for Service, sandbox chosen not valid"
    fi
  }

  # Stop NiFi first, then backup prebuilt NiFi flow, then start NiFi for
  # changes to take effect
  echo "$DATE INFO: Stopping HDF NiFi Service via Ambari REST Call"
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
