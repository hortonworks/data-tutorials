---
title: Hadoop Tutorial – Getting Started with HDP
author: sandbox-team
tutorial-id: 100
experience: Beginner
persona: Developer
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache Hive, Apache Pig, Apache Spark, Apache Zeppelin
release: hdp-3.0.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Hello World, HDP > Develop with Hadoop > Apache Hive
---

# Hadoop Tutorial – Getting Started with HDP

## Introduction

Hello World is often used by developers to familiarize themselves with new concepts by building a simple program. This tutorial aims to achieve a similar purpose by getting practitioners started with Hadoop and HDP. We will use an Internet of Things (IoT) use case to build your first HDP application.

This tutorial describes how to refine data for a Trucking IoT [Data Discovery](https://hortonworks.com/solutions/advanced-analytic-apps/#data-discovery) (aka IoT Discovery) use case using the Hortonworks Data Platform. The IoT Discovery use cases involves vehicles, devices and people moving across a map or similar surface. Your analysis is targeted to linking location information with your analytic data.

For our tutorial we are looking at a use case where we have a truck fleet. Each truck has been equipped to log location and event data. These events are streamed back to a datacenter where we will be processing the data.  The company wants to use this data to better understand risk.

Here is the video of [Analyzing Geolocation Data](http://youtu.be/n8fdYHoEEAM) to show you what you’ll be doing in this tutorial.

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- Go through [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to become familiar with the Sandbox.
- **_Optional_** Install [Hortonworks ODBC Driver](http://hortonworks.com/downloads/#addons). This will be needed for [Data Reporting with Microsoft Excel for Windows](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/7/) tutorial.

## Outline

- [Concepts to strengthen your foundation in the Hortonworks Data Platform (HDP)](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/1/)
- [Loading Sensor Data into HDFS](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/2/)
- [Hive - Data ETL](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/3/)
- [Spark - Risk Factor](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/5/)
- [Data Reporting with Zeppelin](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/6/)
- [Data Reporting with Microsoft Excel for Windows](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/7/)
