#!/bin/bash

###
#
# Purpose: Automate importing and starting a Zeppelin Notebook
#
###

HDP="hdp-sandbox"
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS

# Cleaning-Raw-NASA-Log-Data<.json>, Visualizing-NASA-Log-Data<.json>, etc
NOTEBOOK_NAME="$1"
ZEPPELIN_NOTEBOOK_PATH="/sandbox/tutorial-files/200/zeppelin/notebooks/$NOTEBOOK_NAME.json"
# Download Zeppelin Notebook
echo "Downloading Zeppelin Notebook: $NOTEBOOK_NAME"
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-detection-application/application/development/zeppelin-notebook/$NOTEBOOK_NAME.json \
-O $ZEPPELIN_NOTEBOOK_PATH

# Import Zeppelin Notebook via Zeppelin REST API Call
echo "Importing Zeppelin Noteook: $NOTEBOOK_NAME"
curl -d @"$ZEPPELIN_NOTEBOOK_PATH" -X POST http://$HDP_HOST:9995/api/notebook/import

echo "Grabbing List of Zeppelin Notebooks"
ZEPPELIN_NOTEBOOK_LIST=$(curl -s -X GET http://$HDP_HOST:9995/api/notebook/)
NOTEBOOK_ID=$(echo $ZEPPELIN_NOTEBOOK_LIST | grep -Po '"name":"'$NOTEBOOK_NAME'","id":"\K[^"]*(?=")')

# Start Zeppelin Notebook paragraphs via Zeppelin REST API Call
echo "Executing Paragraphs in Zeppelin Notebook: $NOTEBOOK_NAME"
curl -X POST http://$HDP_HOST:9995/api/notebook/job/$NOTEBOOK_ID
