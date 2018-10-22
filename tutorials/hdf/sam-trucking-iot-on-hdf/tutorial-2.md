---
title: Create a SAM Topology
---

# Create a SAM Topology

## Objective

We are now familiar with the role stream processing plays in data science/engineering applications. Let's use Streaming Analytics Manager (SAM) to create stream topology.

Skills you will gain:

- Create a Service Pool, an Environment, and a SAM Application
- Create Schemas in Schema Registry needed for SAM Application
- Build, deploy and export a SAM topology
- Deploy NiFi DataFlow to source data into Kafka Topics that the SAM Application pulls data from
- Verify SAM stores data into Kafka Sink Queues using Kafka Commands
- Learn how to integrate NiFi, Kafka, Schema Registry with SAM

## Outline

- [Environment Setup](#environment-setup)
- [Trucking IoT SAM Topology](#trucking-iot-sam-topology)
- [Add a New SAM topology](#add-a-new-sam-topology)
- [Building the SAM Topology](#building-the-sam-topology)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Environment Setup

Start your HDF Sandbox via Docker, VMware or VirtualBox.

1\. Head to Ambari at `sandbox-hdf.hortonworks.com:8080`.

2\. Wait for SAM to start indicated by the green check mark.

> Note: If any other services are powered off, make sure to turn them on by clicking on the **service name**->**service actions**->**start**

**Deploy NiFi Producer**

Before we can create the SAM topology, we need to start the producer to store data into the queues that SAM will pull data from.

3\. Open NiFi at `http://sandbox-hdf.hortonworks.com:9090/nifi/`

4\. Drag the template icon to the left of the pencil onto the canvas. Choose the default option.

5\. In the Operate panel, select the gear icon. Click on the lighting symbol, for Scope, select Service and referencing components, then Enable and close.

6\. Press control (command) and A to select entire NiFi flow and in the Operate panel, press start.

> Note: NiFi flow should be kept running until the end of the tutorial.

![dataflow-for-NiFi](assets/images/dataflow.jpg)

> Note: If you want to learn more about how to build the NiFi Flow, refer to [NiFi in Trucking IoT](https://hortonworks.com/tutorial/nifi-in-trucking-iot-on-hdf/) tutorial.

## Trucking Iot SAM Topology

If you have the latest HDF Sandbox you will will have the Trucking-IoT-Demo under My Applications. Go through the process of creating a New Application where you will recreate the SAM topology and use the existing Trucking-IoT-Demo SAM topology as a reference.

## Add a New SAM topology

Now we have a data source for SAM to pull in data, we will build the Trucking IoT SAM topology.

1\. Go back to Ambari UI, click on the SAM service, then on the Summary page, click Quick Links, then SAM UI. You will be directed to this web address: `http://sandbox-hdf.hortonworks.com:7777/`

### Setup SAM

We need to setup SAM by creating a **service pool** and **environment** for our application. Since we are using the HDF Sandbox, it comes pre-loaded with an already created service pool and environment, so we will show you how you would create these two components if you had deployed a fresh HDF Platform that had no reference applications.

> Note: this section is less hands on because we already have the required components setup. If you want to skip this part, then you can head to **Add an Application** section.

Both components are accessible from the **Components** tab.

![components](assets/images/components.jpg)

### Create a Service Pool

1\. Open Service Pool

2\. In the AUTO ADD field is where you insert your Ambari Cluster URL. The information you must include is as follows, you would take the definition and overwrite it to be your Ambari URL:

~~~text
Definition:

http://ambari_host:port/api/v1/clusters/CLUSTER_NAME

Example:
http://sandbox-hdf.hortonworks.com:8080/api/v1/clusters/Sandbox
~~~

> Note: CLUSTER_NAME can be found in Ambari UI under admin(user)->Manage Ambari->Versions->Cluster

3\. Click AUTO ADD, you'll be prompted for Ambari login credentials as seen below::

![service_pool_credentials](assets/images/service_pool_credentials.jpg)

Use your **admin** credentials to sign in.

**Table 1**: Ambari Login credentials

| Username | Password |
|:---:|:---:|
| admin | **setup process |

The result after adding the Ambari Cluster URL will be that SAM retrieves all Ambari Services and creates a new service pool.

![hdf_service_pool](assets/images/hdf_service_pool.jpg)

> Note: To view the existing service pool: click the three squares near the service pool name, then press Edit.

### Create an Environment

1\. Open **Environments**

2\. On the top right of the page, you would click the plus button to add a new environment. When adding the environment for Trucking IoT application, we performed the following actions.

3\. Name the Environment. In our case, we chose the name:

~~~bash
SandboxEnvironment
~~~

4\. Provide a description. In our case, we wrote:

~~~bash
SandboxEnvironment
~~~

5\. Select Services. We selected all services:

~~~bash
Kafka, Storm, Ambari Infra, Zookeeper
~~~

6\. Then we clicked OK to add the new environment.

> Note: To view the existing environment: click the three squares near the environment name, then press Edit. An images similar to the one below will appear:

![existing_sandboxenvironment](assets/images/existing_sandboxenvironment.jpg)

### Add an Application

A quick recap, we just explored the pre-existing service pool and environment for the Trucking IoT SAM application we will build. The topology, you will build from scratch. Let's become SAM Developers.

1\. Click on the SAM Logo in the top right corner to enter the **My Applications** page.

2\. Click on the Add Symbol in the top right of the page, select **New Application**.

The **Add Application** window will appear, enter the following information:

~~~bash
Name: Trucking-IoT-Demo

Environment: SandboxEnvironment
~~~

Then press OK.

SAM will load the canvas, so you can start building your application.

## Building the SAM Topology

Before we start adding components to the canvas, lets verify our Kafka topics and schemas are already created that we need to pull in data and store data using SAM.

**Kafka Topics Dependency Verification**

1\. Open the sandbox web shell client: `http://sandbox-hdf.hortonworks.com:4200`

2\. Login is `root/hadoop`. Run the following command to list Kafka topics:

~~~bash
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper localhost:2181
~~~

Output you should see:

~~~bash
trucking_data_driverstats
trucking_data_joined
trucking_data_traffic
trucking_data_truck_enriched
~~~

If you don't see the topics listed above, then create them:

~~~bash
# trucking_data_driverstats
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 10 --topic trucking_data_driverstats

# trucking_data_joined
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 10 --topic trucking_data_joined

# trucking_data_traffic
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 10 --topic trucking_data_traffic

# trucking_data_truck_enriched
/usr/hdf/current/kafka-broker/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 10 --topic trucking_data_truck_enriched
~~~

**Note:** For more information on how Schemas are being registered into Schema Registry and the architecture works, visit [Schema Registry in Trucking IoT on HDF](https://hortonworks.com/tutorial/schema-registry-in-trucking-iot-on-hdf/)

You may be wondering, why we need Kafka topics and schemas? When we use Kafka Source components, we need a Kafka topic (queue) to pull in data from. The same idea can be applied for Kafka Sinks, but instead we store data into the queue. The schemas are needed to complement Kafka to provide data verification.

Lets begin designing and creating our topology!

**SOURCE**

1\. Add 2 KAFKA source components onto the canvas as shown in **Figure 1**.

![kafka_source_components](assets/images/kafka_source_components.jpg)

**Figure 1: Kafka Source Components**

2\. Configure both components. Double click on one of the components, their configuration window will appear.

Enter the following properties for the first Kafka Source you opened:

| KAFKA SOURCE     | Properties     |
| :------------- | :------------- |
| Name       | TrafficData       |
| **Tab**       | **REQUIRED**       |
| Cluster Name       | Sandbox      |
| Security Protocol       | PLAINTEXT       |
| Bootstrap Servers       | sandbox-hdf.hortonworks.com:6667       |
| Kafka Topic       | trucking_data_traffic       |
| Reader Schema Branch  | MASTER |
| Reader Schema Version | 1 |
| Consumed Group ID | c |
| **Tab**       | **OPTIONAL**       |
| First Poll Offset Strategy | EARLIEST |

When you are done, click OK.

| KAFKA SOURCE 1    | Properties     |
| :------------- | :------------- |
| Name       | TruckData       |
| **Tab**       | **REQUIRED**       |
| Cluster Name       | Sandbox      |
| Security Protocol       | PLAINTEXT       |
| Bootstrap Servers       | sandbox-hdf.hortonworks.com:6667       |
| Kafka Topic       | trucking_data_truck_enriched       |
| Reader Schema Branch  | MASTER |
| Reader Schema Version | 1 |
| Consumed Group ID | c |
| **Tab**       | **OPTIONAL**       |
| First Poll Offset Strategy | EARLIEST |

> Note: If you are not able to choose a Kafka Topic, it could be that Kafka is powered off. Verify that the service is on, you can do so by checking the service in the Ambari Dashboard.

When you are done, click OK.

**PROCESSOR**

3\. Add 3 processor components: JOIN, RULE and AGGREGATE onto the canvas.

![join_rule_aggregate](assets/images/join_rule_aggregate.jpg)

4\. The two Kafka sources have green bubbles on their rightside edge, click, hold and drag to connect to the JOIN processors grey bubble located on its leftside edge.

![connection](assets/images/connection.jpg)

5\. Configure all three components. Double click on each component, enter the following properties for the appropriate processor:

| JOIN   | Properties     |
| :------------- | :------------- |
| Name       | JoinStreams       |
| **Tab**       | **CONFIGURATION**       |
| Input | kafka_stream_1 |
| SELECT STREAM | kafka_stream_2 |
| SELECT FIELD WITH | routeId |
| JOIN TYPE | INNER |  
| SELECT STREAM | kafka_stream_1 |
| SELECT FIELD | routeId |
| WITH STREAM | kafka_stream_2 |
| WINDOW TYPE | Processing Time |
| WINDOW INTERVAL | 1 |
| WINDOW INTERVAL | Seconds |
| SLIDING INTERVAL | 1 |
| SLIDING INTERVAL | Seconds |
| OUTPUT FIELDS | eventTime as `eventTime`, truckId as `truckId` |
| OUTPUT FIELDS | driverId as `driverId`, truckId as `driverName` |
| OUTPUT FIELDS | routeId as `routeId`, routeName as `routeName` |
| OUTPUT FIELDS | latitude as `latitude`, longitude as `longitude` |
| OUTPUT FIELDS | speed as `speed`, eventType as `eventType` |
| OUTPUT FIELDS | foggy as `foggy`, rainy as `rainy` |
| OUTPUT FIELDS | windy as `windy`, congestionanLevel as `congestionLevel` |

6\. Once you click OK for the JOIN processor configuration, its bubbles change to green. Now connect JOIN processor to the RULE processor.

![join_rule_connect](assets/images/join_rule_connect.jpg)

Select **+Add New Rules** and enter the following properties: 

| RULE    | Properties     |
| :------------- | :------------- |
| Name       | FilterNormalEvents       |
| **Tab**       | **CONFIGURATION**       |
| New Rule `Rule Name`       | IsViolation       |
| New Rule `Description`       | IsViolation       |
| New Rule `Create Condition`       | `eventType <> 'Normal'`|

~~~bash
Query Preview:

eventType <> 'Normal'
~~~

![rule_condition](assets/images/rule_condition.jpg)

7\. Once you click OK, the new rule will appear in the table of rules for the RULE processor. Click OK again to save your configuration. Now connect RULE processor to the AGGREGATE processor.

FilterNormalEvents-AGGREGATE window will appear, select OK. Enter the following properties for the AGGREGATE processor:

| AGGREGATE    | Properties     |
| :------------- | :------------- |
| Name       | TimeSeriesAnalysis       |
| **Tab**       | **CONFIGURATION**       |
| SELECT KEYS | driverId, routeId |
| WINDOW INTERVAL TYPE | Time |
| WINDOW INTERVAL | 10 |
| WINDOW INTERVAL | Seconds |
| SLIDING INTERVAL | 10 |
| SLIDING INTERVAL | Seconds |
| TIMESTAMP FIELD | eventTime |
| LAG IN SECONDS | 1 |

Continue to enter the following expressions to FilterNormalEvents-AGGREGATE, to add a new expression select the plus sign next to the first aggregate expression. You can scroll down to view the additional expression fields.

| **AGGREGATE EXPRESSION** | **FIELDS NAME** |
|:---------------------| :----------------|
| AVG(speed)  | averageSpeed |
| SUM(foggy)  | totalFog  |
| SUM(rainy)  | totalRain |
| SUM(windy)  | totalWind |
| SUM(eventTime) | totalViolations |

![aggregate_expressions](assets/images/aggregate_expressions.jpg)

Once you click OK, the configuration has been confirmed.

8\. Add 2 KAFKA SINK components onto the canvas.

Connect TimeSeriesAnalysis processor to Kafka Sink 1 (ToDriverStats). Configure the processor with the following property values:

| KAFKA SINK 1   | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDriverStats     |
| CLUSTER NAME | Sandbox |
| Kafka Topic | trucking_data_driverstats |
| Writer Schema Branch | Master |
| Writer Schema Version | 1 |
| Security Protocol | PLAINTEXT |
| Bootstrap Servers | sandbox-hdf.hortonworks.com:6667 |

Click OK to confirm configuration.

Connect FilterNormalEvents processor to Kafka Sink 2 (ToDataJoined). Configure the processor with the following property values:

| KAFKA SINK 2  | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDataJoined    |
| CLUSTER NAME | Sandbox |
| Kafka Topic | trucking_data_joined |
| Writer Schema Branch | Master |
| Writer Schema Version | 1 |
| Security Protocol | PLAINTEXT |
| Bootstrap Servers | sandbox-hdf.hortonworks.com:6667 |

Click OK to confirm configuration.

After building the SAM topology, you can deploy it by pressing the green arrow:

![trucking_iot_topology](assets/images/sam_start.jpg)

You will see the status shows not running, once you run it the following window "Are you sure want to continue with this configuration?" will appear, make sure to configure it with the following properties:

| Application Configuration  |    |
| :------------- | :------------- |
| **General** | **Values** |
| NUMBER OF WORKERS       | 1     |
| NUMBER OF ACKERS | 1 |
| TOPOLOGY MESSAGE TIMEOUT (SECONDS) | 30 |
| TOPOLOGY WORKER JVM OPTIONS |  |
| NUMBER OF EVENT SAMPLING TASKS | 1 |

Click OK to confirm configuration.

![trucking_iot_topology_deployed](assets/images/sam_active.jpg)

You just deployed your SAM topology.

Lets open web shell client: `http://sandbox-hdf.hortonworks.com:4200`

Lets check the data in our Kafka Sink topics:

~~~bash
# trucking_data_driverstats
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --topic trucking_data_driverstats --from-beginning

# trucking_data_joined
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --topic trucking_data_joined --from-beginning
~~~

> Note: press control + C to exit from the Kafka view messages.

## Summary

Congratulations you just built a SAM topology. You learned how to pull in data from the source that supplies it, such as Kafka, using Kafka source component. You used Join, Rule and Aggregate processors to do processing on the data. You also used Kafka Sink components to store data into Kafka topics.

## Further Reading

- [Streaming Analytics Manager Overview](https://hortonworks.com/open-source/streaming-analytics-manager/)
- [Streaming Analytics Manager Documentation](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.1/index.html)
