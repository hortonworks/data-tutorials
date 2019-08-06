#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Purpose: Automate building and starting the NiFi flow
# How: The script backups the previous existing NiFi flow if any existed,
# downloads the NiFi template, uploading the NiFi template via
# REST Call into the NiFi instance, importing the NiFi template into the
# NiFi canvas and starting the flow. Then once flow is done ingesting,
# preprocessing and storing the data let the User turn off the NiFi flow.
##
DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_DIR_BASE="/var/log/cda-sb/310"
mkdir -p $LOG_DIR_BASE/hdf
HDF_HOST="sandbox-hdf.hortonworks.com"

auto_deploy_nifi()
{
  echo "$DATE INFO: Expecting user to pass in NIFI_TEMPLATE name to this variable"
  NIFI_TEMPLATE="$1"  # $1: Expects user to pass their NiFi template name
  echo "$DATE INFO: Setting the path to the NIFI_TEMPLATE for NiFi REST Call"
  NIFI_TEMPLATE_PATH="/sandbox/tutorial-files/200/nifi/templates/$NIFI_TEMPLATE.xml"

  # Download NiFi Flow Template
  echo "$DATE INFO: Downloading the NIFI_TEMPLATE to location $NIFI_TEMPLATE_PATH"
  wget https://github.com/hortonworks/data-tutorials/blob/master/tutorials/cda/building-a-server-log-analysis-application/application/development/nifi-template/$NIFI_TEMPLATE.xml \
  -O $NIFI_TEMPLATE_PATH

  # Searches for OLD GeoLite2-City.mmdb file path in NiFi template file, then replaces OLD path with NEW path
  # Reference to pass a variable containing forward slashes to sed
  # Ref: https://stackoverflow.com/questions/27787536/how-to-pass-a-variable-containing-slashes-to-sed
  echo "$DATE INFO: Setting a Regex Search Pattern for old Geo DB Path that'll be used for sed cmd"
  GEO_DB_OLD_PATH=\/.*GeoLite2-City.mmdb
  echo "$DATE INFO: Setting a Replacement Value for new Geo DB Path that'll be used for sed cmd"
  GEO_DB_NEW_PATH=$(find / -name "GeoLite2-City.mmdb")
  echo "$DATE INFO: Executing sed to search for path to OLD Geo DB and replace it with NEW Geo DB"
  sed -i.bak "s~$GEO_DB_OLD_PATH~$GEO_DB_NEW_PATH~g" $NIFI_TEMPLATE_PATH

  # Upload and Import NiFi Template
  # Ref: https://community.hortonworks.com/questions/154138/in-apache-nifi-rest-api-what-is-difference-between.html
  # From NiFi Canvas, Store Process ID

  # Uses grep to store Root Process Group ID into Variable
  # Ref: https://stackoverflow.com/questions/5080988/how-to-extract-string-following-a-pattern-with-grep-regex-or-perl
  echo "$DATE INFO: Finding ROOT_PROCESS_GROUP_ID via NiFi REST Call for importing and starting NiFi flow"
  ROOT_PROCESS_GROUP_ID=$(curl -s -X GET http://$HDF_HOST:9090/nifi-api/process-groups/root | grep -Poi "\/process-groups\/\K[0-9a-z_\-]*")
  echo "$DATE INFO: Uploading NiFi flow to NiFi Application"
  curl -iv -F template=@"$NIFI_TEMPLATE_PATH" -X POST http://$HDF_HOST:9090/nifi-api/process-groups/$ROOT_PROCESS_GROUP_ID/templates/upload

  echo "$DATE INFO: Getting NiFi TEMPLATE_ID to be able to import NiFi flow"
  # Uses grep to store HVAC Template Process Group ID into Variable
  TEMPLATE_ID=$(curl -s -X GET http://$HDF_HOST:9090/nifi-api/flow/templates | grep -Po "{\"uri\":\".*\/templates\/\K[0-9a-z_\-]*(?=.*$NIFI_TEMPLATE)")
  echo "$DATE INFO: Importing NiFi flow to NiFi Canvas"
  curl -i -X POST -H 'Content-Type:application/json' -d '{"originX": 2.0,"originY": 3.0,"templateId": "'$TEMPLATE_ID'"}' http://$HDF_HOST:9090/nifi-api/process-groups/$ROOT_PROCESS_GROUP_ID/template-instance

  echo "$DATE INFO: Starting the NiFi Process Group"
  # Use Root Process Group
  # Still need to test specific Process Group ID of AcquireHVACData
  curl -X PUT -H 'Content-Type: application/json' -d '{"id":"'$ROOT_PROCESS_GROUP_ID'","state":"RUNNING"}' http://$HDF_HOST:9090/nifi-api/flow/process-groups/$ROOT_PROCESS_GROUP_ID
}

auto_deploy_nifi $1 | tee -a $LOG_DIR_BASE/hdf/auto-deploy-nifi_flow.log
