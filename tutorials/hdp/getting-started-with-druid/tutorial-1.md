---
title: Druid Concepts
---

# Druid Concepts

## Introduction

In this tutorial, you will learn about the history and motivation on why Druid
was developed. You will become familiar with what Druid is, Druid's architecture,
data storage format, indexing data and querying data.

## Outline

- [History](#history)
- [What is Druid?](#what-is-druid)
- [Architecture](#architecture)
- [Data Storage Format](#data-storage-format)
- [Indexing Data](#indexing-data)
- [Querying Data](#querying-data)
- [Druid in Production](#druid-in-production)
- [What are Suitable Use Cases?](#what-are-suitable-use-cases)
- [Further Reading](#further-reading)

## History

Development of Druid started in 2011 in Metamarkets and was open sourced
in 2012. The initial use case was to power an ad-tech analytics product to
create a dashboard over their data streams. The requirements for the dashboard
were that the user should be able to query any possible combination of metrics
and dimensions. This dashboard should be interactive rather than slow. Since
there are trillions of events generated each day, this dashboard should be
scalable. It should also give the user the ability to see the recent data as
it is happening on the dashboard, so data freshness must be met. The other
requirement Druid was created to support was streaming ingestion and low
latency queries.

## What is Druid?

Druid is a **column-oriented distributed datastore**. Druid stores its data in a
columnar format. The data rules could have 100s or thousands of values. They
could also have 100s or thousands of columns. In OLAP queries what you
query is a subset of those dimensions 5 or 20, etc. Being a column oriented
store, it enables Druid to scan the columns necessary to answer the query.
Druid supports **sub-second query times** because it is going to power an interactive
dashboard. It utilizes various techniques, such as bit map indexes, dictionary
encoding, data compression, query caching in order to provide sub second query
times. Druid supports **realtime streaming ingestion** from almost any ETL pipeline.
You can have pull based as well as push based ingestion. Druid supports
**automatic data summarization** where it can pre-aggregate your data at the time
of ingestion. Druid supports **approximate histograms** where we need to do fast
approximate distinct counts. Druid is **scalable to petabytes of data** and
**highly available**.

## Architecture

In Druid, there are multiple nodes.

### MiddleManager/Indexing Nodes

These nodes are responsible for running index tasks. You could submit index
tasks and those tasks will be run on one of the slots on those middlemanager
nodes.

### Historical Nodes

These nodes load your historical data, which is immutable and serve queries on
top of that.

### Broker Nodes

These nodes break your query and keep track of where in your cluster the data is
present across different historical or middlemanager nodes. Thus, these nodes
know about the location of your data. You send your query to the broker
nodes, they distribute your query across different historical or middlemanager
nodes, they get the results and give you back the results.

### Coordinator Nodes

These nodes help in coordination of your data across the different cluster.

### Visual Diagram

![visual-diagram.jpg](assets/images/visual-diagram.jpg)

Let's examine the flow of data when a streaming event takes place:

1\. Typically you have streaming data coming in from any source. You can use
any data pipeline tool to massage, transform and enrich the data.

2\. Once the processing is done, you send the data to your realtime indexing
task. The task will keep the data in a row oriented fashion in memory and if
there is any query that comes, you can serve that query from the realtime nodes.

3\. The query will first hit the broker node, the broker node will see that it has
some data in the realtime index task and the broker node will send that query
to the realtime index task. In response, the indexing task will send back the
result to the broker node and the event will be visible on the dashboard.

4\. If the data has been sitting in the indexing tasks for a while, the indexing
tasks will create a column oriented format, which is known as a Druid segment.
Segments will be handed off to deep storage.

> Note: Deep storage could be any distributed file system, which is used as a
permanent backup of your data segments.

5\. Once the data is present in deep storage, it is then loaded onto the historical
nodes. After the data is loaded onto the historical nodes, the indexing tasks
will see the segments have been loaded onto the historical nodes, so the
indexing tasks drops the segments from its memory.

> Note: Thus, if a query comes, it will be served from the historical nodes.

6\. Druid leverages Coordinator nodes to manage where the segments needs to be loaded.
They are responsible for coordinating your data across different
historical nodes. Coordinator nodes are also responsible for handling data
replication. You can have configurable rules for loading your data. For
instance, I could set a rule that makes sure only 1 month old data is loaded on
the historical nodes with the Coordinator nodes.

7\. Zookeeper is used for doing internal communication and leader elections and
fail overs.

10\. There is an external dependency on a metadata store. It can be MySQL or
Postgres datastore. It stores metadata about Druid segments, such as how to load
those segments, where is the location of the files present for those segments.

## Data Storage Format

In Druid, data is stored in the form of segment files. These files are
partitioned by time. Every segment has a start and end time, denoting forward
time range that I have data in this time range. Ideally segments should be
smaller than 1GB, so on the historical nodes, we scan each segment in a single
thread and if you have very large segments, it will hit your query performance.
If you have large amounts of data for a particular timed window, you can create
multiple shards.

![druid-segments-diagrams.jpg](assets/images/druid-segments-diagrams.jpg)

For instance, I could have data for 1 week with different segments for
particular days in that week. Since there are two segments for Friday, there
are two shards.

### Dataset Example

We will look at how the different columns look like in Druid. Druid is an event
store and it is mandatory to have timestamp in your
data.

~~~json
{
    "time":"2015-09-12T00:47:05.474Z",
    "channel":"#en.wikipedia",
    "cityName":"Auburn",
    "comment":"/* Status of peremptory norms under international law */ fixed spelling of 'Wimbledon'",
    "countryIsoCode":"AU",
    "countryName":"Australia",
    "isAnonymous":true,
    "isMinor":false,
    "isNew":false,
    "isRobot":false,
    "isUnpatrolled":false,
    "metroCode":null,
    "namespace":"Main",
    "page":"Peremptory norm",
    "regionIsoCode":"NSW",
    "regionName":"New South Wales",
    "user":"60.225.66.142",
    "delta":0,
    "added":0,
    "deleted":0
}
~~~

### Timestamp

Timestamp is the date and time when the above edit was made on wikipedia.

~~~json
{
  "time":"2015-09-12T00:47:05.474Z"
  ...
}
~~~

### Dimensions

Dimensions is the information on that edit, such as who made that edit, from
which location that edit was made.

~~~json
{
  "channel":"#en.wikipedia",
  "cityName":"Auburn",
  "comment":"/* Status of peremptory norms under international law */ fixed spelling of 'Wimbledon'",
  "countryIsoCode":"AU",
  "countryName":"Australia",
  "isAnonymous":true,
  "isMinor":false,
  "isNew":false,
  "isRobot":false,
  "isUnpatrolled":false,
  "metroCode":null,
  "namespace":"Main",
  "page":"Peremptory norm",
  "regionIsoCode":"NSW",
  "regionName":"New South Wales",
  "user":"60.225.66.142",
  ...
}
~~~

### Metrics

Metrics is the information on measurement, such as how many characters were
added and how many were deleted, etc.

~~~json
{
  "delta":0,
  "added":0,
  "deleted":0
  ...
}
~~~

## Indexing Data

Indexing data in Druid can be done in two ways: realtime ingestion and batch
ingestion.

### Realtime Index Tasks

Realtime index tasks have the ability to ingest streaming data. These tasks
store the data in row format, auto converts the data into Druid segments and
hands it over to the Historical nodes. The event is queryable once it reaches
the realtime index task. These tasks support pull based and push based
ingestion (firehose).

### Streaming Ingestion: Tranquility API

Druid has a friend library called Tranquility, which provides APIs to ingest
events into Druid. The following code is an example of how to use the Tranquility
API in Java to send events to Druid:

~~~java
public static void main(String[] args) {
  // Reads config from "example.json" on classpath
  final InputStream configStream = JavaExample.class.getClassLoader()
          .getResourceAsStream("example.json");
  final TranquilityConfig<PropertiesBasedConfig> config = TranquilityConfig.read(configStream);
  final DataSourceConfig<PropertiesBasedConfig> wikipediaConfig = config
          .getDataSource("wikipedia");

  // Create a sender
  final Tranquilizer<Map<String, Object>> sender = DruidBeams.fromConfig(wikipediaConfig)
          .buildTranquilizer(wikipediaConfig.tranquilizerBuilder());
  sender.start();
  try {
    // Build a sample event to send; make sure we use a current date
    final Map<String, Object> obj = ImmutableMap.<~>of(
            "timestamp", new DateTime().toString(),
            "page", "foo",
            "added", 1
    );

    // Asynchronously send event to Druid
    sender.send(obj);
  } finally {
    sender.flush()
    sender.stop();
  }
}
~~~

Tranquility API provides you with a tranquilizer, so you can start it, send
events and stop it. Tranquility API can be used with any of the data pipeline
frameworks, such as NiFi, Spark Streaming, Kafka, Stream Analytics Manager, etc.
Tranquility supports at least one ingestion.

### Batch Ingestion

### Hadoop Batch Ingestion Task

Hadoop batch ingestion task internally launches a MapReduce job. Mappers read
the data and Reducers create Druid segment files. The data is query-able after
the MapReduce job finishes.

### Index Task

Runs in a single JVM and ideally suited for small data sizes.

### Querying Data

Druid supports sending JSON queries to HTTP and receiving results in JSON form.
It also has built in SQL powered by Apache Calcite, various querying
libraries (Python, R, Ruby, Javascript, etc) and multiple UI tools. Later in
the tutorial, we will dive into how to send JSON queries over HTTP to Druid.

## Druid in Production

Ebay uses Druid for their user behavior analytics. Cisco has a product for
analyzing network flows. Yahoo uses Druid for user behavior analytics and
realtime cluster monitoring. There are many more companies using Druid to
perform data analytics.

## What are Suitable Use Cases?

Druid is suitable for powering interactive user facing applications,
arbitrary slicing and dicing large datasets, user behavior analysis and
exploratory analytics/root cause analysis.

## Further Reading

- [An Introduction to Druid: Video](https://www.youtube.com/watch?v=JEhmHsN8jZI)
- [An Introduction to Druid: Slides](https://www.slideshare.net/Hadoop_Summit/an-introduction-to-druid-95294863)
- [Introduction to Druid by Fangjin Yang: Video](https://www.youtube.com/watch?v=GtHu4TVs0xI)
