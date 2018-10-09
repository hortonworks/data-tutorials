---
title: NiFi in Trucking IoT Use Case
---

# NiFi in Trucking IoT Use Case

## Outline

- [The IoT Use Case](#the-iot-use-case)
- [What is NiFi?](#what-is-nifi)
- [Architectural Overview](#architectural-overview)
- [Benefits of NiFi](#benefits-of-nifi)
- [Next: NiFi in Action](#next-nifi-in-action)

## The IoT Use Case

Visit the Storm tutorial to learn about the [Trucking IoT Use Case](https://hortonworks.com/tutorial/storm-in-trucking-iot-on-hdf/section/1/#the-iot-use-case).

## What is NiFi?

What is NiFi's role in this Stream Processing Application?

- NiFi acts as the producer that ingests data from the truck and traffic IoT devices, does simple event processing on the data, so that it can be split into TruckData and TrafficData that can be sent as messages to two Kafka topics.

To learn about what NiFi is, visit [What is Apache NiFi?](https://hortonworks.com/tutorial/analyze-transit-patterns-with-apache-nifi/section/1/#what-is-apache-nifi) from our Analyze Transit Patterns with Apache NiFi tutorial.

## Architectural Overview

At a high level, our data pipeline looks as follows:

~~~ text

MiNiFi Simulator -----> NiFi ----> Kafka

~~~

There is a data simulator that replicates MiNiFi's place in the data flow on IoT edge, MiNiFi is embedded on the vehicles, so the simulator generates truck and traffic data. NiFi ingests this sensor data. NiFi's flow performs preprocessing on the data to prepare it to be sent to Kafka.

## Benefits of NiFi

**Flow Management**

- _Guaranteed Delivery_: Achieved by persistent write-ahead log and content repository allow for very high transaction rates, effective load-spreading, copy-on-write, and play to the strengths of traditional disk read/writes.

- _Data Buffering with Back Pressure and Pressure Release_: If data being pushed into the queue reaches a specified limit, then NiFi will stop the process send data into that queue. Once data reaches a certain age, NiFi will terminate the data.

- _Prioritized Queuing_: A setting for how data is retrieved from a queue based on largest, smallest, oldest or other custom prioritization scheme.

- _Flow Specific QoS_: Flow specific configuration for critical data that is loss intolerant and whose value becomes of less value based on time sensitivity.

**Ease of Use**

- _Visual Command and Control_: Enables visual establishment of data flow in real-time, so any changes made in the flow will occur immediately. These changes are isolated to only the affected components, so there is not a need to stop an entire flow or set of flows to make a modification.

- _Flow Templates_: A way to build and publish flow designs for benefitting others and collaboration.

- _Data Provenance_: Taking automatic records and indexes of the data as it flows through the system.

- _Recovery/Recording a rolling buffer of fine-grained history_: Provides click to content, download of content and replay all at specific points in an object's life cycle.

**Security**

- _System to System_: Offers secure exchange through use of protocols with encryption and enables the flow to encrypt and decrypt content and use shared-keys on either side of the sender/recipient equation.

- _User to System_: Enables 2-Way SSL authentication and provides pluggable authorization, so it can properly control a user's access and particular levels (read-only, data flow manager, admin).

- _Multi-tenant Authorization_: Allows each team to manage flows with full awareness of the entire flow even parts they do not have access.

**Extensible Architecture**

- _Extension_:  Connects data systems no matter how different data system A is from system B, the data flow processes execute and interact on the data to create a uni-line or bidirectional line of communication.

- _Classloader Isolation_: NiFi provides a custom class loader to guarantee each extension bundle is as independent as possible, so component-based dependency problems do not occur as often. Therefore, extension bundles can be created without worry of conflict occurring with another extension.

- _Site-to-Site Communication Protocol_: Eases transferring of data from one NiFi instance to another easily, efficiently and securely. So devices embedded with NiFi can communicate with each other via S2S, which supports a socket based protocol and HTTP(S) protocol.

**Flexible Scaling Model**

- _Scale-out (Clustering)_: Clustering many nodes together. So if each node is able to handle hundreds of MB per second, then a cluster of nodes could be able to handle GB per second.

- _Scale-up & down_: Increase the number of concurrent tasks on a processor to allow more processes to run concurrently or decrease this number to make NiFi suitable to run on edge devices that have limited hardware resources. View [MiNiFi Subproject](https://cwiki.apache.org/confluence/display/MINIFI) to learn more about solving this small footprint data challenge.

## Next: NiFi in Action

We have become familiar with NiFi's role in the use case, next let's move onto seeing NiFi in action while the demo application runs.
