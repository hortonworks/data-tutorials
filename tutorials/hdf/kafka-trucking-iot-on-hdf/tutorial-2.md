---
title: Explore Kafka in the Demo
---

## Explore Kafka in the Demo

## Introduction

While the demo application runs, you will gain an understanding of how Kafka receives data from a producer at its particular topics.

## Outline

- [Environment Setup](#environment-setup)
- [Persist Data Into Kafka Topics](#persist-data-into-kafka-topics)
- [List Kafka Topics](#list-kafka-topics)
- [View Data in Kafka Topics](#view-data-in-kafka-topics)
- [Next: Learn Basic Operations of Kafka](#next-learn-basic-operations-of-kafka)

## Environment Setup

If you have the latest Hortonworks DataFlow (HDF) Sandbox installed, then the demo comes pre-installed.

Open a terminal on your local machine and access the sandbox through the shell-in-a-box method. Please visit [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#environment-setup) to review this method.

Before we can perform Kafka operations on the data, we must first have data in Kafka, so let's run the NiFi DataFlow Application. Refer to the steps in this module: **[Run NiFi in the Trucking IoT Demo](https://hortonworks.com/tutorial/nifi-in-trucking-iot-on-hdf/section/2/)**, then you will be ready to explore Kafka.

Turn Kafka component on if it's not already on through Ambari.

## Persist Data Into Kafka Topics

A NiFi simulator generates data of two types: TruckData and TrafficData as a CSV string. There is some preprocessing that happens on the data to prepare it to be split and sent by NiFi's Kafka producers to two separate Kafka Topics: **trucking_data_truck** and **trucking_data_traffic**.

## List Kafka Topics

From the terminal, we can see the two Kafka Topics that have been created:

~~~bash
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper localhost:2181
~~~

Results:

~~~bash
Output:
trucking_data_driverstats
trucking_data_joined
trucking_data_traffic
trucking_data_truck_enriched
~~~

## View Data in Kafka Topics

As messages are persisted into the Kafka Topics from the producer, you can see them appear in each topic by writing the following commands:

View Data for Kafka Topic: **trucking_data_truck_enriched**:

~~~bash
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --topic trucking_data_truck_enriched --from-beginning
~~~

View Data for Kafka Topic: **trucking_data_traffic**:

~~~bash
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --topic trucking_data_traffic --from-beginning
~~~

As you can see Kafka acts as a robust queue that receives data and allows for it to be transmitted to other systems.

~~~text
Note: You may notice the is data encoded in a format we cannot read, this format is necessary for Schema Registry. The reason we are using Schema Registry is because we need it for Stream Analytics Manager to pull data from Kafka.
~~~

## Next: Learn Basic Operations of Kafka

You have already become familiar with some Kafka operations through the command line, so let's explore basic operations to see how those topics were created, how they can be deleted and how we can use tools to monitor Kafka.
