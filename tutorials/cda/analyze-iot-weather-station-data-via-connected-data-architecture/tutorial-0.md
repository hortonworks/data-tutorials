---
title: Analyze IoT Weather Station Data via Connected Data Architecture
author: James Medel
tutorial-id: 820
experience: Advanced
persona: Data Scientist & Analyst
source: Hortonworks
use case: Internet of Things
technology: Apache NiFi, MiNiFi, Raspberry Pi, Apache Zookeeper, Apache HBase, Apache Phoenix
release: hdp-2.6.4, hdf-3.0.2
environment: Sandbox
product: HDF
series: HDF > Hadoop for Data Scientists & Analysts > Real World Examples
---

# Analyze IoT Weather Station Data via Connected Data Architecture

## Introduction

Over the past two years, San Jose has experienced a shift in weather conditions from having the hottest temperature back in 2016 to having multiple floods occur just within 2017. You have been hired by the City of San Jose as a Data Scientist to build Internet of Things (IoT) and Big Data project, which involves analyzing the data coming in from several weather stations using a data-in-motion framework and data-at-rest framework to improve monitoring the weather. You will be using Hortonworks Connected Data Architecture(Hortonworks Data Flow (HDF), Hortonworks Data Platform (HDP)) and the MiNiFi subproject of Apache NiFi to build this product.

As a Data Scientist, you will create a proof of concept in which you use the Raspberry Pi and Sense HAT to replicate the weather station data, HDF Sandbox and HDP Sandbox on Docker to analyze the weather data. By the end of the project, you will be able to show meaningful insights on temperature, humidity and pressure readings.

In the tutorial series, you will build an Internet of Things (IoT) Weather Station using Hortonworks Connected Data Architecture, which incorporates open source frameworks: MiNiFi, Hortonworks DataFlow (HDF) and Hortonworks Data Platform (HDP). In addition you will work with the Raspberry Pi (R-Pi) and Sense HAT. You will use a MiNiFi agent to route the weather data from the Raspberry Pi to HDF Docker Sandbox via Site-to-Site protocol, then you will connect the NiFi service running on HDF Docker Sandbox to HBase running on HDP Docker Sandbox. From within HDP, you will learn to visually monitor weather data in HBase using Zeppelin’s Phoenix Interpreter.

![cda-minifi-hdf-hdp-architecture](assets/tutorial1/cda-minifi-hdf-hdp-architecture.png)

**Figure 1:** IoT Weather Station and Connected Data Architecture Integration

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

- [IoT Weather Station Hardware Kit](http://a.co/8FNMlUu)

## Hardware Requirements

- At least 12 GB of RAM to run both HDF and HDP Sandboxes on one laptop

## Prerequisites

- Downloaded and Installed [Docker Engine](https://docs.docker.com/engine/installation/) on Local Machine
    - Set [Docker Memory to 12GB](https://docs.docker.com/docker-for-mac/#preferences) to run both HDF and HDP Sandboxes on one laptop.
        - Link above will take you to Docker preferences for Mac. In the Docker documentation, choose your OS.
- Downloaded Latest [HDF and HDP Sandboxes](https://hortonworks.com/downloads) for Docker Engine
- Installed Latest [HDF and HDP Sandboxes](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/) onto your computer

## Tutorial Series Overview

In this tutorial, we work with barometric pressure, temperature and humidity sensor data gathered from a R-Pi using Apache MiNiFi. We transport the MiNiFi data to NiFi using Site-To-Site, then we upload the data with NiFi into HBase to perform data analytics.

This tutorial consists of two tracks, one track in which users have the IoT Weather Station Hardware Kit and the other in which users do not have the kit, so they use simulated data:

| IoT Weather Station Hardware Kit | Track Path |
| :------------- | :------------- |
| Yes I have it     | Follow Track 1  |
| No I don't     | Follow Track 2  |

### Track 1: Tutorial Using IoT Weather Station Hardware

**IoT and Connected Data Architecture Concepts** - Familiarize yourself with Raspberry Pi, Sense HAT Sensor Functionality, Docker, Docker Container, HDF and HDP Docker Sandbox Container Communication, NiFi, MiNiFi, Zookeeper, HBase, Phoenix and Zeppelin.

**Deploy IoT Weather Station and Connected Data Architecture** - Set up the IoT Weather Station for processing the sensor data. You will install Raspbian OS and MiNiFi on the R-Pi, HDF Sandbox and HDP Sandbox on your local machine.

**Collect Sense HAT Weather Data on CDA** - Program the R-Pi to retrieve the sensor data from the Sense HAT Sensor. Embed a MiNiFi Agent onto the R-Pi to collect sensor data and transport it to NiFi on HDF via Site-to-Site. Store the Raw sensor readings into HDFS on HDP using NiFi.

**Populate HDP HBase with HDF NiFi Flow** - Enhance the NiFi flow by adding on geographic location attributes to the sensor data and converting it to JSON format for easy storage into HBase.

**Visualize Weather Data with Zeppelin's Phoenix Interpreter** - Monitor the weather data with Phoenix and create visualizations of those readings using Zeppelin's Phoenix Interpreter.

### Track 2: Tutorial using Simulated Data (Coming Soon)

**Visualize IoT Weather Station Data** - Import NiFi flow. This template runs the IoT Weather Staion simulator, preprocesses the data, adds geographic location insights, converts the data to JSON and stores it into HBase. You will create a Phoenix table in Zeppelin and visualize the data.

The tutorial series is broken into multiple tutorials that provide step by step instructions, so that you can complete the learning objectives and tasks associated with it. You are also provided with a dataflow template for each tutorial that you can use for verification. Each tutorial builds on the previous tutorial.
