---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

## Prerequisites

## Outline

- [Approach 1: Automatically Setup Development Platforms](#approach-1-automatically-setup-development-platforms)
- [Approach 2: Manually Setup Development Platforms via CLI](#approach-2-manually-setup-development-platforms-via-cli)
- [Summary](#summary)
- [Further Reading](#further-readings)

## Approach 1: Automatically Setup Development Platforms

Open the HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

- **Setup NiFi**:

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-a-security-breach-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh
~~~

Open the HDP Sandbox Web Shell Client at `http://sandbox-hdp.hortonworks.com:4200` with login `root/hadoop`. After login, you will be prompted to change the password.

- **Setup Spark**:

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-a-security-breach-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

## Approach 2: Manually Setup Development Platforms via CLI

## Setup Data-In-Motion Platform

Apache NiFi is a service that runs on Hortonworks DataFlow (HDF) Platform. HDF handles data-in-motion using flow management, stream processing and stream analytics. We will do some configurations, so later we can focus on building the NiFi dataflow application.

### Setting up NiFi

Open HDF **sandbox web shell client** at `sandbox-hdf.hortonworks.com:4200` with login credentials: user/pass = `root/hadoop`.

Execute the shell commands:

~~~bash
#!/bin/bash

# Create GeoFile directory and download in GeoFile DB
# Backup existing NiFi flow on canvas
# Upload and Import New NiFi flow onto canvas via NiFi Rest API
# NiFi Rest Ref: https://nifi.apache.org/docs/nifi-docs/rest-api/index.html

HDF_AMBARI_USER="admin"
HDF_AMBARI_PASS="admin"
HDF_CLUSTER_NAME="Sandbox"
HDF_HOST="sandbox-hdf.hortonworks.com"
HDF="hdf-sandbox"

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

# Download the GeoLite DB for NiFi
echo "Downloading GeoLite DB for NiFi"
GEODB_NIFI_DIR="/sandbox/tutorial-files/200/nifi"
mkdir -p $GEODB_NIFI_DIR/input/GeoFile $GEODB_NIFI_DIR/templates
chmod 777 -R $GEODB_NIFI_DIR
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
-O $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz
tar -zxvf $GEODB_NIFI_DIR/input/GeoFile/GeoLite2-City.tar.gz \
-C $GEODB_NIFI_DIR/input/GeoFile/
# Download the NiFi template
AMBARI_CREDENTIALS=$HDF_AMBARI_USER:$HDF_AMBARI_PASS
# echo "Stopping NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Stop NiFi"}, "ServiceInfo": {"state": "INSTALLED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "INSTALLED"

echo "Existing flow on NiFi canvas backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak
echo "Importing NiFi flow"
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/cf9f67737c3f1677b595673fc685670b44d9890f/tutorials/hdp/hdp-2.5/refine-and-visualize-server-log-data/assets/WebServerLogs.xml \
-O $GEODB_NIFI_DIR/templates/WebServerLogs.xml
gzip $GEODB_NIFI_DIR/templates/WebServerLogs.xml
cp -f $GEODB_NIFI_DIR/templates/WebServerLogs.xml.gz /var/lib/nifi/conf/flow.xml.gz

# echo "Starting NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "STARTED"
~~~

## Setup the Data-At-Rest Platform

Apache Spark is a service that runs on Hortonworks Data Platform (HDP). HDP handles data-at-rest using data management, data access engines, data governance, data security, data operations and data analytics. We will setup Spark, so later we can focus analyzing network traffic from NASA's server logs and storytelling it through a visualization notebook.

### Setting up Spark

Open HDP **sandbox web shell client** at `sandbox-hdp.hortonworks.com:4200` with login credentials: user/pass = `root/hadoop`.

~~~bash
#!/bin/bash
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
HDP="hdp-sandbox"

# Setup Spark by turning off maintenance mode
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS
curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
'{"RequestInfo": {"context":"Turn off Maintenance for SPARK"}, "Body":
{"ServiceInfo": {"maintenance_state":"OFF"}}}' \
http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/SPARK
~~~

## Summary

## Further Reading
