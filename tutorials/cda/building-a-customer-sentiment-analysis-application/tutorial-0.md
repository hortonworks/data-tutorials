---
title: Building a Customer Sentiment Analysis Application
author: sandbox-team
tutorial-id: 770
experience: Advanced
persona: Data Engineer, Data Scientist
source: Hortonworks
use case: Data Discovery
technology: Apache Solr, Apache Hive, Apache NiFi, Apache Ambari, Apache Zeppelin
release: hdp-3.0.0, hdf-3.2.0
environment: Sandbox
product: HDP
series: HDP > Hadoop for Data Engineers & Data Scientists > Real World Examples, HDF > Develop Data Flow & Streaming Applications > Real World Examples
---

# Building a Customer Sentiment Analysis Application

## Introduction

For this project, you will play the part of a Big Data Application Developer who leverages their skills as a Data Engineer and Data Scientist by using multiple Big Data Technologies provided by Hortonworks Data Flow (HDF) and Hortonworks Data Platform (HDP) to build a Real-Time Sentiment Analysis Application.

In the first development phase, you will play the role of **Data Engineer** tasked with acquiring tweet data from Twitter and storing the raw data using Apache NiFi.

In the second development phase, you will play the role of **Data Scientist** tasked with using Apache Spark to build a Machine Learning Sentiment Analysis Classification model to categorize the tweets as happy or sad and then translate the model for storage into HDFS.

In the final development phase, you will leverage skills from both roles to visualize the sentiment score of each tweet with Solr's Banana Dashboard by using Spark Streaming to send the model into Kafka, which NiFi pulls into it's dataflow to be pushed to Solr.

## Big Data Technologies used to develop the Application:

- [Twitter API](https://dev.twitter.com/)
- [HDF Sandbox](https://hortonworks.com/products/data-platforms/hdf/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache NiFi](https://nifi.apache.org/)
- [HDP Sandbox](https://hortonworks.com/products/data-platforms/hdp/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache Solr](http://lucene.apache.org/solr/)
    - [LucidWorks Banana Dashboard](https://doc.lucidworks.com/lucidworks-hdpsearch/2.5/Guide-Banana.html)
    - [Apache Hive](https://hive.apache.org/)
    - [Apache Hadoop - HDFS](http://hadoop.apache.org/docs/r2.7.6/)
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

3\. **Acquiring Twitter Data**: Twitter Dev to NiFi to HDFS

4\. **Cleaning the Raw Twitter Data**: Hive.
Show insight of how we are cleaning the data using Zeppelin.

5\. **Building a Sentiment Classification Model**: Scala and Spark2.
Show insight into how we are classifying the data using Zeppelin.

6\. **Visualizing the Classification Model in Real-Time**: Spark Streaming to Kafka to NiFi to Solr's Banana Dashboard
