---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

Our objective in this part of building the HVAC system analysis application is to setup the development environment by shell code, so we can jump to acquiring the data, cleaning it and visualizing keep aspects of it to show insight to our clients. We will clean up the NiFi canvas on HDF, so we start fresh with no pre-existing dataflows.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Check these Two Areas Prior to Starting Approach 1 or 2](#check-these-two-areas-prior-to-starting-approach-1-or-2)
- [Overview of Shell Code Used in Both Approaches](#overview-of-shell-code-used-in-both-approaches)
- [Approach 1: Manually Setup Development Environment](#approach-1-manually-setup-development-environment)
- [Approach 2: Automatically Setup Development Environment](#approach-2-automatically-setup-development-environment)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Check these Two Areas Prior to Starting Approach 1 or Approach 2

**Is our environment setup to map sandbox IP to desired hostname in hosts file?**

If this configuration hasn't been done, which in the demo we use `sandbox-hdf.hortonworks` and `sandbox-hdp.hortonworks.com` mapped to sandbox IP `127.0.0.1`, then for more guidance refer to the link: [environment setup](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#environment-setup).

**Have all the required services for HDF and HDP sandbox started up?**

If unsure, you can login to HDF Ambari at http://sandbox-hdf.hortonworks.com:8080. You can also HDP Ambari at http://sandbox-hdp.hortonworks.com:8080. If you haven't setup Ambari `admin` password, refer to the link: [ambari-admin-password-reset](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#admin-password-reset) cause you will need the password for performing Ambari REST API Calls and operating on services in the Ambari UI. For resetting Ambari Admin password on HDF, open HDF web shell client at http://sandbox-hdf.hortonworks.com:4200. For resetting Ambari Admin password on HDP, open HDP web shell client at http://sandbox-hdp.hortonworks.com:4200. With both web shell clients, initial login is `root/hadoop`, if it is your first login, then you will be prompted to reset your password, make sure to remember it. The Ambari Dashboard will **Background Operations Running window**, which is accessible by the gear icon at the top right of Ambari. From there, you should see **Start All Services** with a green progress bar near it. On HDF, verify **NiFi** started. On HDP, verify **HDFS**, **Hive** and **Zeppelin** started. Otherwise, start them.

## Overview of Shell Code Used in Both Approaches

In **approach 1**, you will manually run the code line by line to setup the development environment. Yet in **approach 2**, you will download and execute a shell script to automate development environment setup. The shell code `tee -a <file> << EOF ... EOF` appends Google's Public DNS to `/etc/resolve.conf` to translate a variety of hostnames to IP addresses. The problem that this configuration potentially solves is using Google's Public DNS to translate `s3.amazonaws.com` to an IP address that services in the application can use to get data. The next couple lines of code initialize variables that will be used in the Ambari REST API Calls. The `wait()` function waits for Ambari services on HDF or HDP to stop or start. The two `curl` commands are used for sending JSON data by Ambari REST API Calls to tell the Ambari Server to overwrite the existing NiFi service state to INSTALLED (means STOPPED) or STARTED. First we tell Ambari we want to STOP the NiFi service. Next we backup and remove the pre-existing NiFi flow to clean the NiFi canvas, so we can do development. Lastly, we tell Ambari to START the NiFi service for the changes to take effect.

## Approach 1: Manually Setup Development Environment

### Setting up HDF

We will be using shell commands to setup the required services in our data-in-motion and data-at-rest platforms from the sandbox web shell clients.

Open the **HDF web shell client** located at http://sandbox-hdf.hortonworks.com:4200.

Prior to copying and pasting all the following shell code line by line, replace the following line of code `HDF_AMBARI_PASS="<Your-Ambari-Admin-Password>"` with the password you created for Ambari Admin user. For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `HDF_AMBARI_PASS="yellowHadoop"`

Copy and paste the following shell code line by line in HDF web shell:

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
HDF_AMBARI_PASS="<Your-Ambari-Admin-Password>"
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

### Setting up HDP

Open the **HDP web shell client** located at http://sandbox-hdp.hortonworks.com:4200. Copy and paste the following code to HDP web shell line by line.

~~~bash
#!/bin/bash
# Creates /sandbox directory in HDFS
# allow read-write-execute permissions for the owner, group, and any other users

su hdfs
hdfs dfs -mkdir -p /sandbox/sensor/hvac_building/ /sandbox/sensor/hvac_machine
hdfs dfs -chmod -R 777 /sandbox/sensor/hvac_building/ /sandbox/sensor/hvac_machine
exit
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
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh $AMBARI_USER $AMBARI_USER_PASSWORD
~~~

Open **HDP web shell client** located at [http://sandbox-hdp.hortonworks.com:4200](http://sandbox-hdp.hortonworks.com:4200). Copy and paste the following code to HDP web shell:

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

Now that the development environment is setup, you can move onto the summary.

## Summary

Congratulations! You now have the development environment ready to start building the HVAC system analysis application. The services needed for the application development have been setup, so we can began building the data pipeline.

## Further Reading

- [NiFi Rest API](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html)
- [Ambari Rest API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [Learning the bash Shell: Unix Shell Programming](https://www.amazon.com/Learning-bash-Shell-Programming-Nutshell/dp/0596009658)
