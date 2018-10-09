---
title: Spark SQL Thrift Server Example
author: Robert Hryniewicz
tutorial-id: 393
experience: Intermediate
persona: Developer
source: Hortonworks
use case: Data Discovery
technology: Apache Spark
release: hdp-2.6.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Spark SQL Thrift Server Example

## Introduction

This is a very short tutorial on how to use SparkSQL Thrift Server for JDBC/ODBC access

## Prerequisites

This tutorial assumes that you are running an HDP Sandbox.

Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Downloaded and Installed the [Hortonworks Sandbox](https://hortonworks.com/products/sandbox/)
-   Reviewed [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## SparkSQL Thrift Server Example

SparkSQL’s thrift server provides JDBC access to SparkSQL.

**Create logs directory**

Once logged in the sandbox terminal (command line), change ownership of `logs` directory from `root` to `spark` user:

~~~ bash
cd /usr/hdp/current/spark-client
chown spark:hadoop logs
~~~

**Start Thrift Server**

~~~ bash
su spark
./sbin/start-thriftserver.sh --master yarn-client --executor-memory 512m --hiveconf hive.server2.thrift.port=10015
~~~

**Connect to the Thrift Server over Beeline**

Launch Beeline:

~~~ bash
./bin/beeline
~~~

**Connect to Thrift Server and issue SQL commands**

On the `beeline>` prompt type:

~~~ sql
!connect jdbc:hive2://localhost:10015
~~~

***Notes***
- This example does not have security enabled, so any username-password combination should work.
- The connection may take a few seconds to be available in a Sandbox environment.

You should see an output similar to the following:

~~~
beeline> !connect jdbc:hive2://localhost:10015
Connecting to jdbc:hive2://localhost:10015
Enter username for jdbc:hive2://localhost:10015:
Enter password for jdbc:hive2://localhost:10015:
...
Connected to: Spark SQL (version 1.6.2)
Driver: Spark Project Core (version 1.6.1.2.5.0.0-817)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://localhost:10015>
~~~

Once connected, try `show tables`:

~~~ sql
show tables;
~~~

You should see an output similar to the following:

~~~ bash
+------------+--------------+--+
| tableName  | isTemporary  |
+------------+--------------+--+
| sample_07  | false        |
| sample_08  | false        |
| testtable  | false        |
+------------+--------------+--+
3 rows selected (2.399 seconds)
0: jdbc:hive2://localhost:10015>
~~~

Type `Ctrl+C` to exit beeline.

**Stop Thrift Server**

~~~ bash
./sbin/stop-thriftserver.sh
~~~
