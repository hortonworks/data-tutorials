---
title: Spark on YARN Example
author: Robert Hryniewicz
tutorial-id: 394
experience: Beginner
persona: Developer
source: Hortonworks
use case: Data Discovery
technology: Apache Spark
release: hdp-2.6.5
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Spark on YARN Example

## Introduction

In this brief tutorial you will run a pre-built Spark example on YARN

## Prerequisites

This tutorial assumes that you are running an HDP Sandbox.

Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Downloaded and Installed the [Hortonworks Sandbox](https://hortonworks.com/products/sandbox/)
-   Reviewed [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Pi Example

To test compute intensive tasks in Spark, the Pi example calculates pi by “throwing darts” at a circle. The example points in the unit square ((0,0) to (1,1)) and sees how many fall in the unit circle. The fraction should be pi/4, which is used to estimate Pi.

To calculate Pi with Spark in yarn-client mode.

Assuming you start as `root` user follow these steps depending on your Spark version.

Note: We have provided two examples one for Spark 2.x and another for Spark 1.6.x for reference.

**Spark 2.x Version**

From the Sandbox terminal (command line):

~~~ bash
root@sandbox# export SPARK_MAJOR_VERSION=2
root@sandbox# cd /usr/hdp/current/spark2-client
root@sandbox spark2-client# su spark
spark@sandbox spark2-client$ ./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-client --num-executors 3 --driver-memory 512m --executor-memory 512m --executor-cores 1 examples/jars/spark-examples*.jar 10
~~~

**Spark 1.6.x Version**

From the Sandbox terminal (command line):

~~~ bash
root@sandbox# export SPARK_MAJOR_VERSION=1
root@sandbox# cd /usr/hdp/current/spark-client
root@sandbox spark-client# su spark
spark@sandbox spark-client$ ./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-client --num-executors 3 --driver-memory 512m --executor-memory 512m --executor-cores 1 lib/spark-examples*.jar 10
~~~

**Note:** The Pi job should complete without any failure messages and produce output similar to below, note the value of Pi in the output message:

~~~ js
...
16/02/25 21:27:11 INFO YarnScheduler: Removed TaskSet 0.0, whose tasks have all completed, from pool
16/02/25 21:27:11 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:36, took 19.346544 s
Pi is roughly 3.143648
16/02/25 21:27:12 INFO ContextHandler: stopped o.s.j.s.ServletContextHandler{/metrics/json,null}
...
~~~

## Next steps

At this point, you might want to set up a complete development  environment for writing and debugging your Spark applications.

Checkout one of the following tutorials on how to set up a full development environment for either [Python](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-python/), [Scala](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-scala/), or [Java](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-java/).
