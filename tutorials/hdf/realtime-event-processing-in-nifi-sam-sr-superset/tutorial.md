---
title: Real-Time Event Processing In NiFi, SAM, Schema Registry and SuperSet
author: sandbox-team
tutorial-id: 830
experience: Advanced
persona: Data Scientist & Analyst
source: Hortonworks
use case: Streaming
technology: Apache NiFi, Apache Storm, Apache Kafka, Streaming Analytics Manager, Schema Registry, Apache SuperSet, Druid
release: hdf-3.1.1
environment: Sandbox
product: HDF
series: HDF > Develop Data Flow & Streaming Applications > Hello World
---

# Real-Time Event Processing In NiFi, SAM, Schema Registry and Superset

## Introduction

In this tutorial, you will learn how to deploy a modern real-time streaming application. This application serves as a reference framework for developing a big data pipeline, complete with a broad range of use cases and powerful reusable core components. You will explore the NiFi Dataflow application, Kafka topics, Schemas and SAM topology. Finally, in Appendix A, you will learn how to visualize slices from Superset.

## Prerequisites

-   [Installed Hortonworks DataFlow (HDF) Sandbox](https://hortonworks.com/downloads/#sandbox)

## Outline

-   [Concepts](#concepts)
-   [Overview of Trucking IoT Ref App](#overview-of-trucking-iot-ref-app)
-   [Step 1: Explore Dataflow Application](#step-1-explore-dataflow-application)
-   [Step 2: View Schema Registry](#step-2-view-schema-registry)
-   [Step 3: Analyze Stream Analytics Application](#step-3-analyze-stream-analytics-application)
-   [Step 4: View the Storm Engine that Powers SAM](#step-4-view-the-storm-engine-that-powers-sam)
-   [Summary](#summary)
-   [Further Reading](#further-reading)
-   [Appendix A: Visualize Trucking Data with Superset Via CDA](#appendix-a-visualize-trucking-data-with-superset-via-cda)
-   [Appendix B: Trucking IoT GitHub Repo](https://github.com/orendain/trucking-iot/tree/master)

## Concepts

### Stream Analytics Manager (SAM)

Stream Analytics Manager is a drag and drop program that enables stream processing developers to build data topologies within minutes compared to traditional practice of writing several lines of code. A topology is a **directed acyclic graph (DAG)** of processors. Now users can configure and optimize how they want each component or processor to perform computations on the data. They can perform windowing, joining multiple streams together and other data manipulation. SAM currently supports the stream processing engine known as Apache Storm, but it will later support other engines such as Spark and Flink. At that time, it will be the users choice on which stream processing engine they want to choose.

### Apache Storm

Apache Storm is the current backend computational processing engine for Stream Analytics Manager. After the user builds their SAM topology, all the actual processing of data happens in a Storm topology, which is also a **DAG**, but is comprised of spouts and bolts with streams of tuples representing the edges.

A **spout** ingests the data usually from a Kafka Topic into the topology while **bolts** do all the processing. Thus, all the same components from the SAM topology are represented in the Storm topology, but as appropriate spouts and bolts.

Storm is the Open Source distributed, reliable, fault-tolerant system that handles real time analytics, scoring machine learning models, continuous static computations and enforcing Extract, Transform and Load (ETL) paradigms.

### Schema Registry

Schema Registry (SR) stores and retrieves Avro Schemas via RESTful interface. SR stores a version history containing all schemas. Serializers are provided to plug into Kafka clients that are responsible for schema storage and retrieve Kafka messages sent in Avro format.

### Kafka

Apache Kafka is an open source publish-subscribe based messaging system responsible for transferring data from one application to another.

### SuperSet

SuperSet is a visual, intuitive and interactive data exploration platform. This platform offers a fast way to create and share dashboards with friends and business clients of your visualized datasets. Various visualization options are available to analyze the data and interpret it. The Semantic Layer allows users to control how the data stores are displayed in the UI. The model is secure and allows users to intricate rules in which only certain features are accessible by select individuals. SuperSet can be integrated with Druid or other data stores (SQLAlchemy, Python ORM, etc) of the user's choice offering flexibility to be compatible with multiple systems.

### Druid

Druid is an open source analytics database developed for business intelligence queries on data. Druid provides low-latency live data ingestion, flexible data exploration and aggregation. Deployments often reach out to trillions of event in relation to numerous petabytes of data.

### Overview of Trucking IoT Ref App

The Trucking IoT Reference Application is built using Hortonworks DataFlow Platform.

The Trucking IoT data comes from a truck events simulator that is ingested by Apache NiFi, NiFi sends the data to Kafka topics which are then ingested by Stream Analytics Manager (SAM) to be stored into Druid. Superset is used to create a visual representation of the Druid data sources. A more in depth explanation of the pipeline will be explained as you explore the NiFi Dataflow application, Schema Registry, SAM, Druid and Superset.

### Step 1: Explore Dataflow Application

1\. Open the NiFi UI [http://sandbox-hdf.hortonworks.com:9090/nifi/](http://sandbox-hdf.hortonworks.com:9090/nifi/)

2\. The NiFi Dataflow application template: `Trucking IoT Demo` will appear on the canvas.

4\. Select NiFi configuration icon ![nifi_configuration](assets/images/nifi_configuration.jpg). Click on the Controller Services tab.

5\. The **HortonworksSchemaRegistry** should be enabled. If it's not enabled then select the lightning bolt symbol next to **HortonworksSchemaRegistry**.

![nifi_controller_services](assets/images/controller-services-en.jpg)

6\. In the "Enable Controller Service" window, under "Scope", select "Service and referencing components". Then click ENABLE.

![enable_hwx_sr](assets/images/enable_hwx_sr.jpg)

All controller services referencing **HortonworksSchemaRegistry** will also be enabled. Head back to the NiFi Dataflow.

Overview of the **7 processors** in the NiFi Flow:

-   **GetTruckingData** - Simulator generates TruckData and TrafficData in bar-delimited CSV

-   **RouteOnAttribute** - filters the _TrafficData_ and _TruckData_ into separate
data feeds

| Data Name | Data Fields    |
| :------------- | :------------- |
| TruckData       | eventTime, truckId, driverId, driverName, routeId, routeName, latitude, longitude, speed, eventType       |
| TrafficData       | eventTime, routeId, congestionLevel       |

_TruckData side of Flow_

-   **EnrichTruckData** - tags on three fields to the end of _TruckData_: "foggy",
"rainy", "windy"

-   **ConvertRecord** - reads incoming data with "CSVReader" and writes out Avro data with "AvroRecordSetWriter" embedding a "trucking_data_truck_enriched" schema onto each flowfile.

-   **PublishKafka_1_0** - stores Avro data into Kafka Topic "trucking_data_truck_enriched"

_TrafficData side of Flow_

-   **ConvertRecord** - converts CSV data into Avro data embedding a "trucking_data_traffic" schema onto each flowfile

-   **PublishKafka_1_0** - stores Avro data into Kafka Topic "trucking_data_traffic"

Overview of **5 controller services** used in the NiFi Flow:

-   **AvroRecordSetWriter - Enriched Truck Data** - writes contents of RecordSet in Binary
Avro Format (trucking_data_truck_enriched schema)

-   **AvroRecordSetWriter - Traffic Data** - writes contents of RecordSet in Binary
Avro Format (trucking_data_traffic schema)

-   **CSVReader - Enriched Truck Data** - returns each row in CSV file as a separate record (trucking_data_truck_enriched schema)

-   **CSVReader - Traffic Data** - returns each row in CSV file as a separate record
(trucking_data_traffic schema)

-   **HortonworksSchemaRegistry** - provides schema registry service for
interaction with Hortonworks Schema Registry

7\. Press `command+A` or `control+A` to select all the processors in the NiFi Dataflow and click on the start button ![nifi_start](assets/images/nifi_start.jpg).

![nifi-to-2kafka-2schemas](assets/images/nifi-to-2kafka-2schemas.jpg)

8\. To reduce resource consumption and footprint, when the **PublishKafka_1_0** processors reach about 500 input records, click on the stop button ![nifi_stop](assets/images/nifi_stop.jpg). This will take approximately 1 - 2 minutes.

9\. Stop **NiFi** service: **Ambari** -> **NiFi** -> **Service Actions** -> **Stop**

### Step 2: View Schema Registry

1\. Open the Schema Registry UI at [http://sandbox-hdf.hortonworks.com:7788/](http://sandbox-hdf.hortonworks.com:7788/)

![schema_registry_trucking_data](assets/images/schema_registry_trucking_data.jpg)

Overview of the essential **schemas** in the Schema Registry:

-   **trucking_data_joined** - model for truck event originating from a truck's onboard computer (EnrichedTruckAndTrafficData)

-   **trucking_data_truck_enriched** - model for truck event originating from a truck's onboard computer (EnrichedTruckData)

-   **trucking_data_traffic** model for eventTime, routeId, congestionLevel (TrafficData)

### Step 3: Analyze Stream Analytics Application

1\. Open Stream Analytics Manager (SAM) at [http://sandbox-hdf.hortonworks.com:7777/](http://sandbox-hdf.hortonworks.com:7777/)

2\. Click on the Trucking-IoT_Demo, then the green pencil on the right top corner. This should show an image similar to the one below, click on the **Run** button to deploy the topology:

![sam_start](assets/images/sam_start.jpg)

A window will appear asking if you want to continue deployment, click **Ok**.

3\. You will receive a notification that the SAM topology application deployed successfully and your topology will show Active Status in the bottom right corner.

![trucking_iot_sam_topology](assets/images/trucking_iot_sam_topology.jpg)

**Overview of the SAM Canvas:**

-   My Applications: Different Topology Projects
-   1st Left Sidebar: My Applications, Dashboard, Schema Registry, Model Registry, Configuration
-   2nd Left Sidebar: Different stream components (source, processor, sink)
-   Gear Icon: Configure topology settings
-   Status Icon: Start or Stop Topology

**Overview of SAM topology:**

-   **TrafficData** is the source component name, which pulls in data from the Kafka topic "trucking_data_traffic".

-   **EnrichedTruckData** is the source component name, which pull is data from the Kafka topic "trucking_data_truck_enriched"

-   **JoinStreams** joins streams "TrafficData" and "EnrichedTruckData" by "routeId".

-   **FilterNormalEvents** checks if non "Normal" eventType's occur, then it  will emit them.

-   **TimeSeriesAnalysis** computes the average of 10 samples of speed across a 10 second window period, calculates the sum across the same window period as before for foggy, rainy, windy and eventTime individually.

-   **ToDriverStats** stores the input from "TimeSeriesAnalysis": driveId, routeId, averageSpeed, totalFog, totalRain, totalWind, and totalViolations into Kafka topic "trucking_data_driverstats".

-   **ToDataJoined** stores the input from "FilterNormalEvents": eventTime, congestionLevel, truckId, driverId, driverName, routeId, routeName, latitude, longitude, speed, eventType, foggy, rainy, and windy into Kafka topic "trucking_data_joined".

### Step 4: View the Storm Engine that Powers SAM

1\. From Ambari, click on **Storm View**:

![storm-view](assets/images/storm_view.jpg)

![storm_view_dashboard](assets/images/storm_view_dashboard.jpg)

2\. Click on Topology Name: **streamline-1-Trucking-IoT-Demo**

![storm_topology](assets/images/storm_topology.jpg)

**Overview of the Storm View**

You can see the total number of **Emitted** `(16116)` and **Transferred** `(17436)` tuples after `10m 0s` under **TOPOLOGY STATS** for the entire topology. You can also see individual emitted and transferred tuples for each individual Spout and Bolt in the topology increase. If we hover over one of the spouts or bolts on the graph, we can see how much data they process and their latency.

-   Topology Summary
-   Topology Stats
-   Topology Static Visualization
-   Spout
-   Bolts
-   Topology Configuration



## Summary

Congratulations! You deployed the Trucking IoT demo that processes truck event data by using the NiFi data flow application to separate the data into two flows: _TruckData_ and _TrafficData_. These two flows are then transmitted into two Kafka robust queues tagged with Schema Registry schemas: _trucking_data_traffic_ and _trucking_data_truck_enriched. Stream Analytics Manager's (SAM) topology pulls in this data to join the two streams (or flows) by _routId_, and filter's non-normal events which then get split into two streams. One stream is sent to a Kafka sink directly the other stream is then further filtered with an aggregate processor then sent to a different Kafka sink.

## Further Reading

-   [Apache NiFi User Guide](https://nifi.apache.org/docs.html)
-   [Kafka Documentation](https://kafka.apache.org/documentation/)
-   [Schema Registry](https://docs.confluent.io/current/schema-registry/docs/index.html)
-   [Stream Analytics Manager User Guide](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.0.2/bk_streaming-analytics-manager-user-guide/content/ch_sam-manage.html)
-   [Superset](https://superset.incubator.apache.org/)


### Appendix A: Visualize Trucking Data with Superset Via CDA

### Prerequisites
- [Installed Hortonworks DataFlow (HDF) Sandbox](https://hortonworks.com/downloads/#sandbox)
- Enabled Connected Data Architecture:
     - [Enable CDA for VirtualBox](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/1/#enable-connected-data-architecture-cda---advanced-topic)
    - [Enable CDA for VMware](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/2/#enable-connected-data-architecture-cda---advanced-topic)
    - [Enable CDA for Docker ](https://hortonworks.com/tutorial/sandbox-deployment-and-install-guide/section/3/#enable-connected-data-architecture-cda---advanced-topic)

### Step 1: Configure SAM for CDA

1\. Open Stream Analytics Manager (SAM) at [http://sandbox-hdf.hortonworks.com:7777/](http://sandbox-hdf.hortonworks.com:7777/)

### Add a Service Pool for HDP

SAM needs to be told where to find the HDP node to allow data transmission between the HDF and HDP nodes.

1\. Hover over the wrench to open the Configuration dropdown, select **Service Pool**, so we can add a new service pool for HDP.

In the field to the left of AUTO ADD, include the following:

~~~bash
http://sandbox-hdp.hortonworks.com:8080/api/v1/clusters/Sandbox
~~~

and then click AUTO ADD.

2\. There will be a popup screen asking for username/password as seen below:

![service_pool_credentials](assets/images/service_pool_credentials.jpg)

Use your **admin** credentials to sign in.

**Table 1**: Ambari Login credentials

| Username | Password |
|:---:|:---:|
| admin | **setup process |

> [Setup Ambari Admin Password Manually](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#admin-password-reset)

You should now see services from the HDP Sandbox on the  SAM Service Pool Dashboard to the right of the HDF Sandbox Service Pool. We have now shared the web address of where SAM can find the services for the HDP Ambari Stack as seen on the image below:

![hdp_sandbox_service_pool](assets/images/hdp_sandbox_service_pool.jpg)

### Create a multi-node Environment

With SAM environments, we can select the services that we want our SAM application to have access to. So, we will add the necessary services from HDF and HDP Service Pools and create a multi-node environment from those services.

1\. Head to the Configuration dropdown, select **Environments**.

Click on the green plus symbol to create a new environment, add the following:

~~~bash
NAME: SandboxCDAEnvironment

DESCRIPTION: HDF and HDP Services Selected for CDA

SELECT SERVICES:

HDF:

KAFKA, STORM, ZOOKEEPER

HDP:

DRUID, HBASE, HDFS, HIVE
~~~

The configurations should look like this:

![create_multi_node_environment](assets/images/create_multi_node_environment.jpg)

Now that these configurations are complete, we are ready to import and run our SAM topology for CDA.

### Step 2: Deploy SAM Topology CDA Version

1\. Open Stream Analytics Manager (SAM) at [http://sandbox-hdf.hortonworks.com:7777/](http://sandbox-hdf.hortonworks.com:7777/)

2\. [Download the SAM topology for CDA](assets/templates/sam_topology/Trucking-IoT-CDA-V2.json) and save it somewhere on your computer as "Trucking-IoT-CDA-V2.json".

3\. Now on the SAM UI click the green plus sign and select **Import Application**

~~~bash
SELECT JSON FILE*
Choose File: Trucking-IoT-CDA-V2.json

APPLICATION NAME
Trucking-IoT-CDA

ENVIRONMENT
SandboxCDAEnvironment
~~~

4\. Click on the **Run** button to deploy the topology:

![sam_start](assets/images/sam_start_cda.jpg)

A window will appear asking if you want to continue deployment, click **Ok**.

5\. You will receive a notification that the SAM topology application deployed successfully and your topology will show Active Status in the bottom right corner.

**Overview of the SAM Canvas:**

-   My Applications: Different Topology Projects
-   1st Left Sidebar: My Applications, Dashboard, Schema Registry, Model Registry, Configuration
-   2nd Left Sidebar: Different stream components (source, processor, sink)
-   Gear Icon: configure topology settings
-   Status Icon: Start or Stop Topology

**Overview of SAM topology:**

-   **TrafficData** source data of "trucking_data_traffic" Kafka topic

-   **TruckEnrichData** source data of "trucking_data_truck_enriched" Kafka topic

-   **JoinStreams** stream TruckEnrichData and TrafficData by "routeId"

-   **FilterEvents** checks if not "Normal" eventType, then will emit them

-   **AverageSpeed** computes average speed for driverId along routeId

-   **ToDruidStore1** stores violation events from FilterEvents processor into Druid

-   **ToDataLake1** store violation events from FilterEvents processor into HDFS

-   **ToDruidStore2** stores average speed events into Druid

-   **ToDataLake2** store average speed events into HDFS

### Step 3: Visualize Trucking Data Via Superset

1\. Open Ambari at `http://sandbox-hdp.hortonworks.com:8080/`. User credentials are `username/password = raj_ops/raj_ops`

2\. Turn on the HDFS, YARN, Druid and Superset services and make sure to turn off maintenance mode.

For example, to turn on **HDFS**, click on the service name in Ambari, click on the **Service Actions** dropdown and click **Start**. In the window, you will be asked if you want to start, confirm and also click on the checkbox to turn off maintenance mode.

3\. Open Superset at [http://sandbox-hdp.hortonworks.com:9089/](http://sandbox-hdp.hortonworks.com:9089/)

>Note: The username and password for Superset is `admin/admin`

4\. Wait about 25 - 30 minutes for Kafka data to be consumed, then periodically, select the **Sources** dropdown and click on **Refresh Druid Metadata**. Eventually, the two Druid data sources will appear.

![refresh_metadata](assets/images/refresh_metadata.jpg)

5\. Select **average-speed-cube-01** druid data source.

6\. You will be taken to the Superset visualization slice where you can visualize that druid data source.

![superset_visual_slice](assets/images/superset_visual_slice.jpg)

7\. Under **Datasource & Chart Type**, select Visualization Type: **Sunburst**.

![visual_type](assets/images/visual_type.jpg)

8\. Under Hierarchy, add **driverId**, **speed_AVG**.

9\. Press on **Query** to visualize the data into a Sunburst representation.

![press-on-query](assets/images/press-on-query.jpg)

10\. Select **Save as** and name the slice: `AvgSpeedSunburst`. Create a new dashboard and call it: `Trucking-IoT-Demo`. Click **Save**.

![save_slice](assets/images/save_slice.jpg)

The following visualization slice is a "Sunburst" of **average-speed-cube-01** data source.

![sunburst_visual_slice](assets/images/sunburst_avgspeed.jpg)

The following visualization slice is a "Sunburst" of **violation-events-cube-01** data source:

![sunburst_driverviolation](assets/images/sunburst_driverviolation.jpg)

All created visualization slices will be sent to the dashboard you assign them to, in the two above examples, both slices are apart of the `Trucking-IoT-Demo` dashboard.

![superset_dashboard](assets/images/superset_dashboard.jpg)


### Appendix B: Trucking IoT GitHub Repo

~~~
https://github.com/orendain/trucking-iot/tree/master
~~~
