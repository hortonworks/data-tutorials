---
title: Concepts
---

# Concepts

## Introduction

In this tutorial, you will strengthen your foundation of technologies used in real-time event processing. You will learn in detail how Apache Kafka sends messages, the process Apache Storm undergoes to collect that data and the process involved for HBase to read that streaming data.

## Prerequisites
- Downloaded and Installed the latest [Hortonworks Sandbox](https://hortonworks.com/products/hortonworks-sandbox/#install)
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline
- [1st Concept: Apache NiFi](#concepts-apache-nifi)
- [2nd Concept: Apache Kafka](#concepts-apache-kafka)
- [3rd Concept: Apache Storm](#concepts-apache-storm)
- [4th Concept: Kafka on Storm](#concepts-kafka-on-storm)
- [Further Reading](#further-reading-concepts)

## 1st Concept: Apache NiFi <a id="concepts-apache-nifi"></a>

NiFi works with Apache Kafka, Apache Storm, Apache HBase and Spark for real-time distributed messaging of streaming data. NiFi is an excellent platform for ingesting real-time streaming data sources, such as the internet of things, sensors and transactional systems. If the data that comes in is garbage data, NiFi offers tools to filter out the undesired data. Additionally, NiFi can also act as a messenger and send data to the desired location.

### Goals of this module:

- Understand how Apache NiFi works

### How NiFi Works

NiFi’s system design can be thought of as an Automated Teller Machine, where incoming data is securely processed and written sequentially to disk. There are four main components involved in moving data in and out of NiFi:

- FlowFile
- Processor
- Connections
- Flow Controller

![Image of NiFi Flow](assets/concepts/image_of_nifi_flow.png)

In NiFi, a **FlowFile** is data brought into the flow from any data source and moves through the dataflow. **Connections** are linkages between components that enable FlowFiles to move throughout the dataflow. A **Flow Controller** regulates the exchange of FlowFiles between processors. **Processors** are actions taken on the FlowFiles to process their content and attributes to ensure desired data moves throughout the dataflow to eventually be stored at a secure location. Therefore, NiFi acts as a Producer to publish messages to one or more topics. So, at a high level, producers send messages over the network to the Kafka cluster.

## 2nd Concept: Apache kafka <a id="concepts-apache-kafka"></a>

In a modern data architecture built on YARN-enabled Apache Hadoop, Kafka works in combination with Apache Storm, Apache HBase and Apache Spark for real-time distributed messaging of streaming data. Kafka is an excellent low latency messaging platform for real-time streaming data sources, such as the internet of things, sensors, and transactional systems.  Whatever the industry or use case, Kafka brokers massive message streams for low-latency analysis in Enterprise Apache Hadoop.
Kafka is fully supported and included in HDP today.

### Goals of this module:

- Understand Apache Kafka Architecture
- Understand how Apache Kafka works

### What Kafka Does

Apache Kafka supports a wide range of use cases as a general-purpose messaging system for scenarios where high throughput, reliable delivery, and horizontal scalability are important. Apache Storm and Apache Spark both work very well in combination with Kafka. Common use cases include:
- Stream Processing
- Website Activity Tracking
- Metrics Collection and Monitoring
- Log Aggregation
Some of the important characteristics that make Kafka such an attractive option for these use cases include the following:

| Feature | Description |
|---------|-------------|
| Scalability | Distributed messaging system scales easily with no downtime |
| Durability | Persists messages on disk, and provides intra-cluster replication |
| Reliability | Replicates data, supports multiple consumers, and automatically balances consumers in case of failure |
| Performance | High throughput for both publishing and subscribing, with disk structures that provide constant performance even with many terabytes of stored messages |

### How Kafka Works

Kafka’s system design can be thought of as that of a distributed commit log, where incoming data is written sequentially to disk. There are four main components involved in moving data in and out of Kafka:

- Topics
- Producers
- Consumers
- Brokers

![Image of Kafka Flow](assets/concepts/01_kafka_cluster.png)

In Kafka, a **Topic** is a user-defined category to which messages are published. NiFi will act in the role of Producers to publish messages to one or more topics and **Consumers** subscribe to topics and process the published messages. At a high level, producers send messages over the network to the Kafka cluster, which in turn serves them up to consumers. Finally, a Kafka cluster consists of one or more servers, called **Brokers** that manage the persistence and replication of message data (i.e. the commit log).

![Image of Kafka Partitions](assets/concepts/02_kafka_partitions.png)

One of the keys to Kafka’s high performance is the simplicity of the brokers’ responsibilities. In Kafka, topics consist of one or more Partitions that are ordered, immutable sequences of messages. Since writes to a partition are sequential, this design greatly reduces the number of hard disk seeks (with their resulting latency).
Another factor contributing to Kafka’s performance and scalability is the fact that Kafka brokers are not responsible for keeping track of what messages have been consumed – that responsibility falls on the consumer. In traditional messaging systems, such as JMS, the broker bore this responsibility, severely limiting the system’s ability to scale as the number of consumers increased.

![Image of Brokers w/ Zookeeper](assets/concepts/03_kafka_zookeeper.png)

For Kafka consumers, keeping track of which messages have been consumed (processed) is simply a matter of keeping track of an **Offset**, which is a sequential id number that uniquely identifies a message within a partition. Because Kafka retains all messages on disk (for a configurable amount of time), consumers can rewind or skip to any point in a partition simply by supplying an offset value. Finally, this design eliminates the potential for back-pressure when consumers process messages at different rates.

## 3rd Concept: Apache Storm <a id="concepts-apache-storm"></a>

Apache Storm is a distributed real-time computation system for processing large volumes of high-velocity data in parallel and at scale. Storm is to realtime data processing as Apache Hadoop and MapReduce are to batch data processing. With its simple programming interface, Storm allows application developers to write applications that analyze streams of tuples of data; a tuple may can contain object of any type.

At the core of Storm’s data stream processing is a computational topology, which is discussed below. This topology of nodes dictates how tuples are processed, transformed,aggregated, stored, or re-emitted to other nodes in the topology for further processing.

### Storm on Apache Hadoop YARN

Storm on YARN is powerful for scenarios requiring  continuous analytics, real-time predictions, and continuous monitoring of operations. Eliminating a need to have dedicated silos, enterprises using Storm on YARN benefit on cost savings (by accessing the same datasets as other engines and applications on the same cluster) and on security, data governance, and operations (by employing the same compute resources managed by YARN.

### Storm in the Enterprise

Some of the specific new business opportunities include: real-time customer service management, data monetization, operational dashboards, or cyber security analytics and threat detection.

Storm is extremely fast, with the ability to process over a million records per second per node on a cluster of modest size. Enterprises harness this speed and combine it with other data access applications in Hadoop to prevent undesirable events or to optimize positive outcomes.

Here are some typical "prevent" and "optimize" use cases for Storm.

|---|"Prevent" Use Cases| "Optimize" Use Cases |
|---|-------------------|----------------------|
| Financial Services | Securities fraud, Operational risks & compliance violations | Order routing, Pricing |
| Telecom | Security breaches, Network outages | Bandwidth allocation, Customer service |
| Retail | Shrinkage, Stock outs | Offers, Pricing |
| Manufacturing| Preventative maintenance, Quality assurance | Supply chain optimization, Reduced plant downtime |
| Transportation | Driver monitoring, Predictive maintenance | Routes, Pricing |
| Web | Application failures, Operational issues | Personalized content|

Now with Storm on YARN, a Hadoop cluster can efficiently process a full range of workloads from real-time to interactive to batch. [Storm](http://storm.apache.org/about/simple-api.html) is simple, and developers can write Storm topologies using [any programming language](http://storm.apache.org/about/multi-language.html).
Five characteristics make Storm ideal for real-time data processing workloads. Storm is:

- **Fast** – benchmarked as processing one million 100 byte messages per second per node
- **Scalable** – with parallel calculations that run across a cluster of machines
- **Fault-tolerant** – when workers die, Storm will automatically restart them. If a node dies, the worker will be restarted on another node.
- **Reliable** – Storm guarantees that each unit of data (tuple) will be processed at least once or exactly once. Messages are only replayed when there are failures.
Easy to operate – standard configurations are suitable for production on day one. Once deployed, Storm is easy to operate.

### How Storm Works

_Storm Cluster Components_
A storm cluster has three sets of nodes:

- **Nimbus** node (master node, similar to the Hadoop JobTracker):
  - Uploads computations for execution
  - Distributes code across the cluster
  - Launches workers across the cluster
  - Monitors computation and reallocates workers as needed
- **ZooKeeper** nodes – coordinates the Storm cluster
- **Supervisor** nodes – communicates with Nimbus through Zookeeper, starts and stops workers according to signals from Nimbus

![Image of Storm-Zookeeper](assets/concepts/04_storm_layout.png)

Five key abstractions help to understand how Storm processes data:

- **Tuples**– an ordered list of elements. For example, a “4-tuple” might be (7, 1, 3, 7)
- **Streams** – an unbounded sequence of tuples.
- **Spouts** –sources of streams in a computation (e.g. a Twitter API)
- **Bolts** – process input streams and produce output streams. They can run functions, filter, aggregate, or join data, or talk to databases.
- **Topologies** – the overall calculation, represented visually as a network of spouts and bolts (as in the following diagram)

![Img of Spouts and Bolts](assets/concepts/05_spouts_and_bolts.png)

Storm users define topologies for how to process the data when it comes streaming in from the spout. When the data comes in, it is processed and the results are passed onto to other bolts or stored in Hadoop.

Learn more about how the community is working to [integrate Storm with Hadoop](https://hortonworks.com/labs/storm) and improve its readiness for the enterprise.

### Storm Topologies

A Storm cluster is similar to a Hadoop cluster. Whereas on Hadoop you run "MapReduce jobs," on Storm you run "topologies." "Jobs" and "topologies" are different -- one key difference is that a MapReduce job eventually finishes, whereas a topology processes messages forever (or until you kill it).

There are two kinds of nodes on a Storm cluster: the master node and the worker nodes. The master node runs a daemon called "Nimbus" that is similar to Hadoop's "JobTracker". Nimbus is responsible for distributing code around the cluster, assigning tasks to machines, and monitoring for failures.

Each worker node runs a daemon called the "Supervisor." It  listens for work assigned to its machine and starts and stops worker processes as dictated by  Nimbus. Each worker process executes a subset of a topology; a running topology consists of many worker processes spread across many machines.

All coordination between Nimbus and the Supervisors is done through a [Zookeeper](http://zookeeper.apache.org/) cluster. Additionally, the Nimbus daemon and Supervisor daemons are fail-fast and stateless; all state is kept in Zookeeper or on local disk. This means you can kill -9 Nimbus or the Supervisors and they'll start back up like nothing happened. Hence, Storm clusters are stable and fault-tolerant

### Streams Within Storm Topologies

The core abstraction in Storm is the "stream." It is  an unbounded sequence of tuples. Storm provides the primitives for transforming a stream into a new stream in a distributed and reliable way. For example, you may transform a stream of tweets into a stream of trending topics.

The basic primitives Storm provides for doing stream transformations are "spouts" and "bolts." Spouts and bolts have interfaces that you, as an application developer, implement to run your application-specific logic.

A spout is a source of streams. For example, a spout may read tuples off of a Kafka Topics and emit them as a stream. Or a spout may connect to the Twitter API and emit a stream of tweets.

A bolt consumes any number of input streams, does some processing, and possibly emits new streams. Complex stream transformations, like computing a stream of trending topics from a stream of tweets, require multiple steps and thus multiple bolts. Bolts can do anything from run functions, filter tuples, do streaming aggregations, do streaming joins, talk to databases, and more.

Networks of spouts and bolts are packaged into a "topology," which is the top-level abstraction that you submit to Storm clusters for execution. A topology is a graph of stream transformations where each node is a spout or bolt. Edges in the graph indicate which bolts are subscribing to which streams. When a spout or bolt emits a tuple to a stream, it sends the tuple to every bolt that subscribed to that stream.

![Another Img of spouts and bolts](assets/concepts/06_more_spouts_and_bolts.png)

Links between nodes in your topology indicate how tuples should be passed around. For example, if there is a link between Spout A and Bolt B, a link from Spout A to Bolt C, and a link from Bolt B to Bolt C, then every time Spout A emits a tuple, it will send the tuple to both Bolt B and Bolt C. All of Bolt B's output tuples will go to Bolt C as well.

Each node in a Storm topology executes in parallel. In your topology, you can specify how much parallelism you want for each node, and then Storm will spawn that number of threads across the cluster to do the execution.

A topology runs forever, or until you kill it. Storm will automatically reassign any failed tasks. Additionally, Storm guarantees that there will be no data loss, even if machines go down and messages are dropped.

## 4th Concept: Kafka on Storm <a id="concepts-kafka-on-storm"></a>

Hortonworks Data Platform’s YARN-based architecture enables multiple applications to share a common cluster and data set while ensuring consistent levels of response made possible by a centralized architecture. Hortonworks led the efforts to on-board open source data processing engines, such as [Apache Hive](https://hortonworks.com/hadoop/hive), [HBase](https://hortonworks.com/hadoop/hbase), [Accumulo](https://hortonworks.com/hadoop/accumulo), [Spark](https://hortonworks.com/hadoop/spark), [Storm](https://hortonworks.com/hadoop/storm) and others, on [Apache Hadoop YARN](https://hortonworks.com/hadoop/yarn/).

In this tutorial, we will focus on one of those data processing engines—[Apache Storm](https://hortonworks.com/hadoop/storm)—and its relationship with [Apache Kafka](https://hortonworks.com/hadoop/kafka). I will describe how Storm and Kafka form a multi-stage event processing pipeline, discuss some use cases, and explain Storm topologies.

### Goals of this tutorial:

- Understand Relationship between Apache Kafka and Apache Storm
- Understand Storm topologies

### Kafka on Storm:

An oil refinery takes crude oil, distills it, processes it and refines it into useful finished products such as the gas that we buy at the pump. We can think of Storm with Kafka as a similar refinery, but data is the input. A real-time data refinery converts raw streaming data into finished data products, enabling new use cases and innovative business models for the modern enterprise.

Apache Storm is a distributed real-time computation engine that reliably processes unbounded streams of data. While Storm processes stream data at scale, Apache Kafka processes messages at scale. Kafka is a distributed pub-sub real-time messaging system that provides strong durability and fault tolerance guarantees.
Storm and Kafka naturally complement each other, and their powerful cooperation enables real-time streaming analytics for fast-moving big data. HDP 2.4 contains the results of Hortonworks’ continuing focus on making the Storm-Kafka union even more powerful for stream processing.

![Img of Cluster Layout](assets/concepts/07_hadoop_cluster.png)

Conceptual Reference Architecture for Real-Time Processing in HDP 2.2

![Image of Event Processing Pipeline](assets/concepts/08_event_processing_pipeline.png)

Conceptual Introduction to the Event Processing Pipeline

In an event processing pipeline, we can view each stage as a purpose-built step that performs some real-time processing against upstream event streams for downstream analysis. This produces increasingly richer event streams, as data flows through the pipeline:

- raw events stream from many sources,
- those are processed to create events of interest, and
- events of interest are analyzed to detect significant events.

Here are some typical uses for this event processing pipeline:

- a. High Speed Filtering and Pattern Matching
- b. Contextual Enrichment on the Fly
- c. Real-time KPIs, Statistical Analytics, Baselining and Notification
- d. Predictive Analytics
- e. Actions and Decisions

### Build the Data Refinery with Topologies

To perform real-time computation on Storm, we create “topologies.” A topology is a graph of a computation, containing a network of nodes called “Spouts” and “Bolts.” In a Storm topology, a Spout is the source of data streams and a Bolt holds the business logic for analyzing and processing those streams.

![Storm and Kafka Pipelines](assets/concepts/09_storm_topologies.png)

Hortonworks’ focus for Apache Storm and Kafka has been to make it easier for developers to ingest and publish data streams from Storm topologies. The first topology ingests raw data streams from Kafka and fans out to HDFS, which serves as persistent store for raw events. Next, a filter Bolt emits the enriched event to a downstream Kafka Bolt that publishes it to a Kafka Topic. As events flow through these stages, the system can keep track of data lineage that allows drill-down from aggregated events to its constituents and can be used for forensic analysis. In a multi-stage pipeline architecture, providing right cluster resources to most intense part of the data processing stages is very critical, an “Isolation Scheduler” in Storm provides the ability to easily and safely share a cluster among many topologies.
In summary, refinery style data processing architecture enables you to:

-   Incrementally add more topologies/use cases
-   Tap into raw or refined data streams at any stage of the processing
-   Modularize your key cluster resources to most intense processing phase of the pipeline

## Further Reading <a id="further-reading-concepts"></a>
-   [Apache NiFi](https://nifi.apache.org/docs/nifi-docs/)
-   [Apache Storm](http://storm.apache.org/)
-   [Apache Kafka](http://kafka.apache.org/)
