---
title: Analyze IoT Weather Station Data via Connected Data Architecture
author: sandbox-team
tutorial-id: 820
experience: Advanced
persona: Data Engineer & Data Scientist
source: Hortonworks
use case: Internet of Things
technology: Apache NiFi, Apache MiNiFi, Raspberry Pi, Apache Zookeeper, Apache HBase, Apache Phoenix
release: hdp-3.0.1, hdf-3.2.0
environment: Sandbox
product: CDA
series: CDA > Data Engineers & Scientists > Data Science Applications
---

# Analyze IoT Weather Station Data via Connected Data Architecture

## Introduction

Over the past two years, San Jose has experienced a shift in weather conditions from having the hottest temperature back in 2016 to having multiple floods occur just within 2017. You have been hired by the City of San Jose as a Data Scientist to build Internet of Things (IoT) and Big Data project, which involves analyzing the data coming in from several weather stations using a data-in-motion framework and data-at-rest framework to improve monitoring the weather. You will be using Hortonworks Connected Data Architecture(Hortonworks Data Flow (HDF), Hortonworks Data Platform (HDP)) and the MiNiFi subproject of Apache NiFi to build this product.

As a Data Scientist, you will create a proof of concept in which you use the Raspberry Pi and Sense HAT to replicate the weather station data, HDF Sandbox and HDP Sandbox on Docker to analyze the weather data. By the end of the project, you will be able to show meaningful insights on temperature, humidity and pressure readings.

In the tutorial series, you will build an Internet of Things (IoT) Weather Station using Hortonworks Connected Data Architecture, which incorporates open source frameworks: MiNiFi, Hortonworks DataFlow (HDF) and Hortonworks Data Platform (HDP). In addition you will work with the Raspberry Pi and Sense HAT. You will use a MiNiFi agent to route the weather data from the Raspberry Pi to HDF Docker Sandbox via Site-to-Site protocol, then you will connect the NiFi service running on HDF Docker Sandbox to HBase running on HDP Docker Sandbox. From within HDP, you will learn to visually monitor weather data in HBase using Zeppelin’s Phoenix Interpreter.

![cda-minifi-hdf-hdp-architecture](assets/tutorial1/cda-minifi-hdf-hdp-architecture.png)

**Figure 1:** IoT Weather Station and Connected Data Architecture Integration

### Big Data Technologies used to develop the Application:

- [Raspberry Pi Sense Hat](https://projects.raspberrypi.org/en/projects/getting-started-with-the-sense-hat)
- [HDF Sandbox](https://hortonworks.com/products/data-platforms/hdf/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache NiFi](https://nifi.apache.org/)
    - [Apache Kafka](http://kafka.apache.org/)
- [HDP Sandbox](https://hortonworks.com/products/data-platforms/hdp/)
    - [Apache Ambari](https://ambari.apache.org/)
    - [Apache Hadoop - HDFS](https://hadoop.apache.org/docs/r3.1.1/)
    - [Apache HBase](https://hbase.apache.org/)
    - [Apache Spark](https://spark.apache.org/)
    - [Apache Kafka](http://kafka.apache.org/)
    - [Apache Zeppelin](https://zeppelin.apache.org/)

## Goals And Objectives

By the end of this tutorial series, you will acquire the fundamental knowledge to build IoT related applications of your own. You will be able to connect MiNiFi, HDF Sandbox and HDP Sandbox. You will learn to transport data across remote systems, and visualize data to bring meaningful insight to your customers. You will need to have a background in the fundamental concepts of programming (any language is adequate) to enrich your experience in this tutorial.

**The learning objectives of this tutorial series include:**

- Deploy IoT Weather Station and Connected Data Architecture
- Become familiar with Raspberry Pi IoT Projects
- Understand Barometric Pressure/Temperature/Altitude Sensor’s Functionality
- Implement a Python Script to Control Sense HAT to Generate Weather Data
- Create HBase Table to hold Sensor Readings
- Build a MiNiFi flow to Transport the Sensor Data from Raspberry Pi to Remote NiFi located on HDF running on your computer
- Build a NiFi flow on HDF Sandbox that preprocesses the data and geographically enriches the sensor dataset, and stores the data into HBase on HDP Sandbox
- Visualize the Sensor Data with Apache Zeppelin Phoenix Interpreter

## Bill of Materials:

- Raspberry Pi 3 Essentials Kit - On-board WiFi and Bluetooth Connectivity
- Raspberry Pi Sense Hat

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- Read through [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to setup hostname mapping to IP address
- If you don't have 32GB of dedicated RAM for HDP Sandbox, then refer to [Deploying Hortonworks Sandbox on Microsoft Azure](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/4/)
- Enabled Connected Data Architecture:
  - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for Docker](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

## Tutorial Series Overview

In this tutorial, we work with barometric pressure, temperature and humidity sensor data gathered from a Raspberry Pi using Apache MiNiFi. We transport the MiNiFi data to NiFi using Site-To-Site, then we upload the data with NiFi into HBase to perform data analytics.

<!--

This tutorial consists of two tracks, one track in which users have the IoT Weather Station Hardware Kit and the other in which users do not have the kit, so they use simulated data:

| IoT Weather Station Hardware Kit | Track Path |
| :------------- | :------------- |
| Yes I have it     | Follow Track 1  |
| No I don't     | Follow Track 2  |


### Track 1: Tutorial Using IoT Weather Station Hardware

-->

1\. **[IoT and Connected Data Architecture Concepts](https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/1/)** - Familiarize yourself with Raspberry Pi, Sense HAT Sensor Functionality, HDF and HDP Docker Sandbox Container Communication, NiFi, MiNiFi, Zookeeper, HBase, Phoenix and Zeppelin.

2\. **[Deploy IoT Weather Station and Connected Data Architecture](https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/2/)** - Set up the IoT Weather Station for processing the sensor data. You will install Raspbian OS and MiNiFi on the Raspberry Pi, HDF Sandbox and HDP Sandbox on your local machine.

3\. **[Collect Sense HAT Weather Data on CDA](https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/3/)** - Program the Raspberry Pi to retrieve the sensor data from the Sense HAT Sensor. Embed a MiNiFi Agent onto the Raspberry Pi to collect sensor data and transport it to NiFi on HDF via Site-to-Site. Store the Raw sensor readings into HDFS on HDP using NiFi.

4\. **[Populate HDP HBase with HDF NiFi Flow](https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/4/)** - Enhance the NiFi flow by adding on geographic location attributes to the sensor data and converting it to JSON format for easy storage into HBase.

5\. **[Visualize Weather Data with Zeppelin's Phoenix Interpreter](https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/5/)** - Monitor the weather data with Phoenix and create visualizations of those readings using Zeppelin's Phoenix Interpreter.

<!--

### Track 2: Tutorial using Simulated Data

**Visualize IoT Weather Data from Multiple Stations]**(https://hortonworks.com/tutorial/analyze-iot-weather-station-data-via-connected-data-architecture/section/1/) - Deploy multiple Docker MiNiFi containers in your Guest VM Docker Network, which pull their own data seeds, simulating the sensor data that would be pulled in from the Sense HAT and route the data from those edge node containers to the remote HDF container where NiFi is running. You will import a NiFi flow, this template has multiple input ports it listens in on incoming data coming from the MiNiFi Weather Station agents and then preprocesses the data, adding geographic location insights, converting the data to JSON and storing it into HBase. You will create a Phoenix table in Zeppelin and visualize the data.

-->

The tutorial series is broken into multiple tutorials that provide step by step instructions, so that you can complete the learning objectives and tasks associated with it. You are also provided with a dataflow template for each tutorial that you can use for verification. Each tutorial builds on the previous tutorial.
