---
title: Sandbox Docs - HDP 3.0.1
---

# Sandbox Docs - HDP 3.0.1

## Outline

- [Release Notes](#release-notes)
- [Behavior Changes](#behavior-changes)
- [Known Issues](#known-issues)
- [Limitations](#limitations)
- [System Information](#system-information)
  - [Databases Used](#databases-used)
  - [HDP Supported Components Not Installed](#hdp-supported-components-not-installed)
  - [Newly Added HDP Supported Packages](#newly-added-hdp-supported-packages)
- [HDP Services Started Automatically on Startup](#hdp-services-started-automatically-on-startup)
- [HDP Services Not Started Automatically on Startup](#hdp-services-not-started-automatically-on-startup)
- [Further Reading](#further-reading)

## Release Notes

November 2018

- The VirtualBox and VMWare releases of the HDP sandbox had their OS-level packages updated, including a version update to Docker 18.03.0

- General Availability Sandbox was tested with the following VMWare, VirtualBox, and Docker versions:
  - **VMWare Fusion** Version 10.1.3 (9472307)
  - **VirtualBox** Version 5.2.22 r126460 (Qt5.6.3)
  - **Docker** _(MAC/LINUX):_ Docker version: 18.06.1-ce. _(WNDOWS):_ Docker version: 18.03.0-ce.

- Image MD5 Checksums:
  - VirtualBox – **cc17e47c3ada7137edb550d26fe0bd49**
  - VMware – **5114f5731fae0654bcf8f4cd2ca5b827**
  - Docker Deploy Script - **fd1a56c3260291818b6eacbc598dfe72**

- HDP Stack and Ambari: The Sandbox uses the following versions of Ambari and HDP stack. Please use the following release note links provided to view Ambari and HDP stack specific information.

  - HDP 3.0.1.0 Version 3.0.1.0-187
    - [HDP 3.0.1 Product Release Notes](https://docs.hortonworks.com/HDPDocuments/HDP3/HDP-3.0.1/release-notes/content/relnotes.html)
  - Ambari Version 2.7.1.0-169
    - [Ambari 2.7.1.0 Release Notes](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.1.0/bk_ambari-release-notes/content/ch_relnotes-ambari-2.7.1.0.html)
  - Data Analytics Studio Version 1.0.2.1.0.2.0-6
    - [DAS Release Notes](https://docs.hortonworks.com/HDPDocuments/DAS/DAS-1.1.0/release-notes/das-release-notes.pdf)

## Behavior Changes

- Connected Data Architecture is disabled by default, it will remain disabled until further notice
- Hive View 2.0 has been replaced with Data Analytics Studio
- UI/UX improvements included in Ambari 2.7.1
- Ambari Database changed to external PostgreSQL 9.6 as DAS is dependent on PostgreSQL
- Ambari Infra is now Ambari Infra Solr
- Pig View has been removed
- Tez View has been removed
- Hive is now in a separate catalog from all other services. In order to use Hive along with other services a [HiveWarehouseConnector](https://docs.hortonworks.com/HDPDocuments/HDP3/HDP-3.0.1/integrating-hive/content/hive_hivewarehouseconnector_for_handling_apache_spark_data.html) is needed
- **Hive Warehouse** directory `/apps/hive/warehouse/` has been split into two new locations
  - **Hive Managed Tables:** `/warehouse/tablespace/managed/hive`
  - **User Managed Tables:** `/warehouse/tablespace/external/hive`
- Hive JDBC Standalone Jar Download now available from Hive Quick Links in Ambari

## Known Issues

- Docker version of Sandbox for Windows is not compatible with Docker version 18.06.1-ce. Users deploying the Sandbox using Docker on Windows must use Docker [version: 18.03.0-ce](https://docs.docker.com/docker-for-windows/release-notes/#docker-community-edition-18030-ce-win59-2018-03-26).

## Limitations

This is a list of common limitations along with their workarounds.

- Pig Views is no longer a part of HDP, Pig scripts are interpreted using Grub. Additionally, a [Zeppelin Pig interpreter](https://zeppelin.apache.org/docs/0.7.0/interpreter/pig.html) can be used
- LLAP not enabled by default, Hive is used without LLAP

## System Information

Operating System and Java versions installed on the Sandbox.

- OS Version (HDP container)
  - CentOS release 7.5.1804 (Core)
  - Java Version (docker container)
  - openJDK version “1.8.0.191”
  - OpenJDK Runtime Environment (build 1.8.0_191-b12)
  - OpenJDK 64-Bit Server VM (build 25.191-b12, mixed mode)
  - Python 2.7.5
  - PostgreSQL 9.6.11
  - MySQL server 5.7.24
  - MySQL connector 5.1.25-3
- OS Version (Hosting Virtual Machine)
  - CentOS Linux release 7.2.1511 (Core)
  - Docker Version 18.03.0-ce, build 0520e24

Image File Sizes:

- VMware - 22.1 GB
- VirtualBox - 22.1 GB
- Docker - 21.2 GB

### Databases Used

These are a list of databases used within Sandbox along with the corresponding HDP components that use them.

- Ambari: Postgres
- Hive Metastore : MySQL
- Ranger: MySQL
- Oozie: derby (embedded)

### HDP Supported Components Not Installed

These components are offered by the Hortonworks Data Platform, but not included in the Sandbox.

- Apache Accumulo
- Apache Mahout
- Apache Calcite
- Apache DataFu

### Newly Added HDP Supported Packages

- Data Analytics Studio 1.0.2.1.0.2.0-6

### Deprecated Services

The following services are deprecated on the Hortonworks Data Platform, as well as the Sandbox.

- Apache Falcon
  - Notes: Marked deprecated as of HDP 2.6.0 and has been removed from HDP 3.0.0 onward.
- Apache Flume
  - Notes: Marked Deprecated as of HDP 2.6.0 and has been removed from HDP 3.0.0 onward, consider HDF as an alternative for Flume use cases.
- Apache Mahout:
  - Notes: Marked deprecated as of HDP 2.6.0 and has been removed from HDP 3.0.0 onward.
- Apache Slider
  - Notes: Marked Deprecated as of HDP 2.6.0 and has been removed from HDP 3.0.0 onward.

## HDP Services Started Automatically on Startup

When the virtual machine is booted up, the following services are started. If not specified, assume all are java processes. The users that launch the process are the corresponding names of the component. The processes are listed with their main class.

- Ambari
  - AmbariServer - org.apache.ambari.server.controller.AmbariServer run as root user
- Ambari Agent (non java process)
- HDFS
  - Portmap - org.apache.hadoop.portmap.Portmap
  - NameNode - org.apache.hadoop.hdfs.server.namenode.NameNode
  - DataNode - org.apache.hadoop.hdfs.server.datanode.DataNode
- Nfs
  - Portmap - Unlike the other processes that are launched by HDFS user, these are run as root user.
  - The nfs process doesn’t show up as a name for jps output
- Hive
  - RunJar - webhcat - org.apache.hadoop.util.RunJar Run as hcat user
  - RunJar - metastore - org.apache.hadoop.util.RunJar
  - RunJar - hiveserver2 - org.apache.hadoop.util.RunJar
- Mapreduce2
  - JobHistoryServer - org.apache.hadoop.mapreduce.v2.hs.JobHistoryServer
  - mapred is the user used to launch this process
- Oozie
  - Bootstrap - org.apache.catalina.startup.Bootstrap
- Ranger
  - UnixAuthenticationService - org.apache.ranger.authentication.UnixAuthenticationService Run as root user
  - EmbededServer - org.apache.ranger.server.tomcat.EmbeddedServer
- Spark2
  - HistoryServer - org.apache.spark.deploy.history.HistoryServer
  - Livy server run as livy
  - Thrift server - org.apache.spark.deploy.SparkSubmit run as hive user
- YARN
  - ApplicationHistoryServer - org.apache.hadoop.yarn.server.applicationhistoryservice.ApplicationHistoryServer
  - ResourceManager - org.apache.hadoop.yarn.server.resourcemanager.ResourceManager
  - NodeManager - org.apache.hadoop.yarn.server.nodemanager.NodeManager
- Zookeeper
  - QuorumPeerMain - org.apache.zookeeper.server.quorum.QuorumPeerMain
- Zeppelin Notebook
  - ZeppelinServer - org.apache.zeppelin.server.ZeppelinServer
- Data Analytics Studio

## HDP Services Not Started Automatically on Startup

Because of the limited resources available in the sandbox virtual machine environment, the following services are in maintenance mode and will not automatically start. To fully use these services, you must allocate more memory to the sandbox virtual machine. If you want these services to automatically start, turn off maintenance mode. The processes are listed with their main class.

- Ambari Metrics
- Atlas
  - Main - org.apache.atlas.Main
- HDFS
  - SecondaryNameNode - org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode
  - Since on a single node, secondary namenode is not needed, it is not started.
- HBase
  - HRegionServer - org.apache.hadoop.hbase.regionserver.HRegionServer
  - HMaster - org.apache.hadoop.hbase.master.HMaster
- Kafka
  - Kafka – kafka.Kafka
- Knox
  - gateway.jar - /usr/hdp/current/knox-server/bin/gateway.jar
  - ldap.jar - /usr/hdp/current/knox-server/bin/ldap.jar This process is a mini ldap server
- Druid
  - org.sparklinedata.druid
- Superset
- Storm
  - supervisor - backtype.storm.daemon.supervisor
  - nimbus - backtype.storm.daemon.nimbus
  - logviewer - backtype.storm.daemon.logviewer
  - core - backtype.storm.ui.core
  - drpc - backtype.storm.daemon.drpc

## Further Reading

- [Cloudera DataFlow 3.0 Simplifies Development of Streaming Analytics Applications](https://hortonworks.com/press-releases/hortonworks-dataflow-3-0/)
- [Hortonworks Hybrid Data Platforms](https://hortonworks.com/products/data-platforms/)
- [Ambari 2.7.1](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.1.0/bk_ambari-release-notes/content/ch_relnotes-ambari-2.7.1.0.html)
- [HDP Documentation](https://docs.hortonworks.com/HDPDocuments/HDP3/HDP-3.0.1/index.html)
- [Data Analytics Studio](https://hortonworks.com/products/dataplane/data-analytics-studio/)