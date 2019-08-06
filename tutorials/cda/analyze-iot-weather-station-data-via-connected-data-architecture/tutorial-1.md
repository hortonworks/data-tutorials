---
title: IoT Weather Station Concepts
---

# IoT Weather Station Concepts

## Introduction

In the concepts tutorial, the goal is to provide you with enough background information on each hardware/software tool used to build this IoT Weather Station System.

## Prerequisites

-   Read "Analyze IoT Weather Station Data via Connected Data Architecture" Overview

## Outline

-   Raspberry Pi
-   HDP + HDF Services
-   IoT Weather Station powered by Connected Data Architecture
-   Summary
-   Further Reading

## Raspberry Pi

### What is a Raspberry Pi?

The Raspberry Pi 3 is a microprocessor or computer with an open-source platform commonly used for beginners learning to code to practitioners building Internet of Things (IoT) related Applications. This embedded device has a 1.2 GHz ARMv8 CPU, 1GB of memory, integrated Wi-Fi and Bluetooth. The Raspberry Pi comes with various General-Purpose Input/Output (GPIO) pins, input/output ports for connecting the device to external peripherals, such as sensors, keyboards, mouse devices and other peripherals. As can be seen in Figure 1, the Raspberry Pi is connected to the internet via Ethernet port, a monitor via HDMI port, keyboard and mouse via USB port and powered by 12V power supply. Embedded Linux flavors have been made for the Raspberry Pi, such as Raspbian, Yocto, etc. The Raspberry Pi's small footprint is a perfect candidate for us to learn to build a MiNiFi dataflow, do some simple processing in Java or C/C++ and route the data to the remote NiFi cluster. Thus, we can leverage this open source Apache tool to gather data at the source of where it is being created.

![raspberry_pi](assets/tutorial2/Raspberry-Pi-3-Flat-Top.jpg)

**Figure 1:** Raspberry Pi

### Internet of Things on Raspberry Pi

The Raspberry Pi is not just a platform for building IoT projects, it is a super platform for learning about IoT. Raspberry Pi is a great way to gain practical experience with IoT. According to [IBM Watson Internet of Things](http://www.ibm.com/internet-of-things/partners/raspberry-pi/), the Raspberry Pi IoT platform can be used in the following cases: a factory, environment, sports, vehicles, buildings, home and retail. All these Raspberry Pi IoT platform use cases have in common that data is processed, which can result in augmented productivity in factories, enhanced environmental stewardship initiatives, provided winning strategies in sports, enhanced driving experience, better decision making, enhanced resident safety and security and customized and improved shopping experience in retail.

### Sense HAT Functionality

![sense-hat-pins](assets/tutorial2/sense-hat-pins.jpg)

**Figure 2:** Sense HAT

The Sense HAT is a board that connects to the Raspberry Pi. It comes with an 8x8 LED Matrix, five-button joystick and the following sensors: gyroscope, accelerometer, magnetometer, temperature, barometric pressure and humidity.

### What exactly does the Sense HAT Sensor Measure?

The Sense HAT sensors enable users to measure orientation via an 3D accelerometer, 3D gyroscope and 3D magnetometer combined into one chip LSM9DS1. The Sense HAT also functions to measure air pressure and temperature via barometric pressure and temperature combined into the LPS25H chip. The HAT can monitor the percentage of humidity in correlation with temperature in the air via humidity and temperature sensor HTS221. All three of the these sensors are I2C.

### How does the Sense HAT Sensor Transfer Data to the Raspberry Pi?

The Sense HAT sensor uses I2C, a communication protocol, to transfer data to the Raspberry Pi and other devices. I2C requires two shared lines: serial clock signal (SCL) and bidirectional data transfers (SDA). Every I2C device uses a 7-bit address, which allows for more than 120 devices sharing the bus, and freely communicate with them one at a time on as-needed basis.

### What is an Advantage of I2C Sensors?

I2C makes it possible to have multiple devices in connection with the Raspberry Pi, each having a unique address and can be set by updating the settings on the Pi. It will be easier to verify everything is working because one can see all the devices connected to the Pi.

## HDP + HDF Services

### Apache MiNiFi

MiNiFi was built to live on the edge for ingesting data at the central location of where it is born, then before that data becomes too large for processing on the edge, it is transported to your data center where a distributed NiFi cluster can continue further processing the data from all these IoT Raspberry Pi devices. MiNiFi comes in two flavors Java or C++ agent. These agents access data from Microcontrollers and Microprocessors, such as Raspberry Pi's and other IoT level devices. The idea behind MiNiFi is to be able to get as close to the data as possible from any particular location no matter how small the footprint on a particular embedded device.

### Apache NiFi

NiFi is a robust and secure framework for ingesting data from various sources, performing simple transformations on that data and transporting it across a multitude of systems. The NiFi UI provides flexibility to allow teams to simultaneously change flows on the same machine. NiFi uses SAN or RAID storage for the data it ingests and the provenance data manipulation events it generates. Provenance is a record of events in the NiFi UI that shows how data manipulation occurs while data flows throughout the components, known as processors, in the NiFi flow. NiFi, program sized at approximately 1.2GB, has over 250 processors for custom integration with various systems and operations.

### Visualization of MiNiFi and NiFi Place in IoT

![nifi-minifi-place-iot](assets/tutorial1/nifi-minifi-place-in-iot.png)

**Figure 3:** MiNiFi to NiFi

### Apache Zookeeper

**Overview**

Zookeeper is an open-source coordination service designed for distributed applications. It uses a data model similar to the tree structure of file systems. With these apps, a set of primitives are exposed to implement higher level services for cases of synchronization, configuration maintenance, groups and naming. Typically building coordination services are difficult and prone to errors like race conditions and deadlocks. The goal with Zookeeper is to prevent developers from having to build coordination services from scratch across distributed applications.

**Design Goals**

Zookeeper is designed to be simple, replicated, ordered and fast. Ideal read/write ratio is close to 10:1 resulting in fast execution against workloads. Transaction records are maintained and can be incorporated for higher-level abstractions. To reflect the order of all transactions, every update is stamped with a number.

**How the Zookeeper Service Works**

In a Zookeeper cluster, you will usually have servers or nodes that make up the Zookeeper service that all know each other exist. They hold in-memory image of the state, transaction logs and snapshots in the persistent store. The Zookeeper service remains available as long as the servers are up and running. The process between client and Zookeeper involves the client making a connection to a Zookeeper server. The client maintains the TCP connection and sends requests, heart beats along with obtaining responses and watch events. Once Zookeeper crashes, clients will connect to another server.

### Apache HBase

Apache HBase is a noSQL database programmed in Java, but unlike other noSQL databases, it provides strong data consistency on reads and writes. HBase is a column-oriented key/value data store implemented to run on top of Hadoop Distributed File System (HDFS). HBase scales out horizontally in distributed compute clusters and supports rapid table-update rates. HBase focuses on scale, which enables it to handle very large database tables. Common scenarios include HBase tables that hold billions of rows and millions of columns. Another example is Facebook utilizes HBase as a structured data handler for its messaging infrastructure.

Critical part of the HBase architecture is utilization of the master nodes to manage region servers that distribute and process parts of data tables. HBase is part of the Hadoop ecosystem along with other services such as Zookeeper, Phoenix, Zeppelin.

### Apache Phoenix

Apache Phoenix provides the flexibility of late-bound, schema-on-read capabilities from NoSQL technology by leveraging HBase as its backing store. Phoenix has the power of standard SQL and JDBC APIs with full ACID transaction capabilities. Phoenix also enables online transaction processing (OLTP) and operational analytics in Hadoop specifically for low latency applications. Phoenix comes fully integrated to work with other products in the Hadoop ecosystem, such as Spark and Hive.

### Apache Zeppelin

Apache Zeppelin is a data science notebook that allows users to use interpreters to visualize their data with line, bar, pie, scatter charts and various other visualizations. The interpreter Phoenix will be used to visualized our weather data.

## IoT Weather Station powered by Connected Data Architecture

We have talked about each component within the project individually, now let's discuss at high level how each component connects to each other.

![cda-minifi-hdf-hdp-architecture](assets/tutorial1/cda-minifi-hdf-hdp-architecture.png)

**Figure 4:** IoT Weather Station and Connected Data Architecture Integration

**IoT Weather Station at the Raspberry Pi + Sense HAT + MiNiFi**

The IoT Weather Station is based at the Raspberry Pi and Sense HAT. At this location, the Raspberry Pi executes a python script that controls the Sense HAT sensors to generate weather data. MiNiFi is agent software that resides on the Raspberry Pi and acts as an edge node that ingests the raw data from the sensor.

**Connected Data Architecture at HDF + HDP Sandbox Nodes**

The combination of HDF and HDP create Connected Data Architecture. For prototyping purposes, you will be running a single node HDF sandbox container and a single node HDP sandbox container inside a docker containerized network that is running in the Guest VM or natively on your host machine. The way that sensor data gets into the Connected Data Architecture is through MiNiFi's connection to HDF NiFi via Site-To-Site. This protocol allows external agents to connect to NiFi by exposing IP address of its host and opening a socket port. NiFi will be used to preprocess the sensor data and add geographic enrichment. NiFi is located in the HDF Sandbox Container, which then makes connection to HBase via NiFi's HBase Client Service Controller. This Controller Service enables NiFi to connect to a remote HBase located on the HDP Sandbox Container by way of an "hbase-site.xml" configuration file that tells NiFi where HBase lives. Zookeeper handles the requests NiFi makes when it tries to connect and transfer data to HBase, if Zookeeper sends NiFi a response that it can connect to HBase, then data is stored in an HBase table. Once the data is stored in HBase, Phoenix is used to map to the HBase table. Visualization is performed using Zeppelin's Phoenix interpreter.

## Summary

Congratulations, you've finished the concepts tutorial! Now you are familiar with the technologies you will be utilizing to build the IoT Weather Station.

## Further Reading

- [Docker Overview](https://docs.docker.com/engine/docker-overview/)
- [Docker Engine Documentation](https://docs.docker.com/engine/)
- [Hortonworks DataFlow](https://hortonworks.com/products/data-center/hdf/)
- [Hortonworks Data Platform](https://hortonworks.com/products/data-center/hdp/)
- [Raspberry Pi Overview](https://www.raspberrypi.org/documentation/)
- [Internet of Things 101: Getting Started w/ Raspberry Pi](https://www.pubnub.com/blog/2015-05-27-internet-of-things-101-getting-started-w-raspberry-pi/)
- [Sense HAT Documentation](https://www.raspberrypi.org/documentation/hardware/sense-hat/)
- [Apache NiFi Overview](https://hortonworks.com/apache/nifi/)
- [MiNiFi Overview](https://hortonworks.com/blog/edge-intelligence-iot-apache-minifi/)
- [Apache HBase Overview](https://hortonworks.com/apache/hbase/)
- [Apache Phoenix Overview](https://hortonworks.com/apache/phoenix/)
- [Apache Zeppelin Overview](https://hortonworks.com/apache/zeppelin/)
