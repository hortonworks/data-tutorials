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
#
# KEY="<Your-Consumer-API-Key>"
# SECRET_KEY="<Your-Consumer-API-Secret-Key>"
# TOKEN="<Your-Access-Token>"
# SECRET_TOKEN="<Your-Access-Token-Secret>"
##

KEY="$1"
SECRET_KEY="$2"
TOKEN="$3"
SECRET_TOKEN="$4"

HDF_AMBARI_USER="admin"
HDF_AMBARI_PASS="admin"
HDF_CLUSTER_NAME="Sandbox"
HDF_HOST="sandbox-hdf.hortonworks.com"
HDF="hdf-sandbox"

NIFI_TEMPLATE_BASE="/sandbox/tutorial-files/770/nifi/templates"
NIFI_TEMPLATE_PATH_NAME="$NIFI_TEMPLATE_BASE/AcquireTwitterData.xml"

mkdir -p $NIFI_TEMPLATE_BASE

# Download NiFi Flow Template
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-customer-sentiment-analysis-application/application/development/nifi-template/AcquireTwitterData.xml \
-O $NIFI_TEMPLATE_PATH_NAME

# Searches for OLD AcquireTwitterData.xml file path in NiFi template file, then replaces OLD path with NEW path
# Reference to pass a variable containing forward slashes to sed
# Ref: https://stackoverflow.com/questions/27787536/how-to-pass-a-variable-containing-slashes-to-sed
KEY_OLD_PATH=

# Updates template with user's chosen KEY, SECRET_KEY, TOKEN and SECRET_TOKEN from their Twitter Developer Account
tee -a /sandbox/tutorial-files/770/nifi/template-updater.py << EOF
#!/usr/bin/python
# XML API Ref: https://docs.python.org/2/library/xml.etree.elementtree.html
# Using Element to interact with a single XML element and its sub-elements
# in XML document (r/w to/from files)
import xml.etree.ElementTree as ET
tree = ET.parse('$NIFI_TEMPLATE_PATH_NAME')
root = tree.getroot()
# shows XML tag at root level
root_tag = root.tag
if root_tag == 'template':
  print "Our root tag signifies this XML is a nifi template"
  # Iterate child nodes of root node "<template>"
  template_name = root.find('name').text
  if template_name == "AcquireTwitterData":
    print "Our name tag signifies this XML is 'AcquireTwitterData' template"
    for processors in root.iter('processors'):
  else:
    print "Our name tag signifies this XML isn't 'AcquireTwitterData' template"
else:
  print "Our root tag signifies this XML isn't a nifi template"
EOF

# Parses NiFi template using XPATH
XPATH1="<snippet> -> <processors> -> <config> -> <properties> -> <processors[4]>"
CHECK_XPATH2="<type>org.apache.nifi.processors.twitter.GetTwitter</type>"
if XPATH2 == GetTwitter,
then
  start at beginning of perform XPATH3="<processors[4]> -> <config> -> <properties> -> <entry[1-4]>"
  if XPATH3 == Consumer Key,
  then
    fill value with user passed in KEY
  elif XPATH3 == Consumer Secret,
  then
    fill value with user passed in SECRET_KEY
  elif XPATH3 == Access Token,
  then
    fill value with user passed in TOKEN
  elif XPATH3 == Access Token Secret,
  then
    fill value with user passed in SECRET_TOKEN
  else
    no value to update in NiFi template
  fi
else
  not GetTwitter
fi
