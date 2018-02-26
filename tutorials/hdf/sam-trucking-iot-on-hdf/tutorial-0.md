---
title: SAM in Trucking IoT on HDF
author: James Medel
tutorial-id: 807
experience: Beginner
persona: Developer
source: Hortonworks
use case: Streaming
technology: Streaming Analytics Manager
release: hdf-3.1
environment: Sandbox
product: HDF
series: HDF > Develop with Hadoop > Real World Examples
---

# SAM in Trucking IoT on HDF

## Introduction

This tutorial covers the core concepts of Streaming Analytics Manager (SAM) and the role it plays in an environment in which Stream processing is important.

We will create a SAM topology to ingest streams of data from Apache Kafka into our stream application, do some complex processing and store the data into Druid and HDFS.

Since Druid and HDFS are not available on HDF, we will also do some HDF and HDP administration work to make it possible to transfer data between the two single node clusters.

## Prerequisites

- [Hortonworks DataFlow (HDF) Sandbox Installed](https://hortonworks.com/downloads/#sandbox)

## Outline

- **Lesson - Stream Processing & SAM** - You will learn the fundamental concepts of Stream Processing and SAM.
- **Tutorial - Create a SAM Topology** - You will learn to build a stream processing application

## Tutorial Reference Application

This tutorial series uses our **[Trucking IoT Application](https://github.com/orendain/trucking-iot/tree/hadoop-summit-2017)** comprised of multiple subprojects. You will build the SAM topology application subproject.
