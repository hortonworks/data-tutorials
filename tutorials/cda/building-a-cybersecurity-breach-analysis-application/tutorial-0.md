---
title: Building a Cybersecurity Breach Analysis Application
author: sandbox-team
tutorial-id: 200
experience: Intermediate
persona: Data Engineer, Data Scientist
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache NiFi, HDFS, Apache Hive, Apache Spark, Apache Zeppelin
release: hdp-2.6.5, hdf-3.1.1
environment: Sandbox
product: HDP
series: HDP > Hadoop for Data Engineers & Data Scientists > Real World Examples, HDF > Develop Data Flow & Streaming Applications > Real World Examples
---

# Building a Cybersecurity Breach Analysis Application

## Introduction



## Big Data Technologies used to develop the Application:

- [NASA Server Logs Dataset](http://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html)
- [HDF Sandbox](https://hortonworks.com/products/data-platforms/hdf/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache NiFi](https://nifi.apache.org/)
- [HDP Sandbox](https://hortonworks.com/products/data-platforms/hdp/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache Hadoop - HDFS](http://hadoop.apache.org/docs/r2.7.6/)
    - [Apache Hive](https://hive.apache.org/)
    - [Apache Spark](https://spark.apache.org/)
    - [Apache Zeppelin](https://zeppelin.apache.org/)

## Goals and Objectives



## Prerequisites

- Downloaded and Installed the latest [Hortonworks HDP Sandbox](https://hortonworks.com/hdp/downloads/)
- Read through [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to setup hostname mapping to IP address
- If you don't have 12GB of RAM for HDP Sandbox, then refer to [Deploying Hortonworks Sandbox on Microsoft Azure](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/4/)
- Enabled Connected Data Architecture:
  - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for Docker](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

## Outline

The tutorial series consists of the following tutorial modules:

1\. **Application Development Concepts**

2\. **Setting up the Development Environment**: Any Configurations and/or software services that may need to be installed.

3\. **Acquiring NASA Server Log Data**: NASA 2 months of Historical Data ingested by NiFi and stored to HDFS

4\. **Cleaning the Raw NASA Log Data**: Hive.
Show insight of how we are cleaning the data using Zeppelin.

5\. **Visualizing NASA Log Data**: Spark. Perform data analysis on NASA Server Logs to find the _Most Frequent Hosts_ - keep count per ip address, _Response Codes_ - keep record of the count per response code, _Type of Extensions_ - gather count of the type of file formats, _Network Traffic per Location_ - visualize location hits are coming from
