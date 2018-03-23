---
title: Real Time Data Ingestion in HBase and Hive using Storm
---

# Real Time Data Ingestion in HBase and Hive using Storm

## Introduction

The Trucking business is a high-risk business in which truck drivers venture into remote areas, often in  harsh weather conditions and chaotic traffic on a daily basis. Using this solution illustrating Modern Data Architecture with Hortonworks Data Platform, we have developed a centralized management system that can help reduce risk and lower the total cost of operations.

This system can take into consideration adverse weather conditions, the driver's driving patterns, current traffic conditions and other criteria to alert and inform the management staff and the drivers themselves when risk factors run high.

In previous tutorial, we have explored generating and capturing streaming data with [Apache NiFi](https://hortonworks.com/tutorial/realtime-event-processing-nifi-kafka-storm#section_4) and [Apache Kafka](https://hortonworks.com/tutorial/realtime-event-processing-nifi-kafka-storm#section_5).

In this tutorial, we will build a solution to ingest real time streaming data into HBase using Storm. Storm has a spout that reads truck_events data from Kafka and passes it to bolts, which process and persist the data into Hive & HBase tables.

## Prerequisites

- Tutorial 0: Set Up Simulator, Apache Services and IDE Environment
- Tutorial 1: Ingest, Route and Land Real Time Events with Apache NiFi
- Tutorial 2: Capture Real Time Events with Apache Kafka
- Downloaded and Installed [Hortonworks Sandbox](https://hortonworks.com/products/hortonworks-sandbox/#install)
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)
- [Hive Quick Start](https://hbase.apache.org/book.html#quickstart)

## Outline

*   [HBase](#hbase-concept-lab3)
*   [Apache Storm](#apache-storm-concept-lab3)
*   [Step 1: Create Tables in HBase](#step1-create-tables-hbase-lab3)
*   [Step 2: Launch new Storm Topology](#step3-launch-new-storm-topology-lab3)
*   [Step 3: Verify Data in HBase](#step4-verify-data-hdfs-hbase-lab3)
*   [Summary](#summary)
*   [Further Reading](#further-reading-lab3)

<!--
*   [Appendix A: Run the Trucking Demo with NiFi Integration](#run-the-trucking-demo-lab3)
-->

## HBase <a id="hbase-concept-lab3"></a>

HBase provides near real-time, random read and write access to tables (or to be more accurate 'maps') storing billions of rows and millions of columns.

In this case, once we store this rapidly and continuously growing dataset from Internet of Things (IoT), we will be able to perform a swift lookup for analytics regardless of the data size.

## Apache Storm <a id="apache-storm-concept-lab3"></a>

Apache Storm is an Open Source distributed, reliable, fault–tolerant system for real time processing of large volume of data.
It's used for:
*   Real time analytics
*   Scoring machine learning modeles
*   Continuous statics computations
*   Operational Analytics
*   And, to enforce Extract, Transform, and Load (ETL) paradigms.


A Storm Topology is network of Spouts and Bolts. The Spouts generate streams, which contain sequences of tuples (data) while the Bolts process input streams and produce output streams. Hence, the Storm Topology can talk to databases, run functions, filter, merge or join data. We will be using Storm parse data, perform complex computations on truck events and send data to HBase Tables.
*   **Spout**: Works on the source of data streams. In the "Truck Events" use case, Spout will read data from Kafka topics.
*   **Bolt**: Spout passes streams of data to Bolt which processes and persists  it to a data store or sends it downstream to another Bolt. We have a RouteBolt that transforms the tuple and passes that data onto the other for further processing. We have 3 HBase bolts that write to 3 tables.

Learn more about Apache Storm at the [Storm Documentation page](http://storm.apache.org/releases/1.0.0/index.html).

## Tutorial Overview

*   Create HBase Tables
*   Deploy Storm Topology
*   Analyze a Storm Spout and several Bolts.
*   Store Persisting data into HBase.
*   Verify Data Stored in HBase.


## Step 1: Create tables in HBase <a id="step1-create-tables-hbase-lab3"></a>

*   Create HBase tables

We will work with 3 Hbase tables in this tutorial.

The first table stores **all events** generated, the second stores only
**dangerous events** and third stores the **number of incidents per driverId**.

~~~
su hbase

hbase shell

create 'driver_events', 'allevents'  
create 'driver_dangerous_events', 'events'
create 'driver_dangerous_events_count', 'counters'
list  
exit
~~~

Now let's exit from hbase user,  type `exit`.

- **driver_events** can be thought of as **All Events** table
- **driver_dangerous_events** can be thought of as **Dangerous Events** Table
- **driver_dangerous_events_count** can be thought of as
**Incidents Per Driver** Table

> Note: 'driver_events' is the table name and 'allevents' is column family.
In the script above, we have one column family. Yet, if we want we can have
multiple column families. We just need to include more arguments.


![Screen Shot 2015-06-04 at 7.03.00 PM.png](assets/lab2-hbase-hive-storm/hbase_tables_iot.png)


<!--
*   [Step 2: Run the Automation script: Setup Demo Modules](#step2-run-auto-script-lab3)
### Step 2: Run the Automation script: Setup Demo Modules <a id="step2-run-auto-script-lab3"></a>

Since this tutorial series is based on part of the trucking demo, there are many modules that need to be setup for the demo outside the scope of the tutorial. We manually setup NiFi, Kafka, HBase and Hive for the demo. Since there are other particular modules in the demo irrelevant from what we are learning in the tutorial series, we will run an automation script to setup the other modules that way we will be able to use storm for ingesting data in HBase with no issues.

1\. Update ambari admin login variables defined at the top in **user-env.sh** file, so the automation script can have the privileges to setup the demo modules. Enter the **username and password** you use to login into to Ambari as an admin. Open a terminal, type:

~~~
vi ~/iot-truck-streaming/user-env.sh
~~~

The file will open as in the image below:

![user_env_sh_setup_auto_script_iot](assets/lab2-hbase-hive-storm/user_env_sh_setup_auto_script_iot.png)

For the ambari configuration credentials: user='admin', pass=what you set it up as manually. For example, after setting up my password, I would enter user='admin', pass='h@d0op.'

Press `esc` and then type `:wq` to exit the editor.

2\. After you update the **user-env.sh** file, we will also need to verify whether the hostnames in the **config.properties** file match the appropriate hostnames for services on HDP. If they do not match, then update the hostname. For example, let's check the **kafka.brokers** host, open Ambari dashboard. Hover to the left side bar, click on **Kafka**. At the top next to the `Summary` tab, click on the `Configs` tab. Under **Kafka Broker** Section, examine **Kafka Broker host** and **listeners** field. You should see the following image:

![kafka_broker_hostname_verify](assets/lab2-hbase-hive-storm/kafka_broker_hostname_verify.png)

Notice Kafka Broker host = sandbox.hortonworks.com
Listeners = localhost:6667

Thus, our **Kafka Broker and Listenrs host** = `sandbox.hortonworks.com:6667`

In our **config.properties** file, under Stream Simulator Config, it shows:

![config_properties_file_verify_hosts_match](assets/lab2-hbase-hive-storm/config_properties_file_verify_hosts_match.png)

> Note: In the config.properties file Kafka.brokers=sandbox.hortonworks.com:6667

Since the **kafka.brokers** hostname in the **config.properties** file matches kafka brokers hostname on HDP, we verified that hostname is up to date. Now let’s verify the other hostnames in the config.properties file match the ones on HDP. If there is a mismatch, update the config.properties file.

3\. Now we can run the installdemo.sh script to automatically setup the background services for the trucking demo. Type the following command:

~~~
cd iot-truck-streaming/
./installdemo.sh
~~~

Once we build and install the necessary modules for the demo, we are ready to deploy our storm topology.
-->

## Step 2: Launch Storm Topology <a id="step3-launch-new-storm-topology-lab3"></a>

Recall that the source code is under directory path
`iot-truck-streaming/storm-streaming/src/`.

The pre-compiled jars are under the directory path
`iot-truck-streaming/storm-streaming/target/`.

> Note: Back in Tutorial 0 in which we set up the Trucking Demo, we used maven
to create the target folder.

### 2.1 Verify Kafka is Running & Deploy Topology

1\. Verify that Kafka service is running using Ambari dashboard. If not, start the Kafka service as we did in tutorial 3.

2\. Deploy Storm Topology

We now have 'supervisor' daemon and Kafka processes running.
To do real-time computation on Storm, you create what are called "topologies". A topology is a Directed Acyclic Graph (DAG) of spouts and bolts with streams of tuples representing the edges. Each node in a topology contains processing logic, and links between nodes indicate how data should be passed around between nodes.

Running a topology is straightforward. First, you package all your code and dependencies into a single jar. In tutorial 0 when we set up our IDE environment, we ran mvn clean package after we were satisfied with the state of our code for the topology, which packaged our storm project into a **storm...SNAPSHOT.jar**. The command below will deploy a new Storm Topology for Truck Events.

~~~bash
[root@sandbox ~]# cd ~/iot-truck-streaming
[root@sandbox iot-truck-streaming]# storm jar storm-streaming/target/storm-streaming-1.0-SNAPSHOT.jar com.hortonworks.streaming.impl.topologies.TruckEventKafkaExperimTopology /etc/storm_demo/config.properties
~~~

You should see that the topology deployed successfully:

![Screen Shot 2015-06-04 at 7.55.23 PM.png](assets/lab2-hbase-hive-storm/storm_topology_submitted_success_storm_iot.png)

This runs the class **TruckEventKafkaExperimTopology**. The main function of the class defines the topology and submits it to Nimbus. The storm jar part takes care of connecting to Nimbus and uploading the jar.

Open your Ambari Dashboard. Click the **Storm View** located in the Ambari User Views list.

![storm_view_iot](assets/lab2-hbase-hive-storm/storm_view_iot.png)

You should see the new Topology **truck-event-processor**.

![storm_view_topology_listing](assets/lab2-hbase-hive-storm/storm_view_topology_listing_iot.png)

Run the NiFi DataFlow to generate events.
Return to the Storm View and click on **truck-event-processor** topology in the list of topologies to drill into it.

As you scroll down the page, let's analyze a Visualization of our truck-event-processor topology:

![storm_topology_new_stormAPI_iot](assets/lab2-hbase-hive-storm/storm_topology_new_stormAPI_iot.png)

### 2.2 Analysis of Topology Visualization:
- RouteBolt processes the data received by KafkaSpout

- CountBolt takes the data from RoutBolt and counts the incidents per driver
- 1 HBaseBolt performs complex transformations on the data received by CountBolt
to write to **Incidents Per Driver** Table

- 2 HBase Bolts perform complex transformations on the data from RouteBolt to
write to **All Events** and **Dangerous Event** Tables.

### 2.3 Overview of the Storm View
After 6-10 minutes, you should see that numbers of emitted and transferred tuples for each node(Spout or Bolt) in the topology is increasing, which shows that the messages are processed in real time by Spout and Bolts. If we hover over one of the spouts or bolts, we can see how much data they process and their latency.

Here is an example of the data that goes through the kafkaSpout and RouteBolt in the topology:

![analysis_of_dive_into_storm_view](assets/lab2-hbase-hive-storm/analysis_of_dive_into_storm_view.png)

**Overview of truck-event-processor in Storm View**
- Topology Summary
- Topology Stats
- truck-event-processor Visualization
- Spout
- Bolts
- Topology Configuration

### 2.4 Overview of Spout Statistics:

To see statistics of a particular component or node in the storm topology, click on that component located in the Spouts or Bolts section. For instance, let's dive into the KafkaSpout's statistics.

**Overview of Spout Statistics**

- Component Summary
- Spout Stats
- Output Stats ( All time )
- Executor Stats ( All time )
- Error Stats ( All time )

![spout_statistics_iot](assets/lab2-hbase-hive-storm/spout_statistics_iot.png)

### 2.5 Overview of Bolt Statistics:

Follow similar process in section 2.4 to see the statistics of a particular bolt in your topology. Let's dive into the RouteBolt statistics.

**Overview of Bolt Statistics**
- Component Summary
- Bolt Stats
- Input Stats ( All time )
- Output Stats ( All time )
- Executor Stats ( All time )
- Error Stats ( All time )

![bolt_statistics_iot](assets/lab2-hbase-hive-storm/bolt_statistics_iot.png)

What differences do you notice about the spout statistics compared to the bolt statistics?

## Step 3: Verify Data in HBase <a id="step4-verify-data-hdfs-hbase-lab3"></a>

Let’s verify that Storm's 3 HBase bolts successfully sent data to the 3 HBase Tables.

-   If you haven't done so, you can you can stop the NiFi DataFlow. Press the stop symbol.
-   Verify that the data is in HBase by executing the following commands in HBase shell:

~~~
hbase shell

list
count 'driver_events'
count 'driver_dangerous_events'
count 'driver_dangerous_events_count'
exit
~~~

The `driver_dangerous_events` table is updated upon every violation event.

![verify_data_in_hbase_iot](assets/lab2-hbase-hive-storm/hbase_dangerous_events_data.png)

### 3.1 Troubleshoot Unexpected Data in HBase Table

If the data in the HBase table is displayed in hexadecimal values, you can perform the following special operation on a table to display the data in the correct format. For instance, if your **driver_dangerous_events** had unexpected data, run the following hbase query:

~~~
scan 'driver_dangerous_events_count' , {COLUMNS => ['counters:driverId:toInt', 'counters:incidentTotalCount:toLong']}
~~~

Your data should look as follows:

![hbase_dangerous_correct_format](assets/lab2-hbase-hive-storm/hbase_dangerous_correct_format.png)

-   Once done, stop the Storm topology

Open the terminal of your sandbox:, then we can deactivate/kill the Storm topology from the Storm View or shell.

~~~bash
storm kill TruckEventKafkaExperimTopology
~~~

![storm_topology_actions_iot](assets/lab2-hbase-hive-storm/storm_topology_actions_iot.png)


## Summary

Congratulations, you built your first Hortonworks DataFlow Application.
When NiFi, Kafka and Storm are combined, they create the Hortonworks DataFlow.
You have used the power of NiFi to ingest, route and land real-time streaming
data. You learned to capture that data with Kafka and perform instant processing
with Storm. A common challenge with many use cases, which is also observed in
this tutorial series is ingesting a live stream of random data, and filtering
the junk data from the actual data we care about. Through these tutorials, you
learned to manipulate, persist and perform many other operations on random data.
We have a working application that shows us a visualization of driver behavior,
normal and dangerous events per city. Can you brainstorm ways to further enhance
this application?

<!--Run Trucking Demo Section

### Appendix A: Run the Trucking Demo with NiFi Integration <a id="run-the-trucking-demo-lab3"></a>

The trucking demo shows realtime monitoring of alerts and predictions of driving violations by fleets of trucks. The demo visually illustrates these events on a map. Let's start the demo to observe these realtime events in action.

### A.1 Start the Trucking Demo

1\. Navigate to the base of the trucking demo project folder, make sh files executable, then execute the rundemo.sh script. Starting the demo may take 15 - 20 minutes:

~~~
cd ~/iot-truck-streaming
chmod 750 *.sh
./rundemo.sh clean
~~~

Note: rundemo.sh clean kills the storm topology, stops storm, cleans the storm directories, restarts storm and redeploys the topology. rundemo.sh is modified with the assumption that you completed the Tutorial Series, specifically you manually installed maven back in tutorial 0, Kafka, Storm, HBase services are running and updated the user-env.sh file in tutorial 2. rundemo.sh will setup and start the demo.

When you see **"[INFO] Started Jetty Server"** message up in the console, you will be able to access the demo at:

~~~
http://<hostname>:8081/storm-demo-web-app/index.html.
~~~

If on virtualbox, the hostname will be: http://127.0.0.1:8081/storm-demo-web-app/index.html.

If you receive the message, **"This site can't be reached"**, you will need to port forward `8081` onto your virtual machine. Refer to [tutorial] 0 step 3](#step3-start-nifi) where we port forward NiFi port number if you need to review.

### A.2 Login to Trucking Demo Dashboard

Once connected to Jetty Server, the following login page appears, user and password are given by default, so press the **sign in** button:

![trucking_demo_sign_in](assets/lab2-hbase-hive-storm/trucking_demo_sign_in.png)

The HDP Storm Demo Dashboard will appear:

![hdp_storm_demo_dashboard_iot](assets/lab2-hbase-hive-storm/hdp_storm_demo_dashboard_iot.png)

### A.3 Run NiFi DataFlow & Topology Tuples Increase

Before entering one of these applications on the dashboard as in the image above, make sure your NiFi DataFlow is running and that your storm topology spout/bolt tuples are increasing. You should have images similar to as below:

![dataflow_withKafka_running_iot](assets/lab1-kafka/dataflow_withKafka_running_iot.png)

> DataFlow is running and sending events to Kafka. If you notice events stop being sent to kafka, stop and start the DataFlow.

![storm_topology_tuples_increasing](assets/lab2-hbase-hive-storm/storm_topology_tuples_increasing.png)

> Storm Topology Spout/Bolt tuples increasing

### A.4 Troubleshooting Section

If storm shows an internal server error, refer to the **troubleshooting section below**, else skip to the next section:

If in the Storm UI and it shows that storm nimbus is not coming up, or you are getting an error similar to:
`java.lang.RuntimeException: Could not find leader nimbus from seed hosts [sandbox.hortonworks.com]. Did you specify a valid list of nimbus hosts for config nimbus.seeds`

Stop Storm and run the following commands to clean out the old data.

~~~
./iot-truck-streaming/setup/bin/cleanupstormdirs.sh
/usr/hdp/current/zookeeper-client/bin/zkCli.sh
rmr /storm
~~~

If any other issues, reset and restart the demo:

~~~
./iot-truck-streaming/setup/bin/cleanup.sh
~~~

Now let's start the Storm service. We'll need to redeploy our topology:

~~~
[root@sandbox ~]# cd iot-truck-streaming/
[root@sandbox iot-truck-streaming]# storm jar storm-streaming/target/storm-streaming-1.0-SNAPSHOT.jar com.hortonworks.streaming.impl.topologies.TruckEventKafkaExperimTopology /etc/storm_demo/config.properties
~~~

We also need to run our NiFi DataFlow. Now we can we can explore the different applications within the demo.

### A.5 Explore Trucking Demo Applications

If you can see your NiFi DataFlow sending truck event data to Kafka and Storm tuples increasing, enter the applications and you shall the see the following maps and tables:


Real-Time Driver Monitoring Application

![driver_monitoring_app_map](assets/lab2-hbase-hive-storm/driver_monitoring_app_map.png)
![driver_monitoring_app_table](assets/lab2-hbase-hive-storm/driver_monitoring_app_table.png)


Real-Time Driver Behavior Predictions Application

![driver_behavior_predictions_app_map](assets/lab2-hbase-hive-storm/driver_behavior_predictions_app_map.png)
![driver_behavior_predictions_app_table](assets/lab2-hbase-hive-storm/driver_behavior_predictions_app_table.png)


Real-Time Drools Driven Monitoring Application

![drools_driven_driver_alerts_app_map](assets/lab2-hbase-hive-storm/drools_driven_driver_alerts_app_map.png)
![drools_driven_driver_alerts_app_table](assets/lab2-hbase-hive-storm/drools_driven_driver_alerts_app_table.png)

Congratulations, you just incorporated NiFi into the trucking demo. Notice that each time the rows in the table turn red, it indicates a prediction that the driver committed a violation while driving. On the map, the green dots indicate probability that the driver will not commit a violation while red dots indicate the opposite.
-->

## Further Reading <a id="further-reading-lab3"></a>
- [Apache HBase](https://hortonworks.com/hadoop/hbase/)
- [Getting Started with HBase](https://hbase.apache.org/book.html#quickstart)
- [Storm Hive Integration](https://storm.apache.org/releases/1.0.1/storm-hive.html)
- [Storm Tutorials](https://hortonworks.com/hadoop/storm/#tutorials)
- [Getting Started with Apache Storm](http://storm.apache.org/releases/1.0.1/index.html)
- [Apache Storm](https://hortonworks.com/hadoop/storm/)
