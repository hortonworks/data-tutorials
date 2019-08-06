---
title: Building a Server Log Analysis Application
author: sandbox-team
tutorial-id: 780
experience: Intermediate
persona: Data Engineer, Data Analyst
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache NiFi, HDFS, Apache Spark, Apache Zeppelin
release: hdp-3.0.1, hdf-3.2.0
environment: Sandbox
product: CDA
series: CDA > Data Engineers & Scientists > Data Science Applications
---

# Building a Server Log Analysis Application

## Introduction

Security Breaches are common problem for businesses with the question of when it
will happen? One of the first lines of defense for detecting potential
vulnerabilities in the network is to investigate the logs from your server. You
have been brought on to apply your skills in Data Engineering and Data Analysis
to acquire server log data, preprocess the data and store it into reliable
distributed storage HDFS using the dataflow management framework Apache NiFi.
You will need to further clean and refine the data using Apache Spark for
specific insights into what activities are happening on your server, such as
most frequent hosts hitting the server and which country or city causes the
most network traffic with your server. You will then visualize these events
using the data science notebook Apache Zeppelin to be able to tell a story
to about the activities occurring on the server and if there is anything your
team should be cautious about.

## Big Data Technologies used to develop the Application:

- [NASA Server Logs Dataset](http://ita.ee.lbl.gov/html/contrib/NASA-HTTP.html)
- [HDF Sandbox](https://hortonworks.com/products/data-platforms/hdf/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache NiFi](https://nifi.apache.org/)
- [HDP Sandbox](https://hortonworks.com/products/data-platforms/hdp/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache Hadoop - HDFS](https://hadoop.apache.org/docs/r3.1.0/)
    - [Apache Spark](https://spark.apache.org/)
    - [Apache Zeppelin](https://zeppelin.apache.org/)

## Goals and Objectives

- Learn about server log data, log data analysis, how it works, the various use cases
and best practices
- Learn to build a NiFi dataflow to acquire server log data
- Learn to clean the data for filtering down to messages that can tell users
about the activities happening on their servers using Spark
- Learn to visualization your finding after cleaning the data using Zeppelin
visualization

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- Read through [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to setup hostname mapping to IP address
- If you don't have at least 20GB of RAM for HDP Sandbox and 4 GB of RAM for your machine, then refer to [Deploying Hortonworks Sandbox on Microsoft Azure](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/4/)
- Enabled Connected Data Architecture:
  - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for Docker](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

## Outline

The tutorial series consists of the following tutorial modules:

1\. **[Application Development Concepts](https://hortonworks.com/tutorial/building-a-server-log-analysis-application/section/1/)**: Covers what is server log data, log data analysis, how log data analysis works, various use cases and some best practices that can be used in server log analysis.

2\. **[Setting up the Development Environment](https://hortonworks.com/tutorial/building-a-server-log-analysis-application/section/2/)**: You will perform any configurations on software services and/or install dependencies for software services that are needed to develop the application.

3\. **[Acquiring NASA Server Log Data](https://hortonworks.com/tutorial/building-a-server-log-analysis-application/section/3/)**: You will learn to build a NiFi dataflow that acquires 2 months worth of NASA log data, preprocesses the data and stores it into HDFS

4\. **[Cleaning the Raw NASA Log Data](https://hortonworks.com/tutorial/building-a-server-log-analysis-application/section/4/)**: You will learn to create a Zeppelin Notebook for cleaning the NASA log data and use Zeppelin's Spark Interpreter to clean the data and gather any valuable insight about the activities going on with the server.

5\. **[Visualizing NASA Log Data](https://hortonworks.com/tutorial/building-a-server-log-analysis-application/section/5/)**: You will create another Zeppelin Notebook whose purpose will be to visualize the key points you found when cleaning the data with Spark. Your data visualization will illustrate from the NASA log data, the _Most Frequent Hosts_ - count per IP address of hosts hitting the server, _Response Codes_ - count per response code in association with the server, _Type of Extensions_ - count of the type of file formats being transferred between devices interacting with the server, _Network Traffic per Location_ - location on where the server hits are coming from.
