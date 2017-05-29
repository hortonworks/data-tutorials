---
title: Hortonworks Sandbox Guide
tutorial-id: 730
platform: hdf-2.1.0
tags: [sandbox, documentation]
---

# Sandbox Docs - HDF 2.1

## Outline

-   [Release Notes](#release-notes)
-   [System Information](#system-information)
    -   [Databases Used](#databases-used)
-   [HDF Services Started Automatically on Startup](#hdf-services-started-automatically-on-startup)
-   [HDF Services Not Started Automatically on Startup](#hdf-services-not-started-automatically-on-startup)
-   [Services Not Supported by HDF](#services-not-supported-by-hdf)
-   [Further Reading](#further-reading)


## Release Notes

Apr 2017
-   Md5 VMware Virtual Appliance – **6b2ae706e7e20222a2a285f03a7daeb6**
-   Md5 Virtualbox Virtual Appliance – **70cf1c8a60c99aac18c881800dc98956**
-   Md5 Docker – **0af6e275c392862294b7a6f848b29692**
-   HDF Stack and Ambari: The Sandbox uses the following versions of Ambari and HDF stack. Please use the following release note links provided to view Ambari and HDF stack specific information.
    -   HDP 2.1
    -   Ambari 2.4


## System Information

Operating System and Java versions that the Sandbox has installed.
-   OS Version (docker container)
    -   CentOS release 6.9 (Final)
    -   Java Version (docker container)
    -   openjdk version “1.8.0_131”
    -   OpenJDK Runtime Environment (build 1.8.0.131-0.b11)
-   OS Version (Hosting Virtual Machine)
    -   CentOS Linux release 7.2.1511 (Core)

Image File Sizes:
-   VMware – 4.6 GB
-   Virtualbox – 4.4 GB
-   Docker – 5.87 GB


### Databases Used

These are a list of databases used within Sandbox along with the corresponding HDF components that use them.

-   Ambari: postgres
-   Ranger: Mysql


## HDP Services Started Automatically on Startup

When the virtual machine is booted up, the following services are started. If not specified, assume all are java processes. The users that launch the process are the corresponding names of the component. The processes are listed with their main class.

-   Ambari
    -   AmbariServer - org.apache.ambari.server.controller.AmbariServer run as root user
-   Ambari Agent (non java process)
-   Zookeeper
    -   QuorumPeerMain - org.apache.zookeeper.server.quorum.QuorumPeerMain
-   Storm
    -   DRPC Server –org.apache.storm.daemon.drpc
    -   Nimbus – org.apache.storm.daemon.nimbus
    -   Storm UI Server – org.apache.storm.ui.core
    -   Supervisors - org.apache.storm.daemon.supervisor.Supervisor
-   Kafka
-   Ranger
    -   UnixAuthenticationService - org.apache.ranger.authentication.UnixAuthenticationService Run as root user
    -   EmbededServer - org.apache.ranger.server.tomcat.EmbeddedServer


## HDF Services Not Started Automatically on Startup

Because of the limited resources avaialble in the sandbox virtual machine environment, the following services are in maintenance mode and will not automatically start. To fully use these services, you must allocate more memory to the sandbox virtual machine. If you want these services to automatically start, turn off maintenance mode. The processes are listed with their main class.

-   Ambari Infra
-   Ambari Metrics
-   Log Search
-   Atlas
    -   Main - org.apache.atlas.Main

## Services Not Supported by HDF

Services that are not yet supported by HDF sandbox.

-   Log Search

## Further Reading
-   <https://hortonworks.com/products/data-center/hdf/>
-   <https://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.1.2/index.html>
