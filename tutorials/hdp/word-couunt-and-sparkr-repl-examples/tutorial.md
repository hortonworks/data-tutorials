---
title: Word Count & SparkR REPL Examples
author: Robert Hryniewicz
tutorial-id: 392
experience: Beginner
persona: Developer
source: Hortonworks
use case: Data Discovery
technology: Apache Spark
release: hdp-2.6.0
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Word Count & SparkR REPL Examples

## Introduction

This tutorial will get you started with a couple of Spark REPL examples

-   How to run Spark word count examples
-   How to use SparkR

You can choose to either use Spark 1.6.x or Spark 2.x API examples.

## Prerequisites

This tutorial assumes that you are running an HDP Sandbox.

Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Downloaded and Installed the [Hortonworks Sandbox](https://hortonworks.com/products/sandbox/)
-   Reviewed [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline

-   [WordCount Example](#wordcount-example)
-   [SparkR Example](#sparkr-example)

-   [Further Reading](#further-reading)


## WordCount Example

**Copy input file for Spark WordCount Example**

Upload the input file you want to use in WordCount to HDFS. You can use any text file as input. In the following example, log4j.properties is used as an example:

If you haven't already, switch to user *spark*:

~~~ bash
su spark
~~~

Next,

~~~ bash
cd /usr/hdp/current/spark2-client/
hdfs dfs -copyFromLocal /etc/hadoop/conf/log4j.properties /tmp/data.txt
~~~

**Spark 2.x Version**

Here's an example of a WordCount in Spark 2.x. (For Spark 1.6.x scroll down.)

**Run the Spark shell:**

~~~ bash
./bin/spark-shell 
~~~

Output similar to the following will be displayed, followed by a `scala>` REPL prompt:

~~~ bash
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.2.0.2.6.4.0-91
      /_/

Using Scala version 2.11.8 (OpenJDK 64-Bit Server VM, Java 1.8.0_161)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
~~~

Read data and convert to Dataset

~~~ js
val data = spark.read.textFile("/tmp/data.txt").as[String]
~~~

Split and group by lowercased word

~~~ js
val words = data.flatMap(value => value.split("\\s+"))
val groupedWords = words.groupByKey(_.toLowerCase)
~~~

Count words

~~~ js
val counts = groupedWords.count()
~~~

Show results

~~~ js
counts.show()
~~~

You should see the following output

~~~ bash
+--------------------+--------+
|               value|count(1)|
+--------------------+--------+
|                some|       1|
|hadoop.security.l...|       1|
|log4j.rootlogger=...|       1|
|log4j.appender.nn...|       1|
|log4j.appender.tl...|       1|
|hadoop.security.l...|       1|
|            license,|       1|
|                 two|       1|
|             counter|       1|
|log4j.appender.dr...|       1|
|hdfs.audit.logger...|       1|
|yarn.ewma.maxuniq...|       1|
|log4j.appender.nm...|       1|
|              daemon|       1|
|log4j.category.se...|       1|
|log4j.appender.js...|       1|
|log4j.appender.dr...|       1|
|        blockmanager|       1|
|log4j.appender.js...|       1|
|                 set|       4|
+--------------------+--------+
only showing top 20 rows
~~~

**Spark 1.6.x Version**

Here's how to run a WordCount example in Spark 1.6.x

**Run the Spark shell:**

If you haven't already, switch to user *spark*:

~~~ bash
su spark
~~~

Next,

~~~ bash
cd /usr/hdp/current/spark-client/
./bin/spark-shell 
~~~

Output similar to the following will be displayed, followed by a `scala>` REPL prompt:

~~~ bash
Welcome to
     ____              __
    / __/__  ___ _____/ /__
   _\ \/ _ \/ _ `/ __/  '_/
  /___/ .__/\_,_/_/ /_/\_\   version 1.6.2
     /_/
Using Scala version 2.10.5 (OpenJDK 64-Bit Server VM, Java 1.7.0_101)
Type in expressions to have them evaluated.
Type :help for more information.
15/12/16 13:21:57 INFO SparkContext: Running Spark version 1.6.2
...

scala>
~~~

At the `scala` REPL prompt enter:

~~~ js
val file = sc.textFile("/tmp/data.txt")
val counts = file.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)
~~~

Save `counts` to a file:

~~~ js
counts.saveAsTextFile("/tmp/wordcount")
~~~

**Viewing the WordCount output with Scala Shell**


To view the output, at the `scala>` prompt type:

~~~ js
counts.count()
~~~

You should see an output screen similar to:

~~~ js
...
16/02/25 23:12:20 INFO DAGScheduler: Job 1 finished: count at <console>:32, took 0.541229 s
res1: Long = 341

scala>
~~~

To print the full output of the WordCount job type:

~~~ js
counts.toArray().foreach(println)
~~~

You should see an output screen similar to:

~~~ js
...
((Hadoop,1)
(compliance,1)
(log4j.appender.RFAS.layout.ConversionPattern=%d{ISO8601},1)
(additional,1)
(default,2)

scala>
~~~

**Viewing the WordCount output with HDFS**

To read the output of WordCount using HDFS command:
Exit the Scala shell.

~~~ bash
exit
~~~

View WordCount Results:

~~~ bash
hdfs dfs -ls /tmp/wordcount
~~~

You should see an output similar to:

~~~ bash
/tmp/wordcount/_SUCCESS
/tmp/wordcount/part-00000
/tmp/wordcount/part-00001
~~~

Use the HDFS `cat` command to see the WordCount output. For example,

~~~ bash
hdfs dfs -cat /tmp/wordcount/part-00000
~~~



## SparkR Example

**Spark 1.6.x Version**

**Prerequisites**

Before you can run SparkR, you need to install R linux distribution by following these steps as a `root` user:

~~~ bash
cd /usr/hdp/current/spark-client
sudo yum update
sudo yum install R
~~~

Switch to user *spark*:

~~~ bash
su spark
~~~

**Upload data set**

If you haven't done so already in previous sections, make sure to upload *people.json* to HDFS:

~~~ bash
hdfs dfs -copyFromLocal examples/src/main/resources/people.json /tmp/people.json
~~~

**Launch SparkR**

~~~ bash
./bin/sparkR
~~~

You should see an output similar to the following:

~~~ js
...
Welcome to
   ____              __
  / __/__  ___ _____/ /__
 _\ \/ _ \/ _ `/ __/  '_/
/___/ .__/\_,_/_/ /_/\_\   version  1.6.2
   /_/


Spark context is available as sc, SQL context is available as sqlContext
>
~~~

Initialize SQL context:

~~~ js
sqlContext <- sparkRSQL.init(sc)
~~~

Create a DataFrame:

~~~ js
df <- createDataFrame(sqlContext, faithful)
~~~

List the first few lines:

~~~ js
head(df)
~~~

You should see an output similar to the following:

~~~ js
...
eruptions waiting
1     3.600      79
2     1.800      54
3     3.333      74
4     2.283      62
5     4.533      85
6     2.883      55
>
~~~

Create people DataFrame from 'people.json':

~~~ js
people <- read.df(sqlContext, "/tmp/people.json", "json")
~~~

List the first few lines:

~~~ js
head(people)
~~~

You should see an output similar to the following:

~~~ js
...
age    name
1  NA Michael
2  30    Andy
3  19  Justin
~~~

For additional SparkR examples, see https://spark.apache.org/docs/latest/sparkr.html.

To exit SparkR type:

~~~ js
quit()
~~~

## Next steps

Next learn more about [Spark DataFrames and Datasets](https://hortonworks.com/tutorial/dataframe-and-dataset-examples-in-spark-repl/) that allow for higher-level data manipulation and abstract away optimization details.
