---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

Our objective in this part of building the HVAC system analysis application is to setup the development environment, so we can began acquiring the data, cleaning it and visualizing keep aspects of it to show insight to our clients. We will clean up the NiFi canvas on HDF, so we start fresh with no pre-existing dataflows.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Check these Two Areas Prior to Starting Approach 1 or Approach 2](#check-these-two-areas-prior-to-starting-approach-1-or-approach-2)
- [Approach 1: Manually Setup Development Platforms via CLI](#approach-1-manually-setup-development-platforms-via-cli)
- [Approach 2: Automatically Setup Development Platforms](#approach-2-automatically-setup-development-platforms)
- [Summary](#summary)
- [Further Reading](#further-readings)

## Check these Two Areas Prior to Starting Approach 1 or Approach 2

**Is our environment setup to map sandbox IP to desired hostname in hosts file?**

If this configuration hasn't been done, which in the demo we use `sandbox-hdf.hortonworks` and `sandbox-hdp.hortonworks.com` mapped to sandbox IP `127.0.0.1`, then for more guidance refer to the link: [environment setup](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#environment-setup).

**Have all the required services for HDF sandbox started up?**

If unsure, you can login to Ambari at [http://sandbox-hdf.hortonowrks.com:8080](http://sandbox-hdf.hortonowrks.com:8080). If you haven't setup Ambari `admin` password, refer to the link: [admin-password-reset](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#admin-password-reset) cause you will need the password for performing Ambari REST API Calls and operating on services in the Ambari UI. The Ambari Dashboard will **Background Operations Running window**, which is accessible by the gear icon at the top right of Ambari. From there, you should see **Start All Services** with a green progress bar near it.

## Approach 1: Manually Setup Development Platforms via CLI

### Setting up HDF

We will be using shell commands to setup the required services in our data-in-motion platform from the HDF sandbox web shell client located at [http://sandbox-hdf.hortonworks.com:4200](http://sandbox-hdf.hortonworks.com:4200). Web shell client login is `root/hadoop`, if this login is your first to the web shell client, then you will be prompted to reset your password, make sure to remember it.

Prior to copying and pasting all the following shell code, replace the following line of code `HDF_AMBARI_PASS="<Your-Ambari-Admin-Password>"` with the password you created for Ambari Admin user. For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `HDF_AMBARI_PASS="yellowHadoop"`

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

## Approach 2: Automatically Setup Development Platforms

We will download and execute a shell script to automate the setup of our data-in-motion platform from the HDF sandbox web shell client located at [http://sandbox-hdf.hortonworks.com:4200](http://sandbox-hdf.hortonworks.com:4200). Web shell client login is `root/hadoop`, if this login is your first to the web shell client, then you will be prompted to reset your password, make sure to remember it.

Prior to executing the shell script, replace the following line of shell code `AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"` with the password you created for Ambari Admin user. For example, if our Ambari Admin password was set to `yellowHadoop`, then the line of code would look as follows: `AMBARI_USER_PASSWORD="yellowHadoop"`

~~~bash
AMBARI_USER="admin"
AMBARI_USER_PASSWORD="<Your-Ambari-Admin-Password>"
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh $AMBARI_USER $AMBARI_USER_PASSWORD
~~~

Once the script finishes, you are now ready to move onto the next phase of development (the next tutorial), acquiring the data using NiFi.

## Summary

Congratulations! You now have the development environment ready to start building the HVAC system analysis application. The services needed for the application development have been setup, so we can began building the data pipeline.

## Further Reading

- [NiFi Rest API](https://nifi.apache.org/docs/nifi-docs/rest-api/index.html)
- [Ambari Rest API](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/index.md)
- [Learning the bash Shell: Unix Shell Programming](https://www.amazon.com/Learning-bash-Shell-Programming-Nutshell/dp/0596009658)
