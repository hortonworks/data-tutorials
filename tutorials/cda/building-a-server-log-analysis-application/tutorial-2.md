---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

For this portion of the project as a Data Engineer, you have the following responsibilities for setting up the development environment: make sure both HDP and HDF CentOS7 can resolve domain names, on HDF download the GeoLite2 Database File, on HDF download NASA Logs, on HDF cleanup the NiFi canvas in case any pre-existing flows still are there from an old project and on HDP make sure Spark's maintenance mode is turned off. After we complete those items, we will be ready to start building the data pipeline.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Verify Prerequisites Have Been Covered](#verify-prerequisites-have-been-covered)
- [Overview of Shell Code Used in Both Approaches](#overview-of-shell-code-used-in-both-approaches)
- [Approach 1: Manually Setup Development Environment](#approach-1-manually-setup-development-environment)
- [Approach 2: Auto Setup Development Environment](#approach-2-auto-setup-development-environment)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Verify Prerequisites Have Been Covered

**Map sandbox IP to desired hostname in hosts file**

- If you need help mapping Sandbox IP to hostname, reference **Environment
Setup -> Map Sandbox IP To Your Desired Hostname In The Hosts File** in [Learning the Ropes of HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

**Setup Ambari admin password for "HDF" and "HDP"**

If you need help setting the Ambari admin password,

- for HDP, reference **Admin Password Reset** in [Learning the Ropes of HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)
- for HDF, reference **Admin Password Reset** in [Learning the Ropes of HDF Sandbox](https://hortonworks.com/tutorial/getting-started-with-hdf-sandbox/)

**Started up all required services for "HDF" and "HDP"**

If unsure, login to Ambari **admin** Dashboard

- for HDF at http://sandbox-hdf.hortonworks.com:8080 and verify **NiFi** starts up, else start it.
- for HDP at http://sandbox-hdp.hortonworks.com:8080 and verify **HDFS**, **Spark2** and **Zeppelin** starts up, else start them.

## Overview of Shell Code Used in Both Approaches

### HDF Shell Code

**setup-hdf.sh**

- wait function waits for service status to be STARTED or INSTALLED(STOPPED)
- add Google Public DNS for resolving domain name servers to IP addresses
- create directories for GeoLite DB and NASA Logs
- download and extract GeoLite DB and NASA Logs to their appropriate directories
- stop NiFi, backup & remove existing NiFi flow, start NiFi for updated changes

### HDP Shell Code

**setup-hdp.sh**

- add Google Public DNS for resolving domain name servers to IP addresses
- turns off Spark's maintenance mode if it is on.

## Approach 1: Manually Setup Development Environment

### Setting up HDF

We will be using shell commands to setup the required services in our data-in-motion and data-at-rest platforms from the sandbox web shell clients.

Open HDF Sandbox Web Shell Client at http://sandbox-hdf.hortonworks.com:4200.

Prior to executing the shell code, replace the following string `"<Your-Ambari-Admin-Password>"` in the following line of code `setup_nifi "admin" "<Your-Ambari-Admin-Password>"` on the last line with the password you created for Ambari admin user.  For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `AMBARI_USER_PASSWORD="yellowHadoop"`

Copy and paste the code line by line:

~~~bash
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
setup_nifi "admin" "<Your-Ambari-Admin-Password>" | tee -a $LOG_DIR_BASE/hdf/setup-nifi.log
~~~

### Setup HDP

Open HDF Sandbox Web Shell Client at http://sandbox-hdp.hortonworks.com:4200.

Copy and paste the code line by line:

~~~bash
##
# Sets up HDP Dev Environment, so User can focus on Spark Data Analysis
# 1. Add Google Public DNS to /etc/resolve.conf
# 2. Created Directory for Zeppelin Notebook, can be referenced later when auto importing Zeppelin Notebooks via Script
# 3. Created HDFS Directory for NiFi to have permission to write data
##

DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/200"
echo "Setting Up HDP Dev Environment for Server Log Analysis App"
mkdir -p $LOG_DIR_BASE/hdp

setup_public_dns()
{
  echo "$DATE INFO: Adding Google Public DNS to /etc/resolve.conf"
  echo "# Google Public DNS" | tee -a /etc/resolve.conf
  echo "nameserver 8.8.8.8" | tee -a /etc/resolve.conf

  echo "$DATE INFO: Checking Google Public DNS added to /etc/resolve.conf"
  cat /etc/resolve.conf

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_public_dns() bash function, logging to $LOG_DIR_BASE/hdp/setup-public-dns.log"
}

setup_zeppelin()
{
  echo "$DATE INFO: Creating Directory for Zeppelin Notebooks"
  mkdir -p /sandbox/tutorial-files/200/zeppelin/notebooks/
  echo "$DATE INFO: Allowing read-write-execute permissions to any user, for zeppelin REST Call"
  chmod -R 777 /sandbox/tutorial-files/200/zeppelin/notebooks/

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_zeppelin() bash function, logging to $LOG_DIR_BASE/hdp/setup-zeppelin.log"
}

setup_hdfs()
{
  # Creates /sandbox directory in HDFS
  # allow read-write-execute permissions for the owner, group, and any other users
  echo "$DATE INFO: Creating HDFS dir /sandbox/tutorial-files/200/nifi/ for HDF NiFi to write data"
  sudo -u hdfs hdfs dfs -mkdir -p /sandbox/tutorial-files/200/nifi/
  echo "$DATE INFO: Allowing read-write-execute permissions to any user, so NiFi has write access"
  sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/tutorial-files/200/nifi/
  echo "$DATE INFO: Checking directory was created and permissions were set"
  sudo -u hdfs hdfs dfs -ls /sandbox/tutorial-files/200/

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_hdfs() bash function, logging to $LOG_DIR_BASE/hdp/setup-hdfs.log"
}

setup_public_dns | tee -a $LOG_DIR_BASE/hdp/setup-public-dns.log
setup_zeppelin | tee -a $LOG_DIR_BASE/hdp/setup-zeppelin.log
setup_hdfs | tee -a $LOG_DIR_BASE/hdp/setup-hdfs.log
~~~

## Approach 2: Auto Setup Development Environment

We will download and execute a shell script to automate the setup of our data-in-motion and data-at-rest platforms from the sandbox web shell clients.

### Auto Setup HDF

Open the **HDF web shell client** at http://sandbox-hdf.hortonworks.com:4200.

Prior to executing the shell script, replace the following line of shell code `AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"` with the password you created for Ambari Admin user. For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `AMBARI_USER_PASSWORD="yellowHadoop"`

~~~bash
AMBARI_USER="admin"
AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"
wget https://github.com/hortonworks/data-tutorials/raw/master/tutorials/cda/building-a-server-log-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh $AMBARI_USER $AMBARI_USER_PASSWORD
~~~

### Auto Setup HDP

Open the **HDP web shell client** at http://sandbox-hdp.hortonworks.com:4200.

~~~bash
wget https://github.com/hortonworks/data-tutorials/raw/master/tutorials/cda/building-a-server-log-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

## Summary

Congratulations! You made sure that both HDF and HDP CentOS7 can resolve domain names. Thus, you were able to download GeoLite2 DB and NASA Server Log data. The platform dependencies for building the data pipeline have been resolved and we can now move forward with acquiring NASA server log data with NiFi.

## Further Reading

- [Ambari REST API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [NASA HTTP Server Logs](http://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html)
- [GeoLite2 Free Downloadable Databases](https://dev.maxmind.com/geoip/geoip2/geolite2/)
