---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

For this portion of the project as a Data Engineer, you have the following responsibilities for setting up the development environment: make sure both HDP and HDF CentOS7 can resolve domain names, on HDF download the GeoLite2 Database File, on HDF download NASA Logs, on HDF cleanup the NiFi canvas in case any pre-existing flows still are there from an old project and on HDP make sure Spark's maintenance mode is turned off. After we complete those items, we will be ready to start building the data pipeline.

## Prerequisites

## Outline

- [Approach 1: Manually Setup Development Platforms CLI](#approach-1-manually-setup-development-platforms-cli)
- [Approach 2: Auto Setup Development Platforms](#approach-2-auto-setup-development-platforms)
- [Summary](#summary)
- [Further Reading](#further-readings)

## Approach 1: Manually Setup Development Platforms CLI

### Setup HDF

Open HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

Copy and paste the code line by line. Overview of the script:

- wait function waits for service status to be STARTED or INSTALLED(STOPPED)
- add Google Public DNS for resolving domain name servers to IP addresses
- create directories for GeoLite DB and NASA Logs
- download and extract GeoLite DB and NASA Logs to their appropriate directories
- stop NiFi, backup & remove existing NiFi flow, start NiFi for updated changes

~~~bash
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
tee -a /etc/resolv.conf << EOF
# Google's Public DNS
nameserver 8.8.8.8
EOF
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

echo "Cleaning Up NiFi Canvas for NiFi Developer to build Cybersecurity Breach Analysis Flow..."
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
~~~

### Setup HDP

Open HDF Sandbox Web Shell Client at `http://sandbox-hdp.hortonworks.com:4200` with login `root/hadoop`. On first login, you will be prompted to reset your password.

Copy and paste the code line by line. Overview of the script:

- add Google Public DNS for resolving domain name servers to IP addresses
- turns off Spark's maintenance mode if it is on.

~~~bash
HDP="hdp-sandbox"
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS

echo "Setting up HDP Sandbox Development Environment"
tee -a /etc/resolv.conf << EOF
# Google's Public DNS
nameserver 8.8.8.8
EOF
echo "Turning off Spark's maintenance mode via Ambari"
curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
'{"RequestInfo": {"context":"Turn off Maintenance for SPARK"}, "Body":
{"ServiceInfo": {"maintenance_state":"OFF"}}}' \
http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/SPARK2
~~~

## Approach 2: Auto Setup Development Platforms

Open the HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

- **Setup NiFi**:

~~~bash
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh
~~~

Open the HDP Sandbox Web Shell Client at `http://sandbox-hdp.hortonworks.com:4200` with login `root/hadoop`. After login, you will be prompted to change the password.

- **Setup Spark**:

~~~bash
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

## Summary

Congratulations! You made sure that both HDF and HDP CentOS7 can resolve domain names. Thus, you were able to download GeoLite2 DB and NASA Server Log data. The platform dependencies for building the data pipeline have been resolved and we can now move forward with acquiring NASA server log data with NiFi.

## Further Reading

- [Ambari REST API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [NASA HTTP Server Logs](http://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html)
- [GeoLite2 Free Downloadable Databases](https://dev.maxmind.com/geoip/geoip2/geolite2/)
