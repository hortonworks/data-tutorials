---
title: Visualizing HVAC Systems with Extreme Temperature
---

# Visualizing HVAC Systems with Extreme Temperature

## Introduction

## Prerequisites

## Outline

- [Visualize Temperature Ranges of Countries](#visualize-temperature-ranges-of-countries)
- [Visualize HVAC Systems with Extreme Temperature](#visualize-buildings-with-extreme-temperature)

## Visualize Temperature Ranges of Countries

Create a new note called `HVAC Data Analysis`.

Configuration for Hive is done by placing hive-site.xml, core-site.xml and
hdfs-site.xml files into `/etc/spark2/conf/` directory.

Spark SQL will be used to read and write data stored in Hive.

To work with Hive:
1\. Instantiate SparkSession with Hive support

2\. Include connectivity to a persistent Hive metastore, support for Hive serdes, Hive UDFs

Note: When not configured by hive-site.xml, context auto creates metastore_db
in current directory and creates directory configured by spark.sql.warehouse.dir
, which defaults to directory spark-warehouse in current directory Spark app is started

Note: hive.metastore.warehouse.dir property in hive-site.xml is deprecated since
Spark 2.0.0, so use spark.sql.warehouse.dir to specify the default location of
database in warehouse
Note: You may need to grant write privilege to the user who starts Spark application.

~~~js
%spark2
//Import Hive Dependencies
import java.io.File
import org.apache.spark.sql.{Row, SaveMode, SparkSession}

val hiveWarehouseLocation = "hdfs://sandbox-hdp.hortonworks.com:8020/apps/hive/warehouse/"

//Creating SparkSession with Hive Support
val spark = SparkSession
  .builder()
  .appName("Spark Analysis on Hive Tables") //Sets name for app, shown in web ui
  .config("spark.sql.warehouse.dir", hiveWarehouseLocation)
  .enableHiveSupport() //includes connectivity to Hive metastore, serdes, UDFs
  .getOrCreate() //if no existing SparkSession creates new one based on options set in builder
~~~

3\. Perform SparkSQL query against Hive table hvac_building selecting country, extremetemp and temprange.

~~~js
%spark2
import spark.implicits._
import spark.sql

// Queries are expressed in HiveQL
sql("SELECT country, extremetemp, temprange FROM hvac_building").show()
~~~

4\. Visualize a bar graph of the HVAC data with country being on the X-axis and SUM of extremetemp per country being on the Y-axis.

~~~js
%spark2

~~~


5\. Visualize a bar graph of the HVAC data with country being on the X-axis, COUNT the extremetemp per country and group temprange into categories of HOT, COLD and NORMAL.

~~~js
%spark2

~~~


## Visualize HVAC Systems with Extreme Temperature

~~~js
%spark2
display(sql("SELECT hvacproduct, extremetemp FROM hvac_building"))
~~~

> Illustrate hvac_building table view of hvacproduct and temprange columns

Visualize each hvacproduct with a COUNT of their extremetemp in a bar graph.

~~~js

~~~

## Summary

## Further Reading

- [Spark SQL Applied to Existing Hive Tables](https://spark.apache.org/docs/latest/sql-programming-guide.html#hive-tables)
- [SparkSession.Builder API Doc](https://spark.apache.org/docs/2.3.0/api/java/org/apache/spark/sql/SparkSession.Builder.html#Builder--)
- [Connect Spark to Hive Metastore](https://stackoverflow.com/questions/31980584/how-to-connect-to-a-hive-metastore-programmatically-in-sparksql)
