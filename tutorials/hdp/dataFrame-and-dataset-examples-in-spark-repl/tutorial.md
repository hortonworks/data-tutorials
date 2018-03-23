---
title: DataFrame and Dataset Examples in Spark REPL
author: Robert Hryniewicz
tutorial-id: 391
experience: Beginner
persona: Developer
source: Hortonworks
use case: Data Discovery
technology: Apache Spark
release: hdp-2.6.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# DataFrame and Dataset Examples in Spark REPL

## Introduction

This tutorial will get you started with Apache Spark and will cover:

- How to use the Spark DataFrame & Dataset API
- How to use SparkSQL Thrift Server for JDBC/ODBC access

Interacting with Spark will be done via the terminal (i.e. command line).

## Prerequisites

This tutorial assumes that you are running an HDP Sandbox.

Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Downloaded and Installed the [Hortonworks Sandbox](https://hortonworks.com/products/sandbox/)
-   Reviewed [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline

-   [DataFrame API Example](#dataframe-api-example)
-   [DataSet API Example](#dataset-api-example)

-   [Further Reading](#further-reading)


## DataFrame API Example

**Spark 1.6.x Version**

 DataFrame API provides easier access to data since it looks conceptually like a Table and a lot of developers from Python/R/Pandas are familiar with it.

Assuming you start as `root` user, switch to user *spark*:

~~~ bash
su spark
~~~

Next, upload people.txt and people.json files to HDFS:

~~~ bash
cd /usr/hdp/current/spark-client
hdfs dfs -copyFromLocal examples/src/main/resources/people.txt /tmp/people.txt
hdfs dfs -copyFromLocal examples/src/main/resources/people.json /tmp/people.json
~~~

Launch the Spark Shell:

~~~ bash
./bin/spark-shell
~~~

At a `scala>` REPL prompt, type the following:

~~~ js
val df = sqlContext.jsonFile("/tmp/people.json")
~~~

Using `df.show`, display the contents of the DataFrame:

~~~ js
df.show
~~~

You should see an output similar to:

~~~ js
...
15/12/16 13:28:15 INFO YarnScheduler: Removed TaskSet 2.0, whose tasks have all completed, from pool
+----+-------+
| age|   name|
+----+-------+
|null|Michael|
|  30|   Andy|
|  19| Justin|
+----+-------+

scala>
~~~

**Additional DataFrame API examples**

Continuing at the `scala>` prompt, type the following to import sql functions:

~~~ js
import org.apache.spark.sql.functions._ 
~~~

and select "name" and "age" columns and increment the "age" column by 1:

~~~ js
df.select(df("name"), df("age") + 1).show()
~~~

This will produce an output similar to the following:

~~~ bash
...
+-------+---------+
|   name|(age + 1)|
+-------+---------+
|Michael|     null|
|   Andy|       31|
| Justin|       20|
+-------+---------+

scala>
~~~

To return people older than 21, use the filter() function:

~~~ js
df.filter(df("age") > 21).show()
~~~

This will produce an output similar to the following:

~~~ bash
...
+---+----+
|age|name|
+---+----+
| 30|Andy|
+---+----+

scala>
~~~

Next, to count the number of people of specific age, use groupBy() & count() functions:

~~~ js
df.groupBy("age").count().show()
~~~

This will produce an output similar to the following:

~~~ bash
...
+----+-----+
| age|count|
+----+-----+
|null|    1|
|  19|    1|
|  30|    1|
+----+-----+

scala>
~~~

**Programmatically Specifying Schema**

~~~ js
import org.apache.spark.sql._ 

// Create sql context from an existing SparkContext (sc)
val sqlContext = new org.apache.spark.sql.SQLContext(sc)

// Create people RDD
val people = sc.textFile("/tmp/people.txt")

// Encode schema in a string
val schemaString = "name age"

// Import Spark SQL data types and Row
import org.apache.spark.sql.types.{StructType,StructField,StringType} 

// Generate the schema based on the string of schema
val schema = 
  StructType(
    schemaString.split(" ").map(fieldName => StructField(fieldName, StringType, true)))

// Convert records of people RDD to Rows
val rowRDD = people.map(_.split(",")).map(p => Row(p(0), p(1).trim))

// Apply the schema to the RDD
val peopleSchemaRDD = sqlContext.createDataFrame(rowRDD, schema)

// Register the SchemaRDD as a table
peopleSchemaRDD.registerTempTable("people")

// Execute a SQL statement on the 'people' table
val results = sqlContext.sql("SELECT name FROM people")

// The results of SQL queries are SchemaRDDs and support all the normal RDD operations.
// The columns of a row in the result can be accessed by ordinal
results.map(t => "Name: " + t(0)).collect().foreach(println)
~~~

This will produce an output similar to the following:

~~~ js
15/12/16 13:29:19 INFO DAGScheduler: Job 9 finished: collect at :39, took 0.251161 s
15/12/16 13:29:19 INFO YarnHistoryService: About to POST entity application_1450213405513_0012 with 10 events to timeline service http://green3:8188/ws/v1/timeline/
Name: Michael
Name: Andy
Name: Justin

scala>
~~~

To exit type `exit`.


## DataSet API Example

If you haven't done so already in previous sections, make sure to upload people data sets (people.txt and people.json) to HDFS:

~~~ bash
cd /usr/hdp/current/spark-client
hdfs dfs -copyFromLocal examples/src/main/resources/people.txt /tmp/people.txt
hdfs dfs -copyFromLocal examples/src/main/resources/people.json /tmp/people.json
~~~

And if you haven't already, switch to user *spark*:

~~~ bash
su spark
~~~

**Spark 1.6.x Version**

The Spark Dataset API brings the best of RDD and Data Frames together, for type safety and user functions that run directly on existing JVM types.

**Launch Spark Shell**

~~~ bash
./bin/spark-shell
~~~

Let's try the simplest example of creating a dataset by applying a *toDS()* function to a sequence of numbers.

At the `scala>` prompt, copy & paste the following:

~~~ js
val ds = Seq(1, 2, 3).toDS()
ds.show
~~~

You should see the following output:

~~~ bash
+-----+
|value|
+-----+
|    1|
|    2|
|    3|
+-----+
~~~

Moving on to a slightly more interesting example, let's prepare a *Person* class to hold our person data. We will use it in two ways by applying it directly on a hardcoded data and then on a data read from a json file.

To apply *Person* class to hardcoded data type:

~~~ bash
case class Person(name: String, age: Long)
val ds = Seq(Person("Andy", 32)).toDS()
~~~

When you type

~~~ bash
ds.show
~~~

you should see the following output of the *ds* Dataset

~~~ bash
+----+---+
|name|age|
+----+---+
|Andy| 32|
+----+---+
~~~

Finally, let's map data read from *people.json* to a *Person* class. The mapping will be done by name.

~~~ bash
val path = "/tmp/people.json"
val people = sqlContext.read.json(path) // Creates a DataFrame
~~~

To view contents of people DataFrame type:

~~~ js
people.show
~~~

You should see an output similar to the following:

~~~ bash
...
+----+-------+
| age|   name|
+----+-------+
|null|Michael|
|  30|   Andy|
|  19| Justin|
+----+-------+
~~~

Note that the *age* column contains a *null* value. Before we can convert our people DataFrame to a Dataset, let's filter out the *null* value first:

~~~ bash
val pplFiltered = people.filter("age is not null")
~~~

Now we can map to the *Person* class and convert our DataFrame to a Dataset.

~~~ bash
val pplDS = pplFiltered.as[Person]
~~~

View the contents of the Dataset type

~~~ bash
pplDS.show
~~~

You should see the following

~~~ bash
+------+---+
|  name|age|
+------+---+
|  Andy| 30|
|Justin| 19|
+------+---+
~~~

To exit type `exit`.

## Further Reading

Next, explore more advanced [SparkSQL commands in a Zeppelin Notebook]( https://hortonworks.com/tutorial/learning-spark-sql-with-zeppelin/).
