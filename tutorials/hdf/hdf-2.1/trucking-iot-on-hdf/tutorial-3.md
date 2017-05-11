---
title: Trucking IoT on HDF
tutorial-id: 805
platform: hdf-2.1.0
tags: [storm, trucking, iot, kafka]
---

# Building a Storm Topology

## Introduction

We now know the role that Storm plays in this Trucking IoT system.  Let's dive into the code and dissect what the code is doing and also learn how to build this topology.


## Outline

-   [Storm Components](#storm-components)
-   [Environment Setup](#environment-setup)
-   [Topology Build and Submit Overview](#topology-build-and-submit-overview)
-   [Starting to Build a Storm Topology](#starting-to-build-a-storm-topology)
-   [Building a Kafka Spout](#building-a-kafka-spout)
-   [Building a Custom Bolt](#building-a-custom-bolt)
-   [Building a Tumbling Windowed Bolt](#building-a-tumbling-windowed-bolt)
-   [Building a Sliding Windowed Bolt](#building-a-sliding-windowed-bolt)
-   [Building a Kafka Bolt](#building-a-kafka-bolt)
-   [Creating the Topology](#creating-the-topology)
-   [Next: Deploying the Storm topology](#next:-deploying-the-storm-topology)


## Storm Components

Now that we have a general idea of the power of Storm, let's look at its different components, our building blocks when defining a Storm process, and what they're used for.

-   **Tuple**: A list of values.  The main data structure in Storm.
-   **Stream**: An unbounded sequence of tuples.
-   **Spout**: A source of streams.  Spouts will read tuples in from an external source and emit them into streams for the rest of the system to process.
-   **Bolt**: Processes the tuples from an input stream and produces an output stream of results.  This process is also called stream transformation.  Bolts can do filtering, run custom functions, aggregations, joins, database operations, and much more.
-   **Topology**: A network of spouts and bolts that are connected together by streams.  In other words, the overall process for Storm to perform.

![A Storm topology: spouts, streams and bolts](assets/storm-100_topology.png)


##  Environment Setup

We will be working with the `trucking-iot-demo-1` project that you downloaded in previous sections.  Feel free to download the project again on your local environment so you can open it with your favorite text editor or IDE.

```
git clone https://github.com/orendain/trucking-iot-demo-1
```

> Alternatively, if you would prefer not to download the code, and simply follow along, you may view this project directly on [GitHub](https://github.com/orendain/trucking-iot-demo-2/tree/master/trucking-storm-topology/src/main/scala/com/orendainx/hortonworks/trucking/storm).


## Topology Build and Submit Overview

Look inside the `KafkaToKafka.scala` class and you'll find a companion object with our standard entry point, `main`, and a `KafkaToKafka` class with a method named `buildTopology` which handles the building of our Storm topology.

The primary purpose of our `main` method is to configure and build our topology and then submit it for deployment onto our cluster.  Let's take a closer look at what's inside:

```
// Set up configuration for the Storm Topology
val stormConfig = new Config()
stormConfig.setDebug(config.getBoolean(Config.TOPOLOGY_DEBUG))
stormConfig.setMessageTimeoutSecs(config.getInt(Config.TOPOLOGY_MESSAGE_TIMEOUT_SECS))
stormConfig.setNumWorkers(config.getInt(Config.TOPOLOGY_WORKERS))
```

The `org.apache.storm.Config` class provides a convenient way to create a topology config by providing setter methods for all the configs that can be set.  It also makes it easier to do things like add serializations.

Following the creation of a Config instance, our `main` method continues with:
```
// Build and submit the Storm config and topology
val topology = new KafkaToKafka(config).buildTopology()
StormSubmitter.submitTopologyWithProgressBar("KafkaToKafka", stormConfig, topology)
```

Here, we invoke the `buildTopology` method of our class, which is responsible for building a StormTopology.  With the topology that is returned, we use the `StormSubmitter` class to submit topologies to run on the Storm cluster.


## Starting to Build a Storm Topology

Let's dive into the `buildTopology` method to see exactly how to build a topology from the ground up.

```
// Builder to perform the construction of the topology.
implicit val builder = new TopologyBuilder()

// Configurations used for Kafka components
val zkHosts = new ZkHosts(config.getString(Config.STORM_ZOOKEEPER_SERVERS))
val zkRoot = config.getString(Config.STORM_ZOOKEEPER_ROOT)
val groupId = config.getString("kafka.group-id")
```

We start by creating an instance of `TopologyBuilder`, which exposes an easy-to-use Java API for putting together a topology.  Next, we pull in some values from our configuration file (`application.conf`).


## Building a Kafka Spout

```
/*
 * Build a Kafka spout for ingesting enriched truck data
 */

// Name of the Kafka topic to connect to
val truckTopic = config.getString("kafka.truck-data.topic")

// Create a Spout configuration object and apply the scheme for the data that will come through this spout
val truckSpoutConfig = new SpoutConfig(zkHosts, truckTopic, zkRoot, groupId)
truckSpoutConfig.scheme = new SchemeAsMultiScheme(new BufferToStringScheme("EnrichedTruckData"))

// Force the spout to ignore where it left off during previous runs (for demo purposes)
truckSpoutConfig.ignoreZkOffsets = true
```

In order to build a `KafkaSpout`, we first need to decide what Kafka topic will be read from, where it exists, and exactly how we want to ingest that data in our topology.  This is where a `SpoutConfig` comes in handy.

This `SpoutConfig` method takes in a list of Kafka ZooKeeper servers as a string ("sandbox-hdf.hortonworks.com:6667" in our case), the name of the Kafka topic to subscribe to, the ZooKeeper root and a group id (the id of the kafka consumer group property).

> Note: This tutorial demonstrates using Storm 1.0.2.  As of Storm 1.1.0, however, there are additions that make defining components even easier with even less boilerplate.

Our `BufferToStringScheme` class defines how the spout converts a data from a Kafka topic into a Storm Tuple.  To look at the innerworkings of this class, check out `BufferToStringScheme.scala`.  This class produces a Tuple where the first field is the type of the data, "EnrichedTruckData", and the second is the record itself (a CSV string record).

Now that we have a SpoutConfig, we use it to build a KafkaSpout and place it in the topology.

```
// Create a spout with the specified configuration, and place it in the topology blueprint
builder.setSpout("enrichedTruckData", new KafkaSpout(truckSpoutConfig), 1)
```

Remember that `builder` refers to the `TopologyBuilder`.  We're creating a new `KafkaSpout` with a parallelism_hint of `1` (how many tasks, or instances, of the component to run on the cluster).  We place the spout in the topology blueprint with the name "enrichedTruckData".


## Building a Custom Bolt

Excellent, we now have a way to ingest our CSV-delimited strings from Kafka topics and into our Storm topology.  We now need a way to unpackage these strings into Java objects so we can more easily interact with them.

Let's go ahead and build a custom Storm Bolt for this purpose.  We'll call it CSVStringToObjectBolt.  But first, let's see how this new custom bolt will fit into our topology blueprint.

```
builder.setBolt("unpackagedData", new CSVStringToObjectBolt(), 1)
  .shuffleGrouping("enrichedTruckData")
  .shuffleGrouping("trafficData")
```

We create a new CSVStringToObjectBolt bolt, and tell spot to assign only a single task for this bolt (i.e. create only 1 instance of this bolt in the cluster).  We name it "unpackagedData".

`ShuffleGrouping` shuffles data flowing in from the specified spouts evenly across all instances of the newly created bolt.

Let's dig in and see how we create this bolt from scratch: check out the `CSVStringToObjectBolt.java` file.

```
class CSVStringToObjectBolt extends BaseRichBolt {
```

Rather than creating a Storm bolt __entirely__ from scratch, we leverage one of Storm's base classes and simply extend `BaseRichBolt`.  BaseRichBolt takes care of a lot of the lower-level implementation for us.

```
private var outputCollector: OutputCollector = _

override def prepare(stormConf: util.Map[_, _], context: TopologyContext, collector: OutputCollector): Unit = {
  outputCollector = collector
}
```

The prepare method provides the bolt with an OutputCollector that is used for emitting tuples from this bolt. Tuples can be emitted at anytime from the bolt -- in the prepare, execute, or cleanup methods, or even asynchronously in another thread. This prepare implementation simply saves the OutputCollector as an instance variable to be used later on in the execute method.

```
override def execute(tuple: Tuple): Unit = {
  // Convert each string into its proper case class instance (e.g. EnrichedTruckData or TrafficData)
  val (dataType, data) = tuple.getStringByField("dataType") match {
    case typ @ "EnrichedTruckData" => (typ, EnrichedTruckData.fromCSV(tuple.getStringByField("data")))
    case typ @ "TrafficData" => (typ, TrafficData.fromCSV(tuple.getStringByField("data")))
  }

  outputCollector.emit(new Values(dataType, data))
  outputCollector.ack(tuple)
}
```

The `execute` method receives a tuple from one of the bolt's inputs.  For each tuple that this bolt processes, the `execute` method is called.

We start by extracting the value of the tuple stored under the name "dataType", which we know is either "EnrichedTruckData" or "TrafficData".  Depending on which it is, we call the `fromCSV` method of the appropriate object, which returns a JVM object based on this CSV string.

Next, we use the `outputCollector` to emit a Tuple onto this bolt's outbound stream.
Finally, we `ack` (acknowledge) that the bolt has processed this tuple.  This is part of Storm's reliability API for guaranteeing no data loss.

The last method in this bolt is a short one:
```
override def declareOutputFields(declarer: OutputFieldsDeclarer): Unit = declarer.declare(new Fields("dataType", "data"))
```

The declareOutputFields method declares that this bolt emits 2-tuples with fields called "dataType" and "data".

That's it!  We've just seen how to build a custom Storm bolt from scratch.


## Building a Tumbling Windowed Bolt

Let's get back to our KafkaToKafka class and look at what other components we're adding downstream of the CSVStringToObjectBolt.

So now, we have KafkaSpouts ingesting in CSV strings from Kafaka topics and a bolt that creating Java objects from these CSV strings.  The next step in our process is to join these two types of Java objects into one.

```
/*
 * Build a windowed bolt for joining two types of Tuples into one
 */

int windowDuration = config.getInt(Config.TOPOLOGY_BOLTS_WINDOW_LENGTH_DURATION_MS);

BaseWindowedBolt joinBolt = new TruckAndTrafficJoinBolt().withTumblingWindow(new BaseWindowedBolt.Duration(windowDuration, MILLISECONDS));

builder.setBolt("joinedData", joinBolt, 1).globalGrouping("unpackagedData");
```

Here, we create a tumbling windowed bolt using our custom TruckAndTrafficJoinBolt, which houses the logic for how to merge the different Tuples.  This bolt processes both `EnrichedTruckData` and `TrafficData` and joins them to emit instances of `EnrichedTruckAndTrafficData`.

A tumbling window with a duration means the stream of incoming Tuples are partitioned based on the time they were processed.  Think of a traffic light, allowing all vehicles to pass but only the ones that get there by the time the light turns red.  All tuples that made it within the window are then processed all at once in the TruckAndTrafficJoinBolt.

We'll take a look at how to build a custom windowed bolt in the next section.


## Building a Sliding Windowed Bolt

Now that we have successfully joined data coming in from two streams, let's perform some windowed analytics on this data.

```
// The size of the window, in number of Tuples.
val intervalCount = config.getInt(Config.TOPOLOGY_BOLTS_SLIDING_INTERVAL_COUNT)

val statsBolt = new DataWindowingBolt().withWindow(new BaseWindowedBolt.Count(intervalCount))
```

Creates a sliding windowed bolt using our custom DataWindowindBolt, which is responsible for reducing a list of recent Tuples(data) for a particular driver into a single datatype.  This data is used for machine learning.

This sliding windowed bolt with a tuple count as a length means we always process the last 'N' tuples in the specified bolt.  The window slides over by one, dropping the oldest, each time a new tuple is processed.

```
builder.setBolt("windowedDriverStats", statsBolt, 1).fieldsGrouping("joinedData", new Fields("driverId"))
```

Build a bolt and then place it in the topology blueprint connected to the "joinedData" stream.

Create 5 tasks for this bolt, to ease the load for any single instance of this bolt.  FieldsGrouping partitions the stream of tuples by the fields specified.  Tuples with the same driverId will always go to the same task.  Tuples with different driverIds may go to different tasks.


## Building a Kafka Bolt

Before we push our Storm-processed data back out to Kafka, we want to serialize the Java objects we've been working with into string form.

```
builder.setBolt("serializedJoinedData", new ObjectToCSVStringBolt()).shuffleGrouping("joinedData")

builder.setBolt("serializedDriverStats", new ObjectToCSVStringBolt()).shuffleGrouping("windowedDriverStats")
```

These bolts, `ObjectToCSVStringBolt` are inverse to our previous custom bolt, `CSVStringToObjectBolt`.  They expect tuples with Java objects and emit a CSV string representation of them.  Check out the source code if you're interested in their inner-workings.

Now, we have two streams emitting string data: "serializedJoinedData" which is the result of the two joined streams, and "serializedDriverStats", which is the result of windowed analytics we performed.

Now, we build KafkaBolts to push data from these streams into Kafka topics.  We start by defining some Kafka properties:

```
// Define properties to pass along to the KafkaBolt
val kafkaBoltProps = new Properties()
kafkaBoltProps.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, config.getString("kafka.bootstrap-servers"))
kafkaBoltProps.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, config.getString("kafka.key-serializer"))
kafkaBoltProps.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, config.getString("kafka.value-serializer"))
```

Next, we build a KafkaBolt:

```
val truckingKafkaBolt = new KafkaBolt()
  .withTopicSelector(new DefaultTopicSelector(config.getString("kafka.joined-data.topic")))
  .withTupleToKafkaMapper(new FieldNameBasedTupleToKafkaMapper("key", "data"))
  .withProducerProperties(kafkaBoltProps)

builder.setBolt("joinedDataToKafka", truckingKafkaBolt, 1).shuffleGrouping("serializedJoinedData")
```

`withTopicSelector` specifies the Kafka topic to drop entries into.

`withTupleToKafkaMapper` is passed an instance of `FieldNameBasedTupleToKafkaMapper`, which tells the bolt which fields of a Tuple the data to pass in is stored as.

`withProducerProperties` takes in properties to set itself up with.


## Creating the Topology

Now that we have specified the entire Storm topology by adding components into our `TopologyBuilder`, we create an actual topology using the builder's blueprint and return it.

```
// Now that the entire topology blueprint has been built, we create an actual topology from it
builder.createTopology()
```


## Next: Deploying the Storm topology

Phew!  We've now learned about how a Storm topology is developed.  In the next section, we'll package this project up into a portable JAR file and run a quick command that will deploy this code onto a cluster.
