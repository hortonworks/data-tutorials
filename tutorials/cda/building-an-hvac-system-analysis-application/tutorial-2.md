---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

Our objective in this part of building the HVAC system analysis application is to setup the development environment by shell code, so we can jump to acquiring the data, cleaning it and visualizing keep aspects of it to show insight to our clients. We will clean up the NiFi canvas on HDF, so we start fresh with no pre-existing dataflows.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Verify Prerequisites Have Been Covered](#verify-prerequisites-have-been-covered)
- [Overview of Shell Code Used in Both Approaches](#overview-of-shell-code-used-in-both-approaches)
- [Approach 1: Manually Setup Development Environment](#approach-1-manually-setup-development-environment)
- [Approach 2: Automatically Setup Development Environment](#approach-2-automatically-setup-development-environment)
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
- for HDP at http://sandbox-hdp.hortonworks.com:8080 and verify **HDFS**, **Hive** and **Zeppelin** starts up, else start them.

## Overview of Shell Code Used in Both Approaches

In **approach 1**, you will manually run the code line by line to setup the development environment. Yet in **approach 2**, you will download and execute a shell script to automate development environment setup. The shell code `tee -a <file> << EOF ... EOF` appends Google's Public DNS to `/etc/resolve.conf` to translate a variety of hostnames to IP addresses. The problem that this configuration potentially solves is using Google's Public DNS to translate `s3.amazonaws.com` to an IP address that services in the application can use to get data. The next couple lines of code initialize variables that will be used in the Ambari REST API Calls. The `wait()` function waits for Ambari services on HDF or HDP to stop or start. The two `curl` commands are used for sending JSON data by Ambari REST API Calls to tell the Ambari Server to overwrite the existing NiFi service state to INSTALLED (means STOPPED) or STARTED. First we tell Ambari we want to STOP the NiFi service. Next we backup and remove the pre-existing NiFi flow to clean the NiFi canvas, so we can do development. Lastly, we tell Ambari to START the NiFi service for the changes to take effect.

## Approach 1: Manually Setup Development Environment

### Setting up HDF

We will be using shell commands to setup the required services in our data-in-motion and data-at-rest platforms from the sandbox web shell clients.

Open the **HDF web shell client** located at http://sandbox-hdf.hortonworks.com:4200.

Prior to executing the shell code, replace the following string `"<Your-Ambari-Admin-Password>"` in the following line of code `setup_nifi "admin" "<Your-Ambari-Admin-Password>"` on the last line with the password you created for ambari admin user.  For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `AMBARI_USER_PASSWORD="yellowHadoop"`

Copy and paste the following shell code line by line in HDF web shell:

~~~bash
##
# Script sets up HDF services used in Building an HVAC System Analysis Application
##

DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/310/"
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
  echo "$DATE INFO: Executing setup_nifi bash function, logging to $LOG_DIR_BASE/hdf/setup-public-dns.log"
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

  echo "$DATE INFO: Prebuilt HDF NiFi Flow removed from NiFi UI, but backed up"
  mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak

  echo "$DATE INFO: Starting HDF NiFi Service via Ambari REST Call"
  curl -u $AMBARI_CREDENTIALS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":
  {"context": "Start NiFi"}, "ServiceInfo": {"state": "STARTED"}}' \
  http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/NIFI
  echo "$DATE INFO: Waiting on HDF NiFi Service to START RUNNING via Ambari REST Call"
  wait $HDF NIFI "STARTED"

  # Log everything, but also output to stdout
  echo "$DATE INFO: Executing setup_nifi bash function, logging to $LOG_DIR_BASE/hdf/setup-nifi.log"
}

setup_public_dns | tee -a $LOG_DIR_BASE/hdf/setup-public-dns.log
setup_nifi "admin" "<Your-Ambari-Admin-Password>" | tee -a $LOG_DIR_BASE/hdf/setup-nifi.log
~~~

### Setting up HDP

Open the **HDP web shell client** located at http://sandbox-hdp.hortonworks.com:4200. Copy and paste the following code to HDP web shell line by line.

~~~bash
##
# Sets up HDP services used in Building an HVAC System Analysis Application
##

DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/310/"
echo "Setting Up HDP Dev Environment for HVAC System Analysis App"

# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users
mkdir -p $LOG_DIR_BASE/hdp
setup_hdfs()
{
  echo "$DATE INFO: Creating /sandbox/sensor/hvac_building and /sandbox/sensor/hvac_machine"
  sudo -u hdfs hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/
  sudo -u hdfs hdfs dfs -mkdir /sandbox/sensor/hvac_machine
  echo "$DATE INFO: Setting permissions for hvac_buildnig and hvac_machine to 777"
  sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/
  sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_machine
  echo "$DATE INFO: Checking both directories were created and permissions were set"
  sudo -u hdfs hdfs dfs -ls /sandbox/sensor
}
# Log everything, but also output to stdout
echo "$DATE INFO: Executing setup_hdfs bash function, logging to /var/log/cda-sb/310/setup-hdp.log"
setup_hdfs | tee -a $LOG_DIR_BASE/hdp/setup-hdp.log
~~~

Now that the development environment is setup, you can move onto the summary.

## Approach 2: Automatically Setup Development Environment

We will download and execute a shell script to automate the setup of our data-in-motion and data-at-rest platforms from the sandbox web shell clients.

Open **HDF web shell client** located at [http://sandbox-hdf.hortonworks.com:4200](http://sandbox-hdf.hortonworks.com:4200).

Prior to executing the shell script, replace the following line of shell code `AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"` with the password you created for Ambari Admin user. For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `AMBARI_USER_PASSWORD="yellowHadoop"`

Copy and paste the following code to HDF web shell with your updated change:

~~~bash
AMBARI_USER="admin"
AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh $AMBARI_USER $AMBARI_USER_PASSWORD
~~~

Open **HDP web shell client** located at [http://sandbox-hdp.hortonworks.com:4200](http://sandbox-hdp.hortonworks.com:4200). Copy and paste the following code to HDP web shell:

~~~bash
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

Now that the development environment is setup, you can move onto the summary.

## Summary

Congratulations! You now have the development environment ready to start building the HVAC system analysis application. The services needed for the application development have been setup, so we can began building the data pipeline.

## Further Reading

- [NiFi Rest API](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html)
- [Ambari Rest API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [Learning the bash Shell: Unix Shell Programming](https://www.amazon.com/Learning-bash-Shell-Programming-Nutshell/dp/0596009658)
