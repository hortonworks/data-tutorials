#!/bin/bash

##
# Author: James Medel
# Email: jamesmedel94@gmail.com
##

##
# Run script in HDP Sandbox CentOS7
# Sets up HDP Dev Environment, so User can focus on doing the Sentiment
# Data Analysis
##

HDP="hdp-sandbox"
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
AMBARI_CREDENTIALS=$HDP_AMBARI_USER:$HDP_AMBARI_PASS

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

# Start Service in Ambari Stack and wait for it
# $1: HDF or HDP
# $2: Service
function wait_for_service_to_start()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Start '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDP $2 "STARTED"
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Start '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDF $2 "STARTED"
  else
    echo "ERROR: Didn't Start Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Stop Service in Ambari Stack and wait for it
# $1: HDF or HDP
# $2: Service
function wait_for_service_to_stop()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By: ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Stop '"$2"' via REST"},
    "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' $ENDPOINT
    wait $HDP $2 "INSTALLED"
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -i -H 'X-Requested-By:ambari' -X PUT -d \
    '{"RequestInfo": {"context":"Stop '"$2"' via REST"},
     "Body": {"ServiceInfo": {"state": "STARTED"}}}' $ENDPOINT
    wait $HDF $2 "INSTALLED"
  else
    echo "ERROR: Didn't Stop Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Check service state on the cluster, whether running or installed (stopped)
# $1: HDF or HDP
# $2: Service - SOLR, AMBARI_INFRA, exs
function check_service_state()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2?fields=ServiceInfo"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl --silent -u $AMBARI_CREDENTIALS -X GET $ENDPOINT | grep "\"state\""
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2?fields=ServiceInfo"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl --silent -u $AMBARI_CREDENTIALS -X GET $ENDPOINT | grep "\"state\""
  else
    echo "ERROR: Didn't Check Service State, need to choose appropriate sandbox HDF or HDP"
  fi

}

# Add a New Service to the HDF/HDP Cluster
# TODO: check if Service already exists in cluster
# $1: HDF or HDP
# $2: Service
function add_service()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"ServiceInfo:":{"service_name":'"$2"'}}' $ENDPOINT
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"ServiceInfo:":{"service_name":'"$2"'}}' $ENDPOINT
  else
    echo "ERROR: Didn't Add New Service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Check if service added to the HDF/HDP Cluster
# $1: HDF or HDP
# $2: Service
function check_if_service_added()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    WAS_SERVICE_ADDED=$(curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X GET $ENDPOINT)
    echo $WAS_SERVICE_ADDED | grep -o *"service_name"*
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    WAS_SERVICE_ADDED=$(curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X GET $ENDPOINT)
    echo $WAS_SERVICE_ADDED | grep -o *"service_name"*
  else
    echo "ERROR: Didn't Check if Service is Added, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Add components to the Service
# $1: HDF or HDP
# $2: Service - SOLR, AMBARI_INFRA, exs
function add_components_to_service()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2/components/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"RequestInfo":{"context":"Install '$2'"}, "Body":{"HostRoles":
    {"state":"INSTALLED"}}}' $ENDPOINT
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2/components/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -k -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"RequestInfo":{"context":"Install '$2'"}, "Body":{"HostRoles":
    {"state":"INSTALLED"}}}' $ENDPOINT
  else
    echo "ERROR: Didn't add components to service, need to choose appropriate sandbox HDF or HDP"
  fi

}

# Read Config File of Service on Ambari Stack
# $1: HDF or HDP
# $2: Service Ambari Config File - SOLR -> example-collection.xml
function read_config_file()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/configurations"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    # Read from example-collection.xml
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:raj_ops" -i -X POST -d "@$2" \
    $ENDPOINT
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/configurations"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    # Read from example-collection.xml
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:raj_ops" -i -X POST -d "@$2" \
    $ENDPOINT
  else
    echo "ERROR: Didn't read config file of service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Apply configuration
# $1: HDF_HOST or HDP_HOST
# $2: Service Ambari Config File - SOLR -> config_file.<json|xml|etc>
function apply_configuration()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -v -u $AMBARI_CREDENTIALS -H 'X-Requested-By:raj_ops' -i -X PUT -d \
    '{ "Clusters" : {"desired_configs": {"type": "'$2'", "tag" : "INITIAL" }}}' \
    $ENDPOINT
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -v -u $AMBARI_CREDENTIALS -H 'X-Requested-By:raj_ops' -i -X PUT -d \
    '{ "Clusters" : {"desired_configs": {"type": "'$2'", "tag" : "INITIAL" }}}' \
    $ENDPOINT
  else
    echo "ERROR: Didn't apply configuration for service, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Install Component on Target HOST
# $1: HDF_HOST or HDP_HOST
# $2: Service - SOLR, AMBARI_INFRA, exs
function add_component_to_host()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/hosts?Hosts/host_name=$HDP_MASTER_DNS"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"host_components" : [{"HostRoles":{"component_name":"'$2'"}}] }' \
    $ENDPOINT
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/hosts?Hosts/host_name=$HDF_MASTER_DNS"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X POST -d \
    '{"host_components" : [{"HostRoles":{"component_name":"'$2'"}}] }' \
    $ENDPOINT
  else
    echo "ERROR: Didn't add component to target host, need to choose appropriate sandbox HDF or HDP"
  fi
}

# Install Service on Ambari Stack for HDP/HDF
# $1: HDF_HOST or HDP_HOST
# $2: Service - SOLR, AMBARI_INFRA, exs
function install_service()
{
  if [[ $1 == "hdp-sandbox" ]]
  then
    ENDPOINT="http://$HDP_HOST:8080/api/v1/clusters/$HDP_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDP_AMBARI_USER:$HDP_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
    '{"RequestInfo":{"context":"Install '$2' via REST API"}, "ServiceInfo":
    {"state":"INSTALLED"}}'
  elif [[ $1 == "hdf-sandbox" ]]
  then
    ENDPOINT="http://$HDF_HOST:8080/api/v1/clusters/$HDF_CLUSTER_NAME/services/$2"
    AMBARI_CREDENTIALS="$HDF_AMBARI_USER:$HDF_AMBARI_PASS"
    curl -u $AMBARI_CREDENTIALS -H "X-Requested-By:ambari" -i -X PUT -d \
    '{"RequestInfo":{"context":"Install '$2' via REST API"}, "ServiceInfo":
    {"state":"INSTALLED"}}'
  else
    echo "ERROR: Didn't add component to target host, need to choose appropriate sandbox HDF or HDP"
  fi
}

echo "Setting up HDP Sandbox Development Environment for Kafka, Hive, Spark and Solr Data Analysis"

echo "Starting Kafka in case it is off"
wait_for_service_to_start $HDP KAFKA
echo "Creating and registering Kafka topic 'tweets'"
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper sandbox-hdp.hortonworks.com:2181 --replication-factor 1 --partitions 10 --topic tweets

echo "Setting Up Maven needed for Compiling and Installing Hive JSON-Serde Lib"
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum install -y apache-maven
mvn -version

echo "Setting up Hive JSON-Serde Libary"
git clone https://github.com/rcongiu/Hive-JSON-Serde
cd Hive-JSON-Serde
# Compile JsonSerDe source to create JsonSerDe library jar file
mvn -Phdp23 clean package
# Give JsonSerDe library jar file to Hive and Hive2 library
cp json-serde/target/json-serde-1.3.9-SNAPSHOT-jar-with-dependencies.jar /usr/hdp/3.0.0.0-1634/hive/lib
# Restart (stop/start) Hive via Ambari REST Call
wait_for_service_to_stop $HDP "HIVE"
wait_for_service_to_start $HDP "HIVE"
cd ~/

echo "Setting up HDFS for Tweet Data"
HDFS_TWEET_STAGING="/sandbox/tutorial-files/770/tweets_staging"
LFS_TWEETS_PACKAGED_PATH="/sandbox/tutorial-files/770/tweets"
sudo -u hdfs mkdir -p $LFS_TWEETS_PACKAGED_PATH
# Create tweets_staging hdfs directory ahead of time for hive
sudo -u hdfs hdfs dfs -mkdir -p $HDFS_TWEET_STAGING
# Change HDFS ownership of tweets_staging dir to maria_dev
sudo -u hdfs hdfs dfs -chown -R maria_dev $HDFS_TWEET_STAGING
# Change HDFS tweets_staging dir permissions to everyone
sudo -u hdfs hdfs dfs -chmod -R 777 $HDFS_TWEET_STAGING
# give anyone rwe permissions to /sandbox/tutorial-files/770
sudo -u hdfs hdfs dfs -chmod -R 777 /sandbox/tutorial-files/770
sudo -u hdfs wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-sentiment-analysis-application/application/setup/data/tweets.zip -O $LFS_TWEETS_PACKAGED_PATH/tweets.zip
sudo -u hdfs unzip $LFS_TWEETS_PACKAGED_PATH/tweets.zip -d $LFS_TWEETS_PACKAGED_PATH
sudo -u hdfs rm -rf $LFS_TWEETS_PACKAGED_PATH/tweets.zip
# Remove existing (if any) copy of data from HDFS. You could do this with Ambari file view.
sudo -u hdfs hdfs dfs -rm -r -f $HDFS_TWEET_STAGING/* -skipTrash
# Move downloaded JSON file from local storage to HDFS
sudo -u hdfs hdfs dfs -put $LFS_TWEETS_PACKAGED_PATH/* $HDFS_TWEET_STAGING

echo "Installing SBT for Spark"
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum install -y sbt

echo "Setting up HBase for Sentiment Score Storage"
# -e: causes echo to process escape sequences, build confirmation into it
# -n: tells hbase shell this is a non-interactive session
echo -e "create 'tweets_sentiment','social_media_sentiment'" | hbase shell -n

exit
