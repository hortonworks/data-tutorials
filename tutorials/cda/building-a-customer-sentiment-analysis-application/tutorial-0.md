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

In the second development phase, you will play the role of **Data Scientist** tasked with using Apache Spark to clean the data to preprocess it to be in the proper format, so you can build a Machine Learning Sentiment Analysis Classification model to categorize the tweets as happy or sad and then translate the model for storage into HDFS.

In the final development phase, you will leverage skills from both roles to visualize the sentiment score of each tweet with Solr's Banana Dashboard by using Spark Structured Streaming to send the model into Kafka, which NiFi pulls into it's dataflow to be pushed to Solr.

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

- Learn to create a Twitter Application using Twitter's Developer Portal to get KEYS and TOKENS for connecting to Twitter's APIs
- Learn to create a NiFi Dataflow Application that integrates Twitter's Decahose API to ingest tweets, perform some preprocessing, store the data into the Kafka Topic "tweets".
- Learn to create a NiFi Dataflow Appliction that ingests the Kafka Topic "tweetsSentiment" to stream sentiment tweet data to Solr
- Learn to build a SparkSQL Application to clean the data and get it into a suitable format for building the sentiment classification model
- Learn to build a SparkML Application to train and validate a sentiment classfication model using Gradient Boosting
- Learn to build a Spark Structured Streaming Application to stream the sentiment tweet data from Kafka topic "tweets" on HDP to Kafka topic "tweetsSentiment" on HDF to do real-time data visualization using Solr's Banana Dashboard
- Learn to do data visualization of sentiment tweet data with Solr's Banana Dashboard

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

1\. **Application Development Concepts**: You will be introduced to customer sentiment fundamentals: customer sentiment analysis, ways to perform the data analysis and the various use cases.

2\. **Setting up the Development Environment**: You will create a Twitter Application in Twitter's Developer Portal for access to KEYS and TOKENS. You will then write a shell code and perform Ambari REST API Calls to setup a development environment.

3\. **Acquiring Twitter Data**: You will build a NiFi dataflow to ingest Twitter data, preprocess it and store it into HDFS along with a Kafka Topic "tweets". The other NiFi dataflow you will build ingests the enriched sentiment tweet data from Kafka topic "tweetsSentiment" and streams the content of the flowfile to Solr.

4\. **Cleaning the Raw Twitter Data**: You will create a Zeppelin notebook and use Zeppelin's Spark Interpreter to clean the raw twitter data in preparation to create the sentiment classification model.

5\. **Building a Sentiment Classification Model**: You will create a Zeppelin notebook and use Zeppelin's Spark Interpreter to build a sentiment classification model that classifies tweets as Happy or Sad and exports the model to HDFS.

6\. **Deploying a Sentiment Classification Model**: You will create a Scala IntelliJ project in which you develop a Spark Structured Streaming application that streams the data from Kafka topic "tweets" on HDP, processes the tweet JSON data by adding sentiment and streaming the data into Kafka topic "tweetsSentiment" on HDF.

7\. **Visualizing the Classification Model in Real-Time**: You will use Solr's Banana Dashboard to visualize the sentiment tweet data with various charts.
