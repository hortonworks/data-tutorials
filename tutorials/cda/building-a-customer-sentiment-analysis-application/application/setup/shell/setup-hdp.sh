#!/bin/bash

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

echo "Setting up HDP Sandbox Development Environment for Hive, Spark and Solr Data Analysis"

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
cp json-serde/target/json-serde-1.3.9-SNAPSHOT-jar-with-dependencies.jar /usr/hdp/2.6.5.0-292/hive/lib
cp json-serde/target/json-serde-1.3.9-SNAPSHOT-jar-with-dependencies.jar /usr/hdp/2.6.5.0-292/hive2/lib
# Restart (stop/start) Hive via Ambari REST Call
wait_for_service_to_stop $HDP "HIVE"
wait_for_service_to_start $HDP "HIVE"
cd ~/

echo "Setting up HDFS for Hive Tweet Data"
HIVE_HDFS_TWEET_STAGING="/sandbox/tutorial-files/770/hive/tweets_staging"
HIVE_HDFS_TABLES="/sandbox/tutorial-files/770/hive/data/tables"
su hdfs
# Create hive/tweets_staging hdfs directory ahead of time for hive
hdfs dfs -mkdir -p $HIVE_HDFS_TWEET_STAGING
# Change HDFS ownership of tweets_staging dir to maria_dev
hdfs dfs -chown -R maria_dev $HIVE_HDFS_TWEET_STAGING
# Change HDFS tweets_staging dir permissions to everyone
hdfs dfs -chmod -R 777 $HIVE_HDFS_TWEET_STAGING
# Create new /tmp/data/tables directory inside /tmp dir
hdfs dfs -mkdir -p $HIVE_HDFS_TABLES
# Set permissions for tables dir
hdfs dfs -chmod 777 $HIVE_HDFS_TABLES
# Inside tables parent dir, create time_zone_map dir
hdfs dfs -mkdir $HIVE_HDFS_TABLES/time_zone_map
# Inside tables parent dir, create dictionary dir
hdfs dfs -mkdir $HIVE_HDFS_TABLES/dictionary
# Exit HDFS user
exit
# Download time_zone_map.tsv file on local file system(FS)
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-customer-sentiment-analysis-application/application/setup/data/time_zone_map.tsv
# Copy time_zone_map.tsv from local FS to HDFS
hdfs dfs -put time_zone_map.tsv $HIVE_HDFS_TABLES/time_zone_map/
# Download dictionary.tsv file on local file system
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-customer-sentiment-analysis-application/application/setup/data/dictionary.tsv
# Copy dictionary.tsv from local FS to HDFS
hdfs dfs -put dictionary.tsv $HIVE_HDFS_TABLES/dictionary/


echo "Installing SBT for Spark"
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum install -y sbt

echo "Downloading SOLR Config files for SOLR Install for Ambari Install REST API"

SOLR_CFG_DIR="/sandbox/tutorial-files/770/solr"
SOLR_CFG_BASE_LINK=https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-customer-sentiment-analysis-application/application/setup/add-solr/cfg-files

solr_cfg_file=(
example-collection
solr-cloud
solr-config-env
solr-hdfs
solr-log4j
solr-ssl
)
# For Loop to download each solr config file specified in solr config array
for (( i=0; i<${#solr_cfg_file[@]}; i++ ))
do
  echo "Downloading SOLR: ${solr_cfg_file[$i]}"
  wget $SOLR_CFG_BASE_LINK/${solr_cfg_file[$i]}.xml -O $SOLR_CFG_DIR/rest-install/conf/${solr_cfg_file[$i]}.xml
done

echo "Installing SOLR via Ambari Install REST API Calls"
# Verify "Ambari Infra Solr" isn't running before installing
INFRA_STATE=$(check_service_state $HDP AMBARI_INFRA)
if [[ $INFRA_STATE == *"STARTED" ]]
then
  # Since Ambari Infra is STARTED, we need to turn it off before installing Apache SOLR Standalone
  wait_for_service_to_stop $HDP AMBARI_INFRA
fi

# Verify "Ambari Infra Solr" is off, then install standalone Solr Service
if [[ $INFRA_STATE == *"INSTALLED"* ]]
then
  # Since Ambari Infra Solr is INSTALLED, but not running, we can proceed with Solr Installation
  add_service $HDP SOLR
  WAS_SOLR_ADDED=$(check_if_service_added $HDP SOLR)
  if [[ $WAS_SOLR_ADDED == *"SOLR"* ]]
  then
    # Add components to SOLR service
    # The component has been added according to the components element in JSON output
    add_components_to_service $HDP SOLR

    # Set the configurations for new SOLR Service
    # According to previous Install that had Solr service, we need 6 ambari config files for Solr

    # Read config files from solr_cfg_file list and apply those configurations via Ambari REST API Calls
    for (( i=0; i<${#} ))
    do
      echo "Reading and Applying Configurations for Solr: ${solr_cfg_file[$i]}"
      read_config_file $HDP ${solr_cfg_file[$i]}.xml
      apply_configuration $HDP ${solr_cfg_file[$i]}
    done

    # Create host components
    # Define which nodes in the cluster the service will run on
    # "Install hosts component on MASTER_DNS," located on HOST due to single node cluster
    # After command is run, state should be in INIT
    add_component_to_host $HDP SOLR

    # Install SOLR Service
    # In Ambari, the install can be observed, once the command is run
    # Final status that should be observed is SOLR installed on 1 client and 6 mandatory config files should be available
    install_service $HDP SOLR
  fi
else
  echo "Since AMBARI INFRA is not STOPPED, need to stop service to before installing SOLR"
  wait_for_service_to_stop $HDP AMBARI_INFRA
fi

echo "Configuring Solr to Recognize Tweet's Timestamp Format"
# Change to Solr user
su solr
cp -r /opt/lucidworks-hdpsearch/solr/server/solr/configsets/data_driven_schema_configs \
/opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config

echo "Insert New Config for Solr to Recognize tweet's Timestamp Format"
sed -i.bak '/<arr name="format">/a   <str>EEE MMM d HH:mm:ss Z yyyy</str>' \
/opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config/conf/solrconfig.xml

sed -i.bak 's/<str>EEE MMM d HH:mm:ss Z yyyy<\/str>/        <str>EEE MMM d HH:mm:ss Z yyyy<\/str>/' \
/opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config/conf/solrconfig.xml

# Exiting Solr user
exit

echo "Modifying SOLRS default.json, so SOLR can connect to Banana Dashboard"
BANANA_DASHBOARD_PATH=/opt/lucidworks-hdpsearch/solr/server/solr-webapp/webapp/banana/app/dashboards
mv $BANANA_DASHBOARD_PATH/default.json $BANANA_DASHBOARD_PATH/default.json.orig
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-customer-sentiment-analysis-application/application/setup/conf-solr/default.json \
-O $BANANA_DASHBOARD_PATH/default.json
