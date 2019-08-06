#!/bin/bash

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
