---
title: Building an HVAC System Analysis Application
author: sandbox-team
tutorial-id: 310
experience: Intermediate
persona: Data Engineer, Data Scientist
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache NiFi, Apache Hive, Apache Zeppelin
release: hdp-3.0.0, hdf-3.2.0
environment: Sandbox
product: HDP
series: HDP > Hadoop for Data Engineers & Data Scientists > Real World Examples, HDF > Develop Data Flow & Streaming Applications > Real World Examples
---

# Building an HVAC System Analysis Application

## Introduction

Hortonworks Connected Data Platform can be used to to acquire, clean and visualize data from heating, ventilation, and air conditioning (HVAC) machine systems to maintain optimal office building temperatures and minimize expenses.

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

3\. **Acquiring HVAC Sensor Data**: 1 month of Historical HVAC Sensor Data  ingested by NiFi and stored to HDFS.

4\. **Cleaning Raw HVAC Data**: Hive.
Show insight of how we are cleaning the data using Zeppelin.

5\. **Visualizing HVAC Systems with Extreme Temperature**: Spark. Perform data analysis on HVAC sensor data to find the _HVAC Temperature Ranges By Country_ - keep count of HOT, COLD, NORMAL ranges per country, _HVAC Extreme HOT Units_ - keep count of machines with HOT temperature, _HVAC Extreme COLD Units_ - keep count of machines with COLD temperature.

## Further Reading

- [Demo Video: Analyzing Sensor Data](https://www.youtube.com/watch?v=Op_5MmG7hIw)
