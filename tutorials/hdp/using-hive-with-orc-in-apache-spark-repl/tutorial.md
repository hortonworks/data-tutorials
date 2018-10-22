---
title: Using Hive with ORC in Apache Spark REPL
author: sandbox-team
tutorial-id: 400
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Predictive
technology: Apache Hive, Apache Spark, Apache ORC
release: hdp-3.0.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Using Hive with ORC in Apache Spark REPL

## Introduction

In this tutorial, we will explore how you can access and analyze data on Hive from Spark. In particular, you will learn:

- How to interact with Apache Spark through an interactive Spark shell
- How to read a text file from HDFS and create a RDD
- How to interactively analyze a data set through a rich set of Spark API operations
- How to create a Hive table in ORC File format
- How to query a Hive table using Spark SQL
- How to persist data in ORC file format

Spark SQL uses the Spark engine to execute SQL queries either on data sets persisted in HDFS or on existing RDDs. It allows you to manipulate data with SQL statements within a Spark program.

## Prerequisites

This tutorial is a part of series of hands-on tutorials to get you started with HDP using Hortonworks sandbox. Please ensure you complete the prerequisites before proceeding with this tutorial.

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://hortonworks.com/downloads/#sandbox) Sandbox
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

This tutorial will be using Spark 2.x API syntax for all the examples.

## Outline

- [Concepts](#concepts)
- [Environment Setup](#environment-setup)
- [Creating a SparkSession](#creating-a-sparksession)
- [Creating ORC Tables](#creating-orc-tables)
- [Loading the File and Creating a RDD](#loading-the-file-and-creating-a-rdd)
- [Creating a Schema](#creating-a-schema)
- [Registering a Temporary Table](#registering-a-temporary-table)
- [Saving as an ORC File](#saving-as-an-orc-file)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Concepts

### Apache Hive

Apache Hive provides SQL interface to query data stored in various databases and files systems that integrate with Hadoop. Hive enables analysts familiar with SQL to run queries on large volumes of data. Hive has three main functions: data summarization, query and analysis. Hive provides tools that enable easy data extraction, transformation and loading (ETL).

Spark SQL supports reading and writing data stored in Apache Hive. It is important to note that Spark distribution does not include the many dependencies that Hive need. However, if those dependencies can be found on the classpath then Spark can load them automatically.

The more basic SQLContext provides a subset of the Spark SQL support that does not depend on Hive. It reads the configuration for Hive from hive-site.xml on the classpath.

### ORC Tables

ORC is a self-describing type-aware columnar file format designed for Hadoop workloads. It is optimized for large streaming reads and with integrated support for finding required rows fast. Storing data in a columnar format lets the reader read, decompress, and process only the values required for the current query. Because ORC files are type aware, the writer chooses the most appropriate encoding for the type and builds an internal index as the file is persisted.

Predicate push down uses those indexes to determine which stripes in a file need to be read for a particular query and the row indexes can narrow the search to a particular set of 10,000 rows. ORC supports the complete set of types in Hive, including the complex types: structs, lists, maps, and unions.

### Resilient Distributed Dataset

A **Resilient Distributed Dataset** (RDD), is an immutable collection of objects that is partitioned and distributed across multiple physical nodes of a YARN cluster and that can be operated in parallel.

Once an RDD is instantiated, you can apply a [series of operations](https://spark.apache.org/docs/2.3.1/programming-guide.html#rdd-operations). All operations fall into one of two types: [transformations](https://spark.apache.org/docs/2.3.1/programming-guide.html#transformations) or [actions](https://spark.apache.org/docs/2.3.1/programming-guide.html#actions). **Transformation** operations, as the name suggests, create new datasets from an existing RDD and build out the processing DAG that can then be applied on the partitioned dataset across the YARN cluster. An **Action** operation, on the other hand, executes DAG and returns a value.

Normally, we would have directly loaded the data in the ORC table we created above and then created an RDD from the same, but in this to cover a little more surface of Spark we will create an RDD directly from the CSV file on HDFS and then apply Schema on the RDD and write it back to the ORC table.

## Environment Setup

### Download the Dataset

In preparation for this tutorial you need to download two files, people.txt and people.json into your  Sandbox's **tmp** folder. The commands below should be typed into [Shell-in-a-Box](http://sandbox-hdp.hortonworks.com:4200/)

1\. Assuming you start as `root` user:

~~~bash
cd /tmp
~~~

2\. Copy and paste the command to download the yahoo_stocks.csv file:

~~~bash
#Download yahoo_stocks.csv
wget http://hortonassets.s3.amazonaws.com/tutorial/data/yahoo_stocks.csv
~~~

### Upload the dataset to HDFS

3\. Before moving the files into HDFS you need to login under **hdfs** user in order to give root user permission to perform file operations:

~~~bash
#Login as hdfs user to give root permissions for file operations
su hdfs
cd
~~~

4\. Next, upload yahoo_stocks.csv file to HDFS:

~~~bash
#Copy files from local system to HDF
hdfs dfs -put /tmp/yahoo_stocks.csv /tmp/yahoo_stocks.csv
~~~

5\. Verify that both files were copied into HDFS **/tmp** folder by copying the following commands:

~~~bash
#Verify that files were move to HDF
hdfs dfs -ls /tmp | grep yahoo_stocks.csv
~~~

6\. Launch the Spark Shell:

~~~bash
spark-shell
~~~

Notice it is already starting with Hive integration as we have pre-configured it on the Hortonworks Sandbox.

7\. Before we get started with the actual analytics let's import the following Hive dependencies on line at a time:

~~~scala
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.types
import org.apache.spark.sql._
import spark.implicits._
~~~

Now we are ready to start the examples.

## Creating a SparkSession

Instantiating a SparkSession with Hive support:

~~~scala
val spark = SparkSession.builder().enableHiveSupport().getOrCreate()
~~~

## Creating ORC Tables

Specifying `as orc` at the end of the SQL statement below ensures that the Hive table is stored in the ORC format.

~~~scala
spark.sql("CREATE TABLE yahoo_orc_table (date STRING, open_price FLOAT, high_price FLOAT, low_price FLOAT, close_price FLOAT, volume INT, adj_price FLOAT) stored as orc")
~~~

## Loading the File and Creating a RDD

With the command below we instantiate an RDD:

~~~scala
val yahoo_stocks = sc.textFile("/tmp/yahoo_stocks.csv")
~~~

To preview data in `yahoo_stocks` type:

~~~scala
yahoo_stocks.take(10)
~~~

Note that `take(10)` returns only ten records that are not in any particular order.

Sample of results from **yahoo_stocks.take(10)**

~~~scala
scala> yahoo_stocks.take(10)
res4: Array[String] = Array(Date,Open,High,Low,Close,Volume,Adj Close, 2015-04-28,44.34,44.57,43.94,44.34,7188300,44.34, 201
11267500,44.52, 2015-04-23,43.92,44.06,43.58,43.70,14274900,43.70, 2015-04-22,44.58,44.85,43.67,43.98,32241200,43.98, 2015-0
52900,44.66, 2015-04-17,45.30,45.44,44.25,44.45,13305700,44.45, 2015-04-16,45.82,46.13,45.53,45.78,13800300,45.78)
~~~

### Separating the Header from the Data

Let’s assign the first row of the RDD above to a new variable:

~~~scala
val header = yahoo_stocks.first
~~~

Let’s dump this new RDD in the console to see what we have here:

~~~scala
header
~~~

Now we need to separate the data into a new RDD where we do not have the header above and

~~~scala
val data = yahoo_stocks.mapPartitionsWithIndex { (idx, iter) => if (idx == 0) iter.drop(1) else iter }
~~~

the first row to be seen is indeed only the data in the RDD

~~~scala
data.first
~~~

## Creating a Schema

Let's create the schema, copy and paste the command below:

~~~scala
case class YahooStockPrice(date: String, open: Float, high: Float, low: Float, close: Float, volume: Integer, adjClose: Float)
~~~

### Attaching the Schema to the Parsed Data

Create an RDD of Yahoo Stock Price objects and register it as a table.

~~~scala
val stockprice = data.map(_.split(",")).map(row => YahooStockPrice(row(0), row(1).trim.toFloat, row(2).trim.toFloat, row(3).trim.toFloat, row(4).trim.toFloat, row(5).trim.toInt, row(6).trim.toFloat)).toDF()
~~~

Let’s verify that the data has been correctly parsed by the statement above by dumping the first row of the RDD containing the parsed data:

~~~scala
stockprice.first
~~~

If we want to dump more all the rows, we can use:

~~~scala
stockprice.show
~~~

Sample results of **stockprice.show**

~~~scala
scala> stockprice.show 
+----------+-----+-----+-----+-----+--------+--------+
|      date| open| high|  low|close|  volume|adjClose|
+----------+-----+-----+-----+-----+--------+--------+
|2015-04-28|44.34|44.57|43.94|44.34| 7188300|   44.34|
|2015-04-27|44.65| 45.1|44.25|44.36|10840900|   44.36|
|2015-04-24|43.73|44.71|43.69|44.52|11267500|   44.52|
|2015-04-23|43.92|44.06|43.58| 43.7|14274900|    43.7|
|2015-04-22|44.58|44.85|43.67|43.98|32241200|   43.98|
|2015-04-21|45.15|45.18|44.45|44.49|16103700|   44.49|
|2015-04-20|44.73|44.91|44.41|44.66|10052900|   44.66|
|2015-04-17| 45.3|45.44|44.25|44.45|13305700|   44.45|
|2015-04-16|45.82|46.13|45.53|45.78|13800300|   45.78|
|2015-04-15|45.46|45.83|45.23|45.73|15033500|   45.73|
|2015-04-14|44.82|45.64|44.79|45.53|12365800|   45.53|
|2015-04-13|45.25|45.59|44.72|44.77| 8837300|   44.77|
|2015-04-10|45.79|45.79| 45.0|45.18| 8436400|   45.18|
|2015-04-09| 45.7|46.17|45.16|45.63|13678000|   45.63|
|2015-04-08|43.86|45.19| 43.8|45.17|16071000|   45.17|
|2015-04-07|43.79|44.22|43.56|43.61|11382000|   43.61|
|2015-04-06|43.82|44.03|43.61|43.67|10717000|   43.67|
|2015-04-02|44.24|44.36|43.68|44.15|12229400|   44.15|
|2015-04-01|44.45| 44.6|43.95|44.13|14722300|   44.13|
|2015-03-31|44.82| 45.2|44.42|44.44|10415500|   44.44|
+----------+-----+-----+-----+-----+--------+--------+
only showing top 20 rows
~~~~

To verify the schema, let’s dump the schema:

~~~scala
stockprice.printSchema
~~~

Sample of schema output:

~~~scala
scala> stockprice.printSchema
root
 |-- date: string (nullable = true)
 |-- open: float (nullable = false)
 |-- high: float (nullable = false)
 |-- low: float (nullable = false)
 |-- close: float (nullable = false)
 |-- volume: integer (nullable = true)
 |-- adjClose: float (nullable = false)
~~~

## Registering a Temporary Table

Now let’s give this RDD a name, so that we can use it in Spark SQL statements:

~~~scala
stockprice.createOrReplaceTempView("yahoo_stocks_temp")
~~~

### Querying Against the Table

Now that our schema’s RDD with data has a name, we can use Spark SQL commands to query it. Remember the table below is not a Hive table, it is just a RDD we are querying with SQL.

~~~scala
val results = spark.sql("SELECT * FROM yahoo_stocks_temp")
~~~

The result set returned from the Spark SQL query is now loaded in the `results` RDD. Let’s pretty print it out on the command line.

~~~scala
results.map(t => "Stock Entry: " + t.toString).collect().foreach(println)
~~~

Sample of results:

~~~~scala
Stock Entry: [1996-04-24,28.5,29.12496,27.75,28.99992,7795200,1.20833]
Stock Entry: [1996-04-23,28.75008,28.99992,28.00008,28.00008,4297600,1.16667]
Stock Entry: [1996-04-22,28.99992,28.99992,27.49992,28.24992,8041600,1.17708]
Stock Entry: [1996-04-19,30.12504,30.75,28.75008,28.87488,12913600,1.20312]
Stock Entry: [1996-04-18,30.12504,30.12504,28.00008,29.25,27268800,1.21875]
Stock Entry: [1996-04-17,28.24992,28.24992,24.75,27.0,42816000,1.125]
Stock Entry: [1996-04-16,32.25,32.25,28.00008,28.75008,48016000,1.19792]
Stock Entry: [1996-04-15,35.74992,36.0,30.0,32.25,79219200,1.34375]
Stock Entry: [1996-04-12,25.24992,43.00008,24.49992,33.0,408720000,1.375]
~~~~

## Saving as an ORC File

Now let’s persist back the RDD into the Hive ORC table we created before.

~~~scala
results.write.format("orc").save("yahoo_stocks_orc")
~~~

To store results in a hive directory rather than user directory, use this path instead:

~~~bash
results.write.format("orc").save("/apps/hive/warehouse/yahoo_stocks_orc")
~~~

### Reading the ORC File

Let’s now try to read back the ORC file, we just created back into an RDD

Now we can try to read the ORC file with:

~~~scala
val yahoo_stocks_orc = spark.read.format("orc").load("yahoo_stocks_orc")
~~~

Let’s register it as a temporary in-memory table mapped to the ORC table:

~~~scala
yahoo_stocks_orc.createOrReplaceTempView("orcTest")
~~~

Now we can verify whether we can query it back:

~~~scala
spark.sql("SELECT * from orcTest").collect.foreach(println)
~~~

Sample of results:

~~~~scala
Stock Entry: [1996-04-24,28.5,29.12496,27.75,28.99992,7795200,1.20833]
Stock Entry: [1996-04-23,28.75008,28.99992,28.00008,28.00008,4297600,1.16667]
Stock Entry: [1996-04-22,28.99992,28.99992,27.49992,28.24992,8041600,1.17708]
Stock Entry: [1996-04-19,30.12504,30.75,28.75008,28.87488,12913600,1.20312]
Stock Entry: [1996-04-18,30.12504,30.12504,28.00008,29.25,27268800,1.21875]
Stock Entry: [1996-04-17,28.24992,28.24992,24.75,27.0,42816000,1.125]
Stock Entry: [1996-04-16,32.25,32.25,28.00008,28.75008,48016000,1.19792]
Stock Entry: [1996-04-15,35.74992,36.0,30.0,32.25,79219200,1.34375]
Stock Entry: [1996-04-12,25.24992,43.00008,24.49992,33.0,408720000,1.375]
~~~~

## Summary

Congratulations! You just did a round trip of using Spark shell, reading data from HDFS, creating an Hive table in ORC format, querying the Hive Table, and persisting data using Spark SQL.

Hope this tutorial illustrated some of the ways you can integrate Hive and Spark.

## Further Reading

- [Hortonworks Apache Spark Component Guide](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.5/bk_spark-component-guide/content/ch_developing-spark-apps.html)
- [Apache Spark](https://spark.apache.org/docs/latest/sql-programming-guide.html#overview)