---
title: Superset in Trucking IoT
author: sandbox-team
tutorial-id: 821
experience: Beginner
persona: Data Analyst
source: Hortonworks
use case: Data Visualization
technology: Apache Superset
release: hdp-3.0.1, hdf 3.2
environment: Sandbox
product: CDA
series: CDA > Data Engineers & Scientists > Data Science Applications
---

# Superset in Trucking IoT

## Introduction

Superset is a Business Intelligence tool packaged with many features for designing, maintaining and enabling the storytelling of data through meaningful data visualizations. The trucking company you work at has a Trucking IoT Application that processes the truck and traffic data it receives from sensors, but the businesses leaders are not able to make sense of the data. They hired you as a Data Visualization Analyst to tell a story through visualizing this application's data, such as how the traffic congestion levels impact truck driver performance, which ultimately affect the company. Therefore, your communication of your insights to business leaders will influence them to take action based on your recommendations.

## Objective

- Learn Data Visualization Concepts
- Become familiar with Apache Superset
- Learn to Design Visualizations with Superset

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- If you don't have 32GB of dedicated RAM for HDP Sandbox, then refer to [Deploying Hortonworks Sandbox on Microsoft Azure](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/4/)
- Enabled Connected Data Architecture:
  - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
  - [Enable CDA for Docker](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

## Outline

- **[Superset Concepts](https://hortonworks.com/tutorial/superset-in-trucking-iot/section/1/)** - Covers the fundamental concepts of Data Visualization and Superset.
- **[Setting up the Development Environment](https://hortonworks.com/tutorial/superset-in-trucking-iot/section/2/)** - Setup hostname mapping to IP address, setup Ambari admin password, turn on services needed for Superset and turn on Superset.
- **[Visualizing Trucking Data](https://hortonworks.com/tutorial/superset-in-trucking-iot/section/3/)** - Shows how to visualize data using Superset.

## Tutorial Reference Application

This tutorial series uses our **[Trucking IoT Application](https://github.com/orendain/trucking-iot/tree/hadoop-summit-2017)** comprised of multiple sub-projects. You will build the Superset visualization subproject.
