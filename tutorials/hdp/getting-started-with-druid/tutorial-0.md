---
title: Getting Started with Druid
author: sandbox-team
tutorial-id: 900
experience: Beginner
persona: Basic Development
source: Hortonworks
use case: OLAP
technology: Apache Druid
release: hdp-3.0.0
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Druid
---

# Getting Started with Druid

## Introduction

In this tutorial, we will install Druid onto HDP Sandbox using the Ambari Install Wizard, then use the Wikipedia sample dataset of 2015 that comes with Druid after installation to store data into Druid and then query the data to answer questions.

## Prerequisites

- Installed [Hortonworks Data Platform (HDP) Sandbox](https://hortonworks.com/downloads/#sandbox)
- 16GB of RAM dedicated for the Sandbox

## Goals and Objectives

- Configure Druid for HDP Sandbox
- Analyze Dataset
- Load Batch Data
- Writing a Druid Ingestion Spec
- Running Druid Task
- Querying the Data

## Outline

1\. **Druid Concepts**: Gain high level overview of how Druid stores data, queries the data and the architecture of a Druid cluster.

2\. **Setting Up Development Environment**: Setup hostname mapping to IP address, setup Ambari admin password, turn off services not needed and turn on Druid.

3\. **Loading Batch Data into Druid**: Learn to load batch data into Druid by submitting an _ingestion task_ that points to your desired data file via POST request.

4\. **Loading Streaming Data into Druid via HTTP**: Learn to use Tranquility Server to send data into Druid using an HTTP client.

5\. **Querying Data from Druid**: Learn to write JSON-based queries to answer questions about the dataset.
