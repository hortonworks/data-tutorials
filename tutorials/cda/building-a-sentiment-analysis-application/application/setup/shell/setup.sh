#!/bin/bash

##
# Run Script from Guest VBox VM, which has direct access to docker HDF/HDP Sandbox Containers
# Setups Development Environment for
# Building Customer Sentiment Analysis Application on HDF/HDP
#
# Ref: https://stackoverflow.com/questions/22107610/shell-script-run-function-from-script-over-ssh
##
HDF_SHELL_PASS="hadoop"
HDF_AMBARI_USER="admin"
HDF_AMBARI_PASS="admin"
HDF_CLUSTER_NAME="Sandbox"
HDF_HOST="sandbox-hdf.hortonworks.com"
HDF_MASTER_DNS=$HDF_HOST
HDF_SLAVE_DNS=$HDF_HOST
HDF="hdf-sandbox"

HDP_SHELL_PASS="greenhadoop"
HDP_AMBARI_USER="raj_ops"
HDP_AMBARI_PASS="raj_ops"
HDP_CLUSTER_NAME="Sandbox"
HDP_HOST="sandbox-hdp.hortonworks.com"
HDP_MASTER_DNS=$HDP_HOST
HDP_SLAVE_DNS=$HDP_HOST
HDP="hdp-sandbox"

################################################################################
# Ambari REST Call Functions

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
function wait_for_service_start()
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
function wait_for_service_stop()
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
# Ambari REST Call Functions
################################################################################

################################################################################
# Setup the Data-In-Motion Platform (HDF 3.1.1 Sandbox)
function setup_nifi()
{
  # Install Network Time Protocol
  yum install -y ntp
  service ntpd stop
  # Use the NTPDATE to synchronize CentOS7 sysclock within few ms of UTC
  ntpdate pool.ntp.org
  service ntpd start
}

# Setup NiFi Service to ingest twitter data wout auth error on HDF Sandbox
sshpass -p "$HDF_SHELL_PASS" ssh "-o StrictHostKeyChecking=no" root@$HDF_HOST << EOF
$(typeset -f setup_nifi)
setup_nifi
EOF
# Setup the Data-In-Motion Platform (HDF 3.1.1 Sandbox)
################################################################################

################################################################################
# SOLR Configuration Files for Ambari (HDP 2.6.5 Sandbox)

# SOLR Config files from HDP Sandbox that had SOLR Installed
#/var/lib/ambari-server/resources/common-services/SOLR/5.5.2.2.5/configuration
# - example-collection.xml
# - solr-cloud.xml
# - solr-config-env.xml
# - solr-hdfs.xml
# - solr-log4j.xml
# - solr-ssl.xml

tee -a ~/example-collection.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>solr_collection_sample_create</name>
        <value>true</value>
        <description>True to create a sample collection when Solr is deployed</description>
        <display-name>Create sample collection</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>

    <property>
        <name>solr_collection_sample_name</name>
        <value>collection1</value>
        <description>Solr sample collection name. Mandatory</description>
        <display-name>Sample collection name</display-name>
    </property>

    <property>
        <name>solr_collection_sample_config_directory</name>
        <value>data_driven_schema_configs</value>
        <description>Solr sample collection configurations directory. Mandatory
            This directory path is relative to /opt/lucidworks-hadoop/solr/server/solr/configset.
            It must contain at least solrconfig.xml and schema.xml
        </description>
        <display-name>Solr configuration directory</display-name>
    </property>

    <property>
        <name>solr_collection_sample_shards</name>
        <value>2</value>
        <description>Number of Solr shards, for details refer to
            (https://cwiki.apache.org/confluence/display/solr/Shards+and+Indexing+Data+in+SolrCloud)
        </description>
        <value-attributes>
            <type>int</type>
        </value-attributes>
        <display-name>Number of shards</display-name>
    </property>

    <property>
        <name>solr_collection_sample_replicas</name>
        <value>1</value>
        <description>Number of Solr replicas, for details refer to
            (https://cwiki.apache.org/confluence/display/solr/NRT%2C+Replication%2C+and+Disaster+Recovery+with+SolrCloud)
        </description>
        <value-attributes>
            <type>int</type>
        </value-attributes>
        <display-name>Number of replicas</display-name>
    </property>
</configuration>
EOF

tee -a ~/solr-cloud.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>solr_cloud_enable</name>
        <value>true</value>
        <description>Whether Solr should be started in Cloud mode</description>
        <display-name>Enable SolrCloud mode</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>

    <property>
        <name>solr_cloud_zk_directory</name>
        <value>/solr</value>
        <description>ZooKeeper directory (chroot) for shared Solr files</description>
        <display-name>ZooKeeper root directory for Solr files</display-name>
    </property>
</configuration>
EOF

tee -a ~/solr-config-env.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>solr_config_port</name>
        <value>8983</value>
        <description>Solr TCP port</description>
        <value-attributes>
            <type>int</type>
        </value-attributes>
        <display-name>Solr port</display-name>
    </property>

    <property>
        <name>solr_config_memory</name>
        <value>512m</value>
        <description>
            Sets the min (-Xms) and max (-Xmx) heap size for the
            JVM, such as: -m 4g
            results in: -Xms4g -Xmx4g; by default, this
            script sets the heap
            size to 512m
        </description>
        <display-name>Solr heap size for the JVM</display-name>
    </property>

    <property>
        <name>solr_config_conf_dir</name>
        <value>/etc/solr/conf</value>
        <description>Solr conf directory</description>
        <value-attributes>
            <type>directory</type>
        </value-attributes>
        <display-name>Solr configuration directory</display-name>
    </property>

    <property>
        <name>solr_config_data_dir</name>
        <value>/etc/solr/data_dir</value>
        <description>Solr data directory</description>
        <value-attributes>
            <type>directory</type>
        </value-attributes>
        <display-name>Solr server directory</display-name>
    </property>

    <property>
        <name>solr_config_pid_dir</name>
        <value>/var/run/solr</value>
        <description>Solr PID directory</description>
        <value-attributes>
            <type>directory</type>
        </value-attributes>
        <display-name>Solr PID directory</display-name>
    </property>

    <property>
        <name>solr_config_log_dir</name>
        <value>/var/log/solr</value>
        <description>Solr log directory</description>
        <value-attributes>
            <type>directory</type>
        </value-attributes>
        <display-name>Solr log directory</display-name>
    </property>

    <property>
        <name>solr_config_service_log_dir</name>
        <value>/var/log/service_solr</value>
        <description>Solr service log directory</description>
        <value-attributes>
            <type>directory</type>
        </value-attributes>
        <display-name>Solr service log directory</display-name>
    </property>

    <property>
        <name>solr_config_user</name>
        <value>solr</value>
        <property-type>USER</property-type>
        <description>User for Solr service</description>
        <value-attributes>
            <type>user</type>
            <overridable>false</overridable>
        </value-attributes>
        <display-name>Solr user</display-name>
    </property>

    <property>
        <name>solr_config_group</name>
        <value>solr</value>
        <property-type>GROUP</property-type>
        <description>Group for Solr service</description>
        <value-attributes>
            <type>group</type>
            <overridable>false</overridable>
        </value-attributes>
        <display-name>Solr group</display-name>
    </property>

    <!-- solr.in.sh -->
    <property>
        <name>content</name>
        <description>This is the jinja template for solr.in.sh file</description>
        <value>
            # Licensed to the Apache Software Foundation (ASF) under one or more
            # contributor license agreements.  See the NOTICE file distributed with
            # this work for additional information regarding copyright ownership.
            # The ASF licenses this file to You under the Apache License, Version 2.0
            # (the "License"); you may not use this file except in compliance with
            # the License.  You may obtain a copy of the License at
            #
            #     http://www.apache.org/licenses/LICENSE-2.0
            #
            # Unless required by applicable law or agreed to in writing, software
            # distributed under the License is distributed on an "AS IS" BASIS,
            # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            # See the License for the specific language governing permissions and
            # limitations under the License.

            # By default the script will use JAVA_HOME to determine which java
            # to use, but you can set a specific path for Solr to use without
            # affecting other Java applications on your server/workstation.
            #SOLR_JAVA_HOME=""

            # Increase Java Heap as needed to support your indexing / query needs
            SOLR_HEAP="512m"

            # Expert: If you want finer control over memory options, specify them directly
            # Comment out SOLR_HEAP if you are using this though, that takes precedence
            #SOLR_JAVA_MEM="-Xms512m -Xmx512m"

            # Enable verbose GC logging
            GC_LOG_OPTS="-verbose:gc -XX:+PrintHeapAtGC -XX:+PrintGCDetails \
            -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime"

            # These GC settings have shown to work well for a number of common Solr workloads
            GC_TUNE="-XX:NewRatio=3 \
            -XX:SurvivorRatio=4 \
            -XX:TargetSurvivorRatio=90 \
            -XX:MaxTenuringThreshold=8 \
            -XX:+UseConcMarkSweepGC \
            -XX:+UseParNewGC \
            -XX:ConcGCThreads=4 -XX:ParallelGCThreads=4 \
            -XX:+CMSScavengeBeforeRemark \
            -XX:PretenureSizeThreshold=64m \
            -XX:+UseCMSInitiatingOccupancyOnly \
            -XX:CMSInitiatingOccupancyFraction=50 \
            -XX:CMSMaxAbortablePrecleanTime=6000 \
            -XX:+CMSParallelRemarkEnabled \
            -XX:+ParallelRefProcEnabled"

            {{solr_hdfs_prefix}}GC_TUNE="$GC_TUNE -XX:MaxDirectMemorySize=20g -XX:+UseLargePages"

            # Set the ZooKeeper connection string if using an external ZooKeeper ensemble
            # e.g. host1:2181,host2:2181/chroot
            # Leave empty if not using SolrCloud
            #ZK_HOST=""

            # Set the ZooKeeper client timeout (for SolrCloud mode)
            #ZK_CLIENT_TIMEOUT="15000"

            # By default the start script uses "localhost"; override the hostname here
            # for production SolrCloud environments to control the hostname exposed to cluster state
            SOLR_HOST="{{solr_hostname}}"

            # By default the start script uses UTC; override the timezone if needed
            #SOLR_TIMEZONE="UTC"

            # Set to true to activate the JMX RMI connector to allow remote JMX client applications
            # to monitor the JVM hosting Solr; set to "false" to disable that behavior
            # (false is recommended in production environments)
            ENABLE_REMOTE_JMX_OPTS="false"

            # The script will use SOLR_PORT+10000 for the RMI_PORT or you can set it here
            # RMI_PORT=18983

            # Set the thread stack size
            SOLR_OPTS="$SOLR_OPTS -Xss256k"

            # Anything you add to the SOLR_OPTS variable will be included in the java
            # start command line as-is, in ADDITION to other options. If you specify the
            # -a option on start script, those options will be appended as well. Examples:
            #SOLR_OPTS="$SOLR_OPTS -Dsolr.autoSoftCommit.maxTime=3000"
            #SOLR_OPTS="$SOLR_OPTS -Dsolr.autoCommit.maxTime=60000"
            #SOLR_OPTS="$SOLR_OPTS -Dsolr.clustering.enabled=true"

            # Location where the bin/solr script will save PID files for running instances
            # If not set, the script will create PID files in $SOLR_TIP/bin
            SOLR_PID_DIR={{solr_config_pid_dir}}

            # Path to a directory for Solr to store cores and their data. By default, Solr will use server/solr
            # If solr.xml is not stored in ZooKeeper, this directory needs to contain solr.xml
            SOLR_HOME={{solr_config_data_dir}}

            # Solr provides a default Log4J configuration properties file in server/resources
            # however, you may want to customize the log settings and file appender location
            # so you can point the script to use a different log4j.properties file
            LOG4J_PROPS={{solr_config_conf_dir}}/log4j.properties

            # Location where Solr should write logs to; should agree with the file appender
            # settings in server/resources/log4j.properties
            SOLR_LOGS_DIR={{solr_config_log_dir}}

            # Sets the port Solr binds to, default is 8983
            #SOLR_PORT=8983

            # Uncomment to set SSL-related system properties
            # Be sure to update the paths to the correct keystore for your environment
            {{solr_ssl_prefix}}SOLR_SSL_KEY_STORE={{ solr_ssl_key_store }}
            {{solr_ssl_prefix}}SOLR_SSL_KEY_STORE_PASSWORD={{ solr_ssl_key_store_password }}
            {{solr_ssl_prefix}}SOLR_SSL_TRUST_STORE={{ solr_ssl_trust_store }}
            {{solr_ssl_prefix}}SOLR_SSL_TRUST_STORE_PASSWORD={{ solr_ssl_trust_store_password }}
            {{solr_ssl_prefix}}SOLR_SSL_NEED_CLIENT_AUTH={{ solr_ssl_need_client_auth }}
            {{solr_ssl_prefix}}SOLR_SSL_WANT_CLIENT_AUTH={{ solr_ssl_want_client_auth }}

            # Uncomment if you want to override previously defined SSL values for HTTP client
            # otherwise keep them commented and the above values will automatically be set for HTTP clients
            #SOLR_SSL_CLIENT_KEY_STORE=
            #SOLR_SSL_CLIENT_KEY_STORE_PASSWORD=
            #SOLR_SSL_CLIENT_TRUST_STORE=
            #SOLR_SSL_CLIENT_TRUST_STORE_PASSWORD=

            # Settings for authentication
            {{solr_kerberos_prefix}}SOLR_AUTHENTICATION_CLIENT_CONFIGURER=org.apache.solr.client.solrj.impl.Krb5HttpClientConfigurer
            {{solr_kerberos_prefix}}SOLR_AUTHENTICATION_OPTS="-Djava.security.auth.login.config={{solr_kerberos_jaas_config}} \
            {{solr_kerberos_prefix}}-Dsolr.kerberos.cookie.domain={{solr_kerberos_cookie_domain}} \
            {{solr_kerberos_prefix}}-Dsolr.kerberos.cookie.portaware=true \
            {{solr_kerberos_prefix}}-Dsolr.kerberos.principal={{solr_spnego_principal}} \
            {{solr_kerberos_prefix}}-Dsolr.kerberos.keytab={{solr_spnego_keytab}}"
        </value>
        <value-attributes>
            <type>content</type>
        </value-attributes>
    </property>
</configuration>
EOF

tee -a ~/solr-hdfs.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>solr_hdfs_enable</name>
        <value>true</value>
        <description>Enable support for Solr on HDFS</description>
        <display-name>Enable support for Solr on HDFS</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>

    <property>
        <name>solr_hdfs_directory</name>
        <value>/solr</value>
        <description>HDFS directory for Solr indexes</description>
        <display-name>HDFS directory for Solr indexes</display-name>
    </property>

    <property>
        <name>solr_hdfs_delete_write_lock_files</name>
        <value>false</value>
        <description>Delete write.lock files on HDFS</description>
        <display-name>Delete write.lock files on HDFS</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>
</configuration>
EOF

tee -a ~/solr-log4j.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration supports_final="false" supports_adding_forbidden="true">

  <property>
    <name>content</name>
    <description>Custom log4j.properties</description>
    <value>
      # Licensed to the Apache Software Foundation (ASF) under one or more
      # contributor license agreements.  See the NOTICE file distributed with
      # this work for additional information regarding copyright ownership.
      # The ASF licenses this file to You under the Apache License, Version 2.0
      # (the "License"); you may not use this file except in compliance with
      # the License.  You may obtain a copy of the License at
      #
      #     http://www.apache.org/licenses/LICENSE-2.0
      #
      # Unless required by applicable law or agreed to in writing, software
      # distributed under the License is distributed on an "AS IS" BASIS,
      # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      # See the License for the specific language governing permissions and
      # limitations under the License.

      #  Logging level
      solr.log={{solr_config_log_dir}}
      #log4j.rootLogger=INFO, file, CONSOLE
      log4j.rootLogger=INFO, file

      log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender

      log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
      log4j.appender.CONSOLE.layout.ConversionPattern=%-4r [%t] %-5p %c %x [%X{collection} %X{shard} %X{replica} %X{core}] \u2013 %m%n

      #- size rotation with log cleanup.
      log4j.appender.file=org.apache.log4j.RollingFileAppender
      log4j.appender.file.MaxFileSize=10MB
      log4j.appender.file.MaxBackupIndex=9

      #- File to log to and log format
      log4j.appender.file.File=${solr.log}/solr.log
      log4j.appender.file.layout=org.apache.log4j.PatternLayout
      log4j.appender.file.layout.ConversionPattern=%d{ISO8601} [%t] %-5p [%X{collection} %X{shard} %X{replica} %X{core}] %C (%F:%L) - %m%n

      log4j.logger.org.apache.zookeeper=WARN
      log4j.logger.org.apache.hadoop=WARN

      # set to INFO to enable infostream log messages
      log4j.logger.org.apache.solr.update.LoggingInfoStream=OFF
    </value>
    <value-attributes>
      <type>content</type>
      <show-property-name>false</show-property-name>
    </value-attributes>
  </property>
</configuration>
EOF

tee -a ~/solr-ssl.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>solr_ssl_enable</name>
        <value>false</value>
        <description>Enable SSL support</description>
        <display-name>Enable SSL support</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>

    <property>
        <name>solr_ssl_key_store</name>
        <value>etc/solr-ssl.keystore.jks</value>
        <description>SSL keystore file</description>
        <display-name>SSL keystore file</display-name>
    </property>

    <property>
        <name>solr_ssl_key_store_password</name>
        <value>secret</value>
        <property-type>PASSWORD</property-type>
        <description>SSL keystore password</description>
        <value-attributes>
            <type>password</type>
            <overridable>false</overridable>
        </value-attributes>
        <display-name>SSL keystore password</display-name>
    </property>

    <property>
        <name>solr_ssl_trust_store</name>
        <value>etc/solr-ssl.keystore.jks</value>
        <description>SSL truststore file</description>
        <display-name>SSL truststore file</display-name>
    </property>

    <property>
        <name>solr_ssl_trust_store_password</name>
        <value>secret</value>
        <property-type>PASSWORD</property-type>
        <description>SSL truststore password</description>
        <value-attributes>
            <type>password</type>
            <overridable>false</overridable>
        </value-attributes>
        <display-name>SSL truststore password</display-name>
    </property>

    <property>
        <name>solr_ssl_need_client_auth</name>
        <value>false</value>
        <description>Need client authentication</description>
        <display-name>Need client authentication</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>

    <property>
        <name>solr_ssl_want_client_auth</name>
        <value>false</value>
        <description>Want client authentication</description>
        <display-name>Want client authentication</display-name>
        <value-attributes>
            <type>boolean</type>
            <overridable>false</overridable>
        </value-attributes>
    </property>
</configuration>
EOF

# - example-collection.xml
# - solr-cloud.xml
# - solr-config-env.xml
# - solr-hdfs.xml
# - solr-log4j.xml
# - solr-ssl.xml
solr_cfg_file=(
"~/example-collection.xml"
"~/solr-cloud.xml"
"~/solr-config-env.xml"
"~/solr-hdfs.xml"
"~/solr-log4j.xml"
"~/solr-ssl.xml"
)
for (( i=0; i<${#solr_cfg_file[@]}; i++ ))
do
  sshpass -p "$HDP_SHELL_PASS" scp -P 2222 "-o StrictHostKeyChecking=no" ${solr_cfg_file[$i]} root@$HDP_HOST:~/
done

# SOLR Configuration Files for Ambari (HDP 2.6.5 Sandbox)
################################################################################



################################################################################
# Setup the Data-At-Rest Platform (HDP 2.6.5 Sandbox)
function setup_maven()
{
  # Download apache maven
  # wget http://mirrors.koehn.com/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz \
  # -O ~/apache-maven-3.5.4-bin.tar.gz
  # # Extract maven
  # tar xvf apache-maven-3.5.4-bin.tar.gz
  # # Set variables that will be added to .bash_profile
  # M2_HOME=/usr/local/apache-maven/apache-maven-3.5.4
  # M2=$M2_HOME/bin
  # PATH=$M2:$PATH
  # echo "export M2_HOME=$M2_HOME" | tee -a ~/.bash_profile
  # echo "export M2=$M2" | tee -a ~/.bash_profile
  # echo "export PATH=$M2:$PATH" | tee -a ~/.bash_profile
  # Checking for maven, installing if missing
  wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
  yum install -y apache-maven
  # Verify maven version
  mvn -version
}
function setup_hive()
{
  # Clone the JsonSerDe source
  git clone https://github.com/rcongiu/Hive-JSON-Serde
  cd Hive-JSON-Serde
  # Compile JsonSerDe source to create JsonSerDe library jar file
  mvn -Phdp23 clean package
  # Give JsonSerDe library jar file to Hive and Hive2 library
  cp json-serde/target/json-serde-1.3.9-SNAPSHOT-jar-with-dependencies.jar /usr/hdp/2.6.0.3-8/hive/lib
  cp json-serde/target/json-serde-1.3.9-SNAPSHOT-jar-with-dependencies.jar /usr/hdp/2.6.0.3-8/hive2/lib
  # Restart (stop/start) Hive via Ambari REST Call
  # $1: HDF_HOST or HDP_HOST
  # $2: HDF/HDP Cluster Name
  # $3: HDF/HDP User Login Credential
  # $4: HDF/HDP Pass Login Credential
  # $5: Service
  wait_for_service_stop $HDP "HIVE"
  wait_for_service_start $HDP "HIVE"
}
# Setup Hive Service to be able to read JSON data on HDP Sandbox
sshpass -p "$HDP_SHELL_PASS" ssh "-o StrictHostKeyChecking=no" root@$HDP_HOST << EOF
$(typeset -f setup_maven)
setup_maven
$(typeset -f setup_hive)
setup_hive
EOF

function setup_hdfs_for_hive()
{
  # Create /tmp/tweets_staging directory ahead of time
  sudo -u hdfs hdfs dfs -mkdir -p /tmp/tweets_staging
  # Change HDFS ownership of tweets_staging dir to maria_dev
  sudo -u hdfs hdfs dfs -chown -R maria_dev /tmp/tweets_staging
  # Change HDFS tweets_staging dir permissions to everyone
  sudo -u hdfs hdfs dfs -chmod -R 777 /tmp/tweets_staging
  # Create new /tmp/data/tables directory inside /tmp dir
  sudo -u hdfs hdfs dfs -mkdir -p /tmp/data/tables
  # Set permissions for tables dir
  sudo -u hdfs hdfs dfs -chmod 777 /tmp/data/tables
  # Inside tables parent dir, create time_zone_map dir
  sudo -u hdfs hdfs dfs -mkdir /tmp/data/tables/time_zone_map
  # Inside tables parent dir, create dictionary dir
  sudo -u hdfs hdfs dfs -mkdir /tmp/data/tables/dictionary
  # Download time_zone_map.tsv file on local file system(FS)
  wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/hdp/analyzing-social-media-and-customer-sentiment-with-apache-nifi-and-hdp-search/assets/time_zone_map.tsv
  # Copy time_zone_map.tsv from local FS to HDFS
  sudo -u hdfs hdfs dfs -put time_zone_map.tsv /tmp/data/tables/time_zone_map/
  # Download dictionary.tsv file on local file system
  wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/hdp/analyzing-social-media-and-customer-sentiment-with-apache-nifi-and-hdp-search/assets/dictionary.tsv
  # Copy dictionary.tsv from local FS to HDFS
  sudo -u hdfs hdfs dfs -put dictionary.tsv /tmp/data/tables/dictionary/
}

# Setup HDFS Service for Hive Data Analysis
sshpass -p "$HDP_SHELL_PASS" ssh "-o StrictHostKeyChecking=no" root@$HDP_HOST << EOF
$(typeset -f setup_hdfs_for_hive)
setup_hdfs_for_hive
EOF

function setup_zeppelin_spark()
{
  wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/hdp/sentiment-analysis-with-apache-spark/assets/Sentiment%20Analysis.json
  # Import Sentiment Analysis Notebook to Zeppelin
  curl -X POST http://$HDP_HOST:9995/api/notebook/import \
  -d @'Sentiment%20Analysis.json'
  # Clone Scala Spark Streaming Application (Dependency needs to be moved to Hortonworks)
  git clone https://github.com/Gregw135/sentimentAnalysis
  # Install SBT
  cd sentimentAnalysis
  curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
  yum install sbt
}
# Setup Zeppelin and Spark Dependency
sshpass -p "$HDP_SHELL_PASS" ssh "-o StrictHostKeyChecking=no" root@$HDP_HOST << EOF
$(typeset -f setup_zeppelin_spark)
setup_zeppelin_spark
EOF

function setup_solr()
{
  # Verify Ambari Infra Solr isn't running, else stop it
  INFRA_STATE=$(check_service_state $HDP "AMBARI_INFRA")
  if [[ $INFRA_STATE == *"STARTED"* ]]
  then
    # Ambari Infra is STARTED, we need to turn it off before installing Apache Solr
    wait_for_service_stop $HDP "AMBARI_INFRA"
  fi

  # Verify Ambari Infra Solr is off, then install standalone Solr Service
  if [[ $INFRA_STATE == *"INSTALLED"* ]]
  then
    # Ambari Infra is INSTALLED, but not running, so lets begin installing Apache Solr
    # Add SOLR Service on HDP Service
    add_service $HDP "SOLR"
    WAS_SOLR_ADDED=$(check_if_service_added $HDP "SOLR")
    if [[ $WAS_SOLR_ADDED == *"SOLR"* ]]
    then
      # Add components to the SOLR service
      # The component has been added according to the components element in JSON output
      add_components_to_service $HDP "SOLR"

      # Create configuration for SOLR
      # 6 ambari configuration files are needed and will be used for SOLR.

      # - example-collection.xml
      # "201 Created" status should be returned
      read_config_file $HDP "example-collection.xml"
      apply_configuration $HDP "example-collection"

      # - solr-cloud.xml
      # "201 Created" status should be returned
      read_config_file $HDP "solr-cloud.xml"
      apply_configuration $HDP "solr-cloud"

      # - solr-config-env.xml
      # "201 Created" status should be returned
      read_config_file $HDP "solr-config-env.xml"
      apply_configuration $HDP "solr-config-env"

      # - solr-hdfs.xml
      # "201 Created" status should be returned
      read_config_file $HDP "solr-hdfs.xml"
      apply_configuration $HDP "solr-hdfs"

      # - solr-log4j.xml
      # "201 Created" status should be returned
      read_config_file $HDP "solr-log4j.xml"
      apply_configuration $HDP "solr-log4j"

      # - solr-ssl.xml
      # "201 Created" status should be returned
      read_config_file $HDP "solr-ssl.xml"
      apply_configuration $HDP "solr-ssl"

      # Create host components
      # Define which nodes in the cluster the service will run on
      # "Install hosts component on MASTER_DNS," located on HOST due to single node cluster
      # After command is run, state should be in INIT
      add_component_to_host $HDP "SOLR"

      # Install SOLR Service
      # In Ambari, the install can be observed, once the command is run
      # Final status that should be observed is SOLR installed on 1 client and 6 mandatory config
      # files should be available
      # $1: HDF_HOST or HDP_HOST
      # $2: HDF/HDP Cluster Name
      # $3: HDF/HDP User Login Credential
      # $4: HDF/HDP Pass Login Credential
      # $5: Service - SOLR, AMBARI_INFRA, exs
      install_service $HDP "SOLR"

      # Now the SOLR Service is ready to use. Could run a service check?
    fi
  else
    echo "AMBARI INFRA is not STOPPED, need to stop service to began installing SOLR"
    wait_for_service_stop $HDP "AMBARI_INFRA"
  fi
  # Configure Apache Solr to recognize tweet's timestamp format
  sudo -u solr cp -r /opt/lucidworks-hdpsearch/solr/server/solr/configsets/data_driven_schema_configs \
  /opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config

  echo "Insert new config for Solr to recognize tweet's timestamp format"
  sudo -u solr sed -i.bak '/<arr name="format">/a   <str>EEE MMM d HH:mm:ss Z yyyy</str>' \
  /opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config/conf/solrconfig.xml

  sudo -u solr sed -i.bak 's/<str>EEE MMM d HH:mm:ss Z yyyy<\/str>/        <str>EEE MMM d HH:mm:ss Z yyyy<\/str>/' \
  /opt/lucidworks-hdpsearch/solr/server/solr/configsets/tweet_config/conf/solrconfig.xml

  # Establish Connection from Solr to Banana Dashboard
  # Backup existing JSON and replace with replacement file
  cd /opt/lucidworks-hdpsearch/solr/server/solr-webapp/webapp/banana/app/dashboards/
  mv default.json default.json.orig
  wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/hdp/analyzing-social-media-and-customer-sentiment-with-apache-nifi-and-hdp-search/assets/default.json
}

# Setup SOLR Service on HDP Sandbox: Install Service,
# Configure for recognizing Tweet timestamp and establishing connection to Banana
sshpass -p "$HDP_SHELL_PASS" ssh "-o StrictHostKeyChecking=no" root@$HDP_HOST << EOF
$(typeset -f setup_solr)
setup_solr
EOF
# Setup the Data-At-Rest Platform (HDP 2.6.5 Sandbox)
################################################################################
echo "Application Development Environment is Setup"
echo "Now Let's build the pipeline to process customer sentiment data"
