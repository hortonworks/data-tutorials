# Analyze IoT Weather Station Data via Connected Data Architecture

## Introduction

You will build an Internet of Things (IoT) Weather Station using Connected Data Architecture, which incorporates open source frameworks: MiNiFi, Hortonworks DataFlow (HDF) and Hortonworks Data Platform (HDP). In addition you will work with the Raspberry Pi (R-Pi) and Sense HAT. You will use MiNiFi to route the weather data from the Raspberry Pi to HDF via Site-to-Site protocol, then you will connect the NiFi service running on HDF to HBase running on HDP. From within HDP, you will learn to visually monitor weather data in HBase using Zeppelin’s Phoenix Interpreter.

## Goals And Objectives

By the end of this tutorial series, you will acquire the fundamental knowledge to build IoT related applications of your own. You will be able to connect MiNiFi, HDF Sandbox and HDP Sandbox. You will learn to transport data across remote systems, and visualize data to bring meaningful insight to your customers. You will need to have a background in the fundamental concepts of programming (any language is adequate) to enrich your experience in this tutorial.

**The learning objectives of this tutorial series include:**

- Install an Operating System (Linux) on the R-Pi (Tutorial 1)
- Setup HDP Sandbox on your local machine (Tutorial 1)
- Understand the R-Pi’s Place in the IoT Spectrum (Tutorial 1)
- Understand Barometric Pressure/Temperature/Altitude Sensor’s Functionality (Tutorial 1)
- Configure R-Pi to communicate with Sensor via I2C (Tutorial 2)
- Implement a Python Script to Show Sensor Readings (Tutorial 2)
- Create HBase Table to hold Sensor Readings (Tutorial 3)
- Build a MiNiFi flow in NiFi using ExecuteProcess Processor and Remote Process Group to Ingest Raw Sensor Data from Python and Transport it to a Remote NiFi (Tutorial 3)
- Build a Remote NiFi flow that geographically enriches the sensor dataset, converts the data format to JSON and stores the data into HBase (Tutorial 3)
- Perform Aggregate Functions for Temperature, Pressure & Altitude with Phoenix (Tutorial 5)
- Visualize the Analyzed Data with Apache Zeppelin (Tutorial 5)


## Prerequisites

- Downloaded and installed [Hortonworks Sandboxes](http://hortonworks.com/products/sandbox/)

## Bill of Materials:

- [IoT Weather Station Electronics List](http://a.co/8FNMlUu)

## Hardware Requirements

- At least 12 GB of RAM to run both HDF and HDP Sandboxes on one laptop

## Tutorial Series Overview

In this tutorial, we work with barometric pressure, temperature and humidity sensor data gathered from a R-Pi using Apache MiNiFi. We transport the MiNiFi data to NiFi using Site-To-Site, then we upload the data with NiFi into HBase to perform data analytics.

This tutorial consists of five sections:

If you have a R-Pi and Sense HAT, follow track 1: tutorials 1 - 4. If you don’t have it, then start at Track 2: tutorial 5. Track 2 is optional for those users who don't have access R-Pi and Sense HAT.

### Track 1: Tutorial Series with R-Pi and Sense HAT

**Tutorial 1** - Set up the IoT Weather Station for processing the sensor data. You will install Raspbian OS and MiNiFi on the R-Pi, HDF Sandbox and HDP Sandbox on your local machine.

**Tutorial 2** - Program the R-Pi to retrieve the sensor data from the Sense HAT Sensor. Embed a MiNiFi Agent onto the R-Pi to collect sensor data and transport it to NiFi on HDF via Site-to-Site. Store the Raw sensor readings into HDFS on HDP using NiFi.

**Tutorial 3** - Enhance the NiFi flow by adding on Geographic location attributes to the sensor data and converting it to JSON format for easy storage into HBase.

**Tutorial 4** - Monitor the weather data with Phoenix and create visualizations of those readings using Zeppelin's Phoenix Interpreter.

### Track 2: Tutorial Series with Simulated Data

**Tutorial 5** - Import New workflow of NiFi. This template runs the sensor data simulator, then perform the same processing operations against the data as Tutorial 3 and 4.

The tutorial series is broken into multiple tutorials that provide step by step instructions, so that you can complete the learning objectives and tasks associated with it. You are also provided with a dataflow template for each tutorial that you can use for verification. Each tutorial builds on the previous tutorial.
