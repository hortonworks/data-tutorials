---
title: Using Hive with ORC in Apache Spark REPL
author: Robert Hryniewicz
tutorial-id: 400
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Predictive
technology: Apache Hive, Apache Spark, Apache ORC
release: hdp-2.6.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Using Hive with ORC in Apache Spark REPL

## Introduction

In this tutorial, we will explore how you can access and analyze data on Hive from Spark. In particular, you will learn:

-   How to interact with Apache Spark through an interactive Spark shell
-   How to read a text file from HDFS and create a RDD
-   How to interactively analyze a data set through a rich set of Spark API operations
-   How to create a Hive table in ORC File format
-   How to query a Hive table using Spark SQL
-   How to persist data in ORC file format

Spark SQL uses the Spark engine to execute SQL queries either on data sets persisted in HDFS or on existing RDDs. It allows you to manipulate data with SQL statements within a Spark program.

## Prerequisites

This tutorial is a part of series of hands-on tutorials to get you started with HDP using Hortonworks sandbox. Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Download and Install [Hortonworks Sandbox](https://hortonworks.com/products/sandbox/)
-   Review [Learning the Ropes of the Hortonworks Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

This tutorial will be using Spark 1.6.x. API syntax for all the examples.

## Outline

-   [Getting the dataset](#getting-the-dataset)
-   [Starting the Spark shell](#starting-the-spark-shell)
-   [Creating HiveContext](#creating-hivecontext)
-   [Creating ORC tables](#creating-orc-tables)
-   [Loading the file and creating a RDD](#loading-the-file-and-creating-a-rdd)
-   [Creating a schema](#creating-a-schema)
-   [Registering a temporary table](#registering-a-temporary-table)
-   [Saving as an ORC file](#saving-as-an-orc-file)

-   [Summary](#summary)

## Getting the dataset

To begin, login to Hortonworks Sandbox through SSH:

The default password is `hadoop`.

Now let’s download the dataset with the command below:

~~~ bash
wget http://hortonassets.s3.amazonaws.com/tutorial/data/yahoo_stocks.csv
~~~

and copy the downloaded file to HDFS:

~~~ bash
hdfs dfs -put ./yahoo_stocks.csv /tmp/
~~~

## Starting the Spark shell

Use the command below to launch the Scala REPL for Apache Spark:

~~~ bash
spark-shell
~~~

Notice it is already starting with Hive integration as we have preconfigured it on the Hortonworks Sandbox.

Before we get started with the actual analytics let's import some of the libraries we are going to use below.

~~~ java
import org.apache.spark.sql.hive.orc._
import org.apache.spark.sql._
~~~

## Creating HiveContext

HiveContext is an instance of the Spark SQL execution engine that integrates with data stored in Hive. The more basic SQLContext provides a subset of the Spark SQL support that does not depend on Hive. It reads the configuration for Hive from hive-site.xml on the classpath.

~~~ java
val hiveContext = new org.apache.spark.sql.hive.HiveContext(sc)
~~~

## Creating ORC tables

ORC is a self-describing type-aware columnar file format designed for Hadoop workloads. It is optimized for large streaming reads and with integrated support for finding required rows fast. Storing data in a columnar format lets the reader read, decompress, and process only the values required for the current query. Because ORC files are type aware, the writer chooses the most appropriate encoding for the type and builds an internal index as the file is persisted.

Predicate pushdown uses those indexes to determine which stripes in a file need to be read for a particular query and the row indexes can narrow the search to a particular set of 10,000 rows. ORC supports the complete set of types in Hive, including the complex types: structs, lists, maps, and unions.

Specifying `as orc` at the end of the SQL statement below ensures that the Hive table is stored in the ORC format.

~~~ java
hiveContext.sql("create table yahoo_orc_table (date STRING, open_price FLOAT, high_price FLOAT, low_price FLOAT, close_price FLOAT, volume INT, adj_price FLOAT) stored as orc")
~~~

## Loading the file and creating a RDD

A **Resilient Distributed Dataset** (RDD), is an immutable collection of objects that is partitioned and distributed across multiple physical nodes of a YARN cluster and that can be operated in parallel.

Once an RDD is instantiated, you can apply a [series of operations](https://spark.apache.org/docs/1.2.0/programming-guide.html#rdd-operations). All operations fall into one of two types: [transformations](https://spark.apache.org/docs/1.2.0/programming-guide.html#transformations) or [actions](https://spark.apache.org/docs/1.2.0/programming-guide.html#actions). **Transformation** operations, as the name suggests, create new datasets from an existing RDD and build out the processing DAG that can then be applied on the partitioned dataset across the YARN cluster. An **Action** operation, on the other hand, executes DAG and returns a value.

Normally, we would have directly loaded the data in the ORC table we created above and then created an RDD from the same, but in this to cover a little more surface of Spark we will create an RDD directly from the CSV file on HDFS and then apply Schema on the RDD and write it back to the ORC table.

With the command below we instantiate an RDD:

~~~ java
val yahoo_stocks = sc.textFile("/tmp/yahoo_stocks.csv")
~~~

To preview data in `yahoo_stocks` type:

~~~ java
yahoo_stocks.take(10)
~~~

Note that `take(10)` returns only ten records that are not in any particular order.

### Separating the header from the data

Let’s assign the first row of the RDD above to a new variable

~~~ java
val header = yahoo_stocks.first
~~~

Let’s dump this new RDD in the console to see what we have here:

~~~ java
header
~~~

Now we need to separate the data into a new RDD where we do not have the header above and :

~~~ java
val data = yahoo_stocks.mapPartitionsWithIndex { (idx, iter) => if (idx == 0) iter.drop(1) else iter }
~~~

the first row to be seen is indeed only the data in the RDD

~~~ java
data.first
~~~

## Creating a schema

There’s two ways of doing this.

~~~ java
case class YahooStockPrice(date: String, open: Float, high: Float, low: Float, close: Float, volume: Integer, adjClose: Float)
~~~

### Attaching the schema to the parsed data

Create an RDD of Yahoo Stock Price objects and register it as a table.

~~~ java
val stockprice = data.map(_.split(",")).map(row => YahooStockPrice(row(0), row(1).trim.toFloat, row(2).trim.toFloat, row(3).trim.toFloat, row(4).trim.toFloat, row(5).trim.toInt, row(6).trim.toFloat)).toDF()
~~~

Let’s verify that the data has been correctly parsed by the statement above by dumping the first row of the RDD containing the parsed data:

~~~ java
stockprice.first
~~~

if we want to dump more all the rows, we can use

~~~ java
stockprice.show
~~~

To verify the schema, let’s dump the schema:

~~~ java
stockprice.printSchema
~~~

## Registering a temporary table

Now let’s give this RDD a name, so that we can use it in Spark SQL statements:

~~~ java
stockprice.registerTempTable("yahoo_stocks_temp")
~~~

### Querying against the table

Now that our schema’s RDD with data has a name, we can use Spark SQL commands to query it. Remember the table below is not a Hive table, it is just a RDD we are querying with SQL.

~~~ java
val results = spark.sqlContext.sql("SELECT * FROM yahoo_stocks_temp")
~~~

The resultset returned from the Spark SQL query is now loaded in the `results` RDD. Let’s pretty print it out on the command line.

~~~ java
results.map(t => "Stock Entry: " + t.toString).collect().foreach(println)
~~~

## Saving as an ORC file

Now let’s persist back the RDD into the Hive ORC table we created before.

~~~ java
results.write.format("orc").save("yahoo_stocks_orc")
~~~

To store results in a hive directory rather than user directory, use this path instead:

~~~ bash
results.write.format("orc").save("/apps/hive/warehouse/yahoo_stocks_orc")
~~~

### Reading the ORC file

Let’s now try to read back the ORC file, we just created back into an RDD. But before we do so, we need a `hiveContext`:

~~~ java
val hiveContext = new org.apache.spark.sql.hive.HiveContext(sc)
~~~

now we can try to read the ORC file with:

~~~ java
val yahoo_stocks_orc = hiveContext.read.format("orc").load("yahoo_stocks_orc")
~~~

Let’s register it as a temporary in-memory table mapped to the ORC table:

~~~ java
yahoo_stocks_orc.registerTempTable("orcTest")
~~~

Now we can verify whether we can query it back:

~~~ java
hiveContext.sql("SELECT * from orcTest").collect.foreach(println)
~~~

## Summary

Voila! We just did a round trip of using Spark shell, reading data from HDFS, creating an Hive table in ORC format, querying the Hive Table, and persisting data using Spark SQL.

Hope this tutorial illustrated some of the ways you can integrate Hive and Spark.
