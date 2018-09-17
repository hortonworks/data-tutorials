---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

Our objective in this part of building the HVAC system analysis application is to setup the development environment, so we can began acquiring the data, cleaning it and visualizing keep aspects of it to show insight to our clients. We will clean up the NiFi canvas on HDF, so we start fresh with no pre-existing dataflows.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Approach 1: Manually Setup Development Platforms via CLI](#approach-1-manually-setup-development-platforms-via-cli)
- [Approach 2: Automatically Setup Development Platforms](#approach-2-automatically-setup-development-platforms)
- [Summary](#summary)
- [Further Reading](#further-readings)

## Approach 1: Manually Setup Development Platforms via CLI

### Setting up HDF

~~~bash
#!/bin/bash
# Adding Public DNS to resolve msg: unable to resolv s3.amazonaws.com
# https://forums.aws.amazon.com/thread.jspa?threadID=125056
tee -a /etc/resolve.conf << EOF
# Google Public DNS
nameserver 8.8.8.8
EOF

##
# Purpose: HDF Sandbox comes with a prebuilt NiFi flow, which causes user to be
# pulled away from building the HVAC System Analysis Application.
#
# Potential Solution: Backup prebuilt NiFi flow and call it a different name.
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

# Stop NiFi first, then backup prebuilt NiFi flow, then start NiFi for
# changes to take effect

echo "Stopping NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Stop NiFi"}, "ServiceInfo": {"state": "INSTALLED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "INSTALLED"

echo "Prebuilt flow on NiFi canvas backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak

echo "Starting NiFi via Ambari"
curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
{"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
wait $HDF NIFI "STARTED"
~~~

## Approach 2: Automatically Setup Development Platforms

Open the HDF sandbox web shell client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh
~~~

Once the script finishes, you are now ready to move onto the next phase of development (the next tutorial), acquiring the data using NiFi.

## Summary

Congratulations! You now have the development environment ready to start building the HVAC system analysis application. The services needed for the application development have been setup, so we can began building the data pipeline.

## Further Reading

- [NiFi Rest API](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html)
- [Ambari Rest API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [Learning the bash Shell: Unix Shell Programming](https://www.amazon.com/Learning-bash-Shell-Programming-Nutshell/dp/0596009658)
