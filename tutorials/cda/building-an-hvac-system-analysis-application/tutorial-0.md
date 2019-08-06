---
title: Building an HVAC System Analysis Application
author: sandbox-team
tutorial-id: 790
experience: Intermediate
persona: Data Engineer, Data Analyst
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache NiFi, Apache Hive, Apache Zeppelin
release: hdp-3.0.1, hdf-3.2.0
environment: Sandbox
product: CDA
series: CDA > Data Engineers & Scientists > Data Science Applications
---

# Building an HVAC System Analysis Application

## Introduction

Hortonworks Connected Data Platform can be used to acquire, clean and visualize data from heating, ventilation, and air conditioning (HVAC) machine systems to maintain optimal office building temperatures and minimize expenses.

## Big Data Technologies used to develop the Application:

- Historical HVAC Sensor Data
- [HDF Sandbox](https://hortonworks.com/products/data-platforms/hdf/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache NiFi](https://nifi.apache.org/)
- [HDP Sandbox](https://hortonworks.com/products/data-platforms/hdp/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache Hadoop - HDFS](http://hadoop.apache.org/docs/r2.7.6/)
    - [Apache Hive](https://hive.apache.org/)
    - [Apache Zeppelin](https://zeppelin.apache.org/)

## Goals and Objectives

- Learn to write a shell script to automate development environment setup
- Learn to build a NiFi flow to acquire HVAC machine sensor data
- Learn to write Hive scripts to clean the HVAC machine sensor data and prepare it for visualization
- Learn to visualize HVAC machine sensor data in Zeppelin

## Prerequisites

- Downloaded and Installed the latest [Hortonworks HDP Sandbox](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial Sandbox
- Read through [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to setup hostname mapping to IP address
- If you don't have at least 16GB of RAM for HDP Sandbox and 4 GB of RAM for your machine, then refer to [Deploying Hortonworks Sandbox on Microsoft Azure](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/4/)
- Enabled Connected Data Architecture:
  - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for Docker](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

## Outline

The tutorial series consists of the following tutorial modules:

1\. **[Application Development Concepts](https://hortonworks.com/tutorial/building-an-hvac-system-analysis-application/section/1/)**: Focus on HVAC fundamentals, common sensors used in HVAC Systems and ways to analyze data from these sensors to understand the status of the HVAC Systems.

2\. **[Setting up the Development Environment](https://hortonworks.com/tutorial/building-an-hvac-system-analysis-application/section/2/)**: Any Configurations and/or software services that may need to be installed prior to building the data pipeline and visualization notebook.

3\. **[Acquiring HVAC Sensor Data](https://hortonworks.com/tutorial/building-an-hvac-system-analysis-application/section/3/)**: Create a part of the data pipeline using Apache NiFi to ingest, process and store 1 month of Historical HVAC Sensor Data into HDFS.

4\. **[Cleaning Raw HVAC Data](https://hortonworks.com/tutorial/building-an-hvac-system-analysis-application/section/4/)**: Create the next portion of the data pipeline using Apache Hive to upload the data into Hive tables, so the data can be cleaned and queried to capture valuable insight about the status of HVAC Systems regulating temperature in buildings across various countries.

5\. **[Visualizing Sensor Data Related To HVAC Machine Systems](https://hortonworks.com/tutorial/building-an-hvac-system-analysis-application/section/5/)**: Perform data analysis on HVAC sensor data to find the _HVAC Building Temperature Characteristics Per Country_ - keep count of HOT, COLD, NORMAL ranges per country, _Extreme Temperature in Buildings Having HVAC Products_ - building that are experiencing extreme temperature whether it be HOT or COLD even though they have HVAC products.
