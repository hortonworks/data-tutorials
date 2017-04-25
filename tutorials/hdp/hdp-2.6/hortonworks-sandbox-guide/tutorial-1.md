---
title: Hortonworks Sandbox Guide
tutorial-id: 730
platform: hdp-2.6.0
tags: [sandbox, documentation]
---

# Sandbox Docs - HDP 2.6

## Outline

-   [Release Notes](#release-notes)
-   [Behavior Changes](#behavior-changes)
-   [Known Issues](#known-issues)
-   [Limitations](#limitations)
-   [System Informaiton](#system-information)
    -   [Databases Used](#databases-used)
    -   [HDP Supported Components Not Installed](#hdp-supported-components-not-installed)
    -   [Newly Added HDP Supported Packages](#newly-added-hdp-supported-packages)
-   [HDP Services Started Automatically on Startup](#hdp-services-started-automatically-on-startup)
-   [HDP Services Not Started Automatically on Startup](#hdp-services-not-started-automatically-on-startup)
-   [Further Reading](#further-reading)


## Release Notes

Apr 2017

-   Md5 VMware Virtual Appliance - **50aab8be7ef25418d475000045abe571**
-   Md5 Virtualbox Virtual Appliance - **9cb91797dc2a53bf3799007c5c80770e**
-   Md5 Docker - **f1663bbff04721c3b1a32a39fef676e3**
-   HDP Stack and Ambari: The Sandbox uses the following versions of Ambari and HDP stack. Please use the following release note links provided to view Ambari and HDP stack specific information.
    -   [HDP 2.6 Product Release Notes](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.0/bk_release-notes/content/ch_relnotes.html)
    -   [Ambari 2.5 Release Notes](https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.0.3/bk_ambari-release-notes/content/ch_relnotes-ambari-2.5.0.3.html)


## Behavior Changes

-   New splash page
    -   Removed Falcon
    -   Added Workflow Manager


## Known Issues

-   Unable to stop/restart Oozie service using ambari
    -   Works from the command line
-   Atlas Schema Tab Doesn't Appear, So Not Able to Assign Specific Hive Columns an Tag
-   HBase RPC Bindings not configured out of box


## Limitations

This is a list of common limitations along with their workarounds.

-   RMP-3586 - Due to dependency of the underlying OS and Virtual machine application, the following may occur when suspending the virtual machine:
    -   Region Server service for HBase may be stopped when returning back from suspended state. It will need to be restarted.
    -   Ambari Metrics may be stopped when returning back from suspended state since it now uses an embedded HBase.
    -   Workaround: Avoid having to suspend your virtual machine.


## System Informaiton

Operating System and Java versions that the Sandbox has installed.
-   OS Version (docker container)
    -   CentOS release 6.8 (Final)
    -   Java Version (docker container)
    -   openjdk version “1.8.0_111”
    -   OpenJDK Runtime Environment (build 1.8.0_111-b15)
    -   OpenJDK 64-Bit Server VM (build 25.111-b15, mixed mode)
    -   Updated from previous version
-   OS Version (Hosting Virtual Machine)
    -   CentOS Linux release 7.2.1511 (Core)

Image File Sizes:
-   VMware - 10.75 GB
-   Virtualbox - 10.4 GB
-   Docker - 12 GB


### Databases Used

These are a list of databases used within Sandbox along with the corresponding HDP components that use them.

-   Ambari: postgres
-   Hive Metastore : Mysql
-   Ranger: Mysql
-   Oozie: derby (embedded)


### HDP Supported Components Not Installed

These components are offered by the Hortonworks distribution, but not included in the Sandbox.
-   Apache Accumulo
-   Apache Mahout
-   Hue


### Newly Added HDP Supported Packages

These are packages that have recently been included into the Sandbox for this release.
-   Workflow Manager


## HDP Services Started Automatically on Startup

When the virtual machine is booted up, the following services are started. If not specified, assume all are java processes. The users that launch the process are the corresponding names of the component. The processes are listed with their main class.

-   Ambari
    -   AmbariServer - org.apache.ambari.server.controller.AmbariServer run as root user
-   Ambari Agent (non java process)
-   Flume
    -   Application - org.apache.flume.node.Application
-   HDFS
    -   Portmap - org.apache.hadoop.portmap.Portmap
    -   NameNode - org.apache.hadoop.hdfs.server.namenode.NameNode
    -   DataNode - org.apache.hadoop.hdfs.server.datanode.DataNode
-   Nfs
    -   Portmap - Unlike the other processes that are launched by hdfs user, these are run as root user.
    -   The nfs process doesn’t show up as a name for jps output
-   HIVE
    -   RunJar - webhcat - org.apache.hadoop.util.RunJar Run as hcat user
    -   RunJar - metastore - org.apache.hadoop.util.RunJar
    -   RunJar - hiveserver2 - org.apache.hadoop.util.RunJar
-   Mapreduce
    -   JobHistoryServer - org.apache.hadoop.mapreduce.v2.hs.JobHistoryServer
    -   mapred is the user used to launch this process
-   Oozie
    -   Bootstrap - org.apache.catalina.startup.Bootstrap
-   Ranger
    -   UnixAuthenticationService - org.apache.ranger.authentication.UnixAuthenticationService Run as root user
    -   EmbededServer - org.apache.ranger.server.tomcat.EmbeddedServer
-   Spark
    -   HistoryServer - org.apache.spark.deploy.history.HistoryServer
-   YARN
    -   ApplicationHistoryServer - org.apache.hadoop.yarn.server.applicationhistoryservice.ApplicationHistoryServer
    -   ResourceManager - org.apache.hadoop.yarn.server.resourcemanager.ResourceManager
    -   NodeManager - org.apache.hadoop.yarn.server.nodemanager.NodeManager
-   Zookeeper
    -   QuorumPeerMain - org.apache.zookeeper.server.quorum.QuorumPeerMain
-   Zeppelin
    -   ZeppelinServer - org.apache.zeppelin.server.ZeppelinServer


## HDP Services Not Started Automatically on Startup

Because of the limited resources avaialble in the sandbox virtual machine environment, the following services are in maintenance mode and will not automatically start. To fully use these services, you must allocate more memory to the sandbox virtual machine. If you want these services to automatically start, turn off maintenance mode. The processes are listed with their main class.

-   Ambari Infra
-   Ambari Metrics
-   Atlas
    -   Main - org.apache.atlas.Main
-   HDFS
    -   SecondaryNameNode - org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode
    -   Since on a single node, secondary namenode is not needed, it is not started.
-   Falcon
    -   Main - org.apache.falcon.Main
-   HBase
    -   HRegionServer - org.apache.hadoop.hbase.regionserver.HRegionServer
    -   HMaster - org.apache.hadoop.hbase.master.HMaster
-   Kafka
    -   Kafka - kafka.Kafka
-   Knox
    -   gateway.jar - /usr/hdp/current/knox-server/bin/gateway.jar
    -   ldap.jar - /usr/hdp/current/knox-server/bin/ldap.jar This process is a mini ldap server
-   Spark
    -   Livy server run as livy
    -   Thrift Server - org.apache.spark.deploy.SparkSubmit run as hive user
-   Spark2
    -   Livy server run as livy
    -   Thrift server - org.apache.spark.deploy.SparkSubmit run as hive user
-   Storm
    -   supervisor - backtype.storm.daemon.supervisor
    -   nimbus - backtype.storm.daemon.nimbus
    -   logviewer - backtype.storm.daemon.logviewer
    -   core - backtype.storm.ui.core
    -   drpc - backtype.storm.daemon.drpc


## Further Reading
-   <https://hortonworks.com/press-releases/hortonworks-leads-industry-performance-customer-choice-hdp-2-6/>
-   <https://hortonworks.com/products/data-center/hdp/>
-   <https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.0/index.html>
