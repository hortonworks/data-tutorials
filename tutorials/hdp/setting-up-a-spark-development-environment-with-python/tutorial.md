---
title: Setting up a Spark Development Environment with Python
author: sandbox-team
tutorial-id: 801
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Predictive
technology: Apache Spark
release: hdp-3.0.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Setting up a Spark Development Environment with Python

## Introduction

This tutorial will teach you how to set up a full development environment for developing Spark applications. For this tutorial we'll be using Python, but Spark also supports development with [Java](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-java/), [Scala](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-scala/) and R.

We'll be using PyCharm Community Edition as our IDE. PyCharm Professional edition can also be used. By the end of the tutorial, you'll know how to set up Spark with PyCharm and how to deploy your code to the sandbox or a cluster.

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- [Learning the Ropes of HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)
- Installed [Python](https://www.python.org/)
- Installed [PyCharm](https://www.jetbrains.com/pycharm/)

## Outline

- [Create New PyCharm Project](#create-new-pycharm-project)
- [Download and Save Dataset](#download-and-save-dataset)
- [Create a Spark Application](#create-a-spark-application)
- [Deploying to the Sandbox](#deploying-to-the-sandbox)
- [Deploying to the Cloud](#deploying-to-the-cloud)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Create New PyCharm Project

> NOTE: Instructions may vary based on operating system.

To create a new project select **File** > **New Project**. Name the project **HelloSpark** and save in **~/PycharmProjects/HelloSpark**.

![pycharm-create](assets/pycharm-create.jpg)

You should now have an empty project called HelloSpark.

## Download and Save Dataset

For our first application we're going to build a simple program that performs a word count on the collected works of Shakespeare - Right click and select **Save as** to download the [_shakespeaker.txt_ file](assets/shakespeare.txt).

We need to save two copies of this dataset. One, inside PyCharm project for testing on local system and another on HDFS (Hadoop Distributed File System) for testing on the sandbox.

1\. On local system, copy **shakespeare.txt** to **~/PycharmProjects/HelloSpark**

2\. Upload to HDFS (make sure sandbox is up and running):

- Navigate to [sandbox-hdp.hortonworks.com:8080](http://sandbox-hdp.hortonworks.com:8080)
- Login using username/password as **maria_dev** / **maria_dev**
- Once you've logged into Ambari Manager, mouse over the drop-down menu on the upper-right hand corner and click on **Files View**.

![select_files_view](assets/files-view.jpg)

- Open the **tmp** folder and click the **upload** button in the upper-right corner to upload the file. Make sure it's named **shakespeare.txt**.

![files-view-saved](assets/files-view-saved.jpg)

## Create a Spark Application

Now the fun part begins!

Let's create the application:

Right-click on **HelloSpark** > Select **New** > **File**, name it **Main.py**

![pycharm-newfile](assets/pycharm-newfile.jpg)

- Copy the following code into it:

~~~python
from pyspark import SparkContext, SparkConf

conf = SparkConf().setAppName('MyFirstStandaloneApp')
sc = SparkContext(conf=conf)

text_file = sc.textFile("./shakespeare.txt")

counts = text_file.flatMap(lambda line: line.split(" ")) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)

print ("Number of elements: " + str(counts.count()))
counts.saveAsTextFile("./shakespeareWordCount")
~~~

To run your program, click **Run** > **Run...** from IDE menu and select **Main**. That's all it takes to perform a word count in Spark. The results are saved in **shakespeareWordCount** folder that is on the same directory that your source-code is saved.

> NOTE: **pyspark** package may need to be installed.

In order to install the **pyspark** package navigate to **Pycharm** > **Preferences** > **Project: HelloSpark** > **Project interpreter** and click **+**

![pycharm-preferences](assets/pycharm-preferences.jpg)

Now search and select **pyspark** and click **Install Package**

![pyspark-install-pyspark](assets/pyspark-install-pycharm.jpg)

## Deploying to the Sandbox

In this section we will deploy our code on the Hortonworks Data Platform (HDP) Sandbox.

First, we need to modify the code. We need to read the dataset from HDFS instead of the local PyCharm project.

~~~python
# REPLACE THIS
text_file = sc.textFile("./shakespeare.txt")

# TO THIS
text_file = sc.textFile("hdfs:///tmp/shakespeare.txt")
~~~

and

~~~python
# REPLACE THIS
counts.saveAsTextFile("./shakespeareWordCount")

# TO THIS
counts.saveAsTextFile("hdfs:///tmp/shakespeareWordCount")
~~~

Copy **Main.py** to HDP sandbox using **_Secure Copy Protocol (SCP)_**:

~~~bash
scp -P 2222 ./Main.py root@sandbox-hdp.hortonworks.com:/root
~~~

Next, open sandbox shell using [Shell-in-a-Box](http://sandbox-hdp.hortonworks.com:4200) or **ssh**:

~~~bash
ssh -p 2222 root@sandbox-hdp.hortonworks.com
~~~

Finally, use **spark-submit** to run the program:

~~~bash
spark-submit ./Main.py
~~~

> NOTE: If you encounter the error: **Output directory hdfs://sandbox-hdp.hortonworks.com:8020/tmp/shakespeareWordCount already exists** use the following command on the sandbox shell: `hdfs dfs -rm -r /tmp/shakespeareWordCount` and resubmit.

The results are saved on HDFS: **/tmp/shakespeareWordCount**. You will see a word count output that looks like this:

~~~text
...
(u'fawn', 11)
(u'Fame,', 3)
(u'mustachio', 1)
(u'protested,', 1)
(u'sending.', 3)
(u'offendeth', 1)
(u'instant;', 1)
(u'scold', 4)
(u'Sergeant.', 1)
(u'nunnery', 1)
(u'Sergeant,', 2)
...
~~~

## Deploying to the Cloud

In this section we'll learn how to deploy our code to a real cluster. If you don't have a cluster available you can quickly set one up using [Hortonworks Cloud Solutions](https://hortonworks.com/products/data-platforms/cloud/).

These services are designed to let you quickly spin up a cluster for a few hours (perhaps on cheaper spot instances), run a series of jobs, then spin the cluster back down to save money. If you want a permanent installation of Hadoop that will run for months without being shutdown, you should download [Hortonworks Data Platform](https://hortonworks.com/downloads/#data-platform) and install on your servers.

After setting up a cluster the process of deploying our code is similar to deploying to the sandbox. We need to scp our code to the cluster:

~~~bash
scp -P 2222 -i "key.pem" ~/PycharmProjects/HelloSpark/Main.py root@[ip address of a master node]:root
~~~

Then open a second terminal window and ssh into the master node:

~~~bash
ssh -p 2222 -i "key.pem" root@[ip address of a master node]
~~~

Then use **spark-submit** to run our code:

~~~bash
spark-submit ~/Main.py --master yarn --deploy-mode client
~~~

Notice that we specified the parameters **--master yarn** - it means we want Spark to run in a distributed mode rather than on a single machine, and we want to rely on YARN (a cluster resource manager) to fetch available machines to run the job. If you aren't familiar with YARN, it is especially important if you want to run several jobs simultaneously on the same cluster. When configured properly, a YARN queue will provide different users or process a quota of cluster resources they're allowed to use. It also provides mechanisms for allowing a job to take full use of the cluster when resources are available and scaling existing jobs down when additional users or jobs begin to submit jobs.

The parameter **--deploy-mode client** indicates we want to use the current machine as the driver machine for Spark. The driver machine is a single machine that initiates a Spark job, and is also where summary results are collected when the job is finished. Alternatively, we could have specified **--deploy-mode cluster**, which would have allowed YARN to choose the driver machine.

It's important to note that a poorly written Spark program can accidentally try to bring back many Terabytes of data to the driver machine, causing it to crash. For this reason you shouldn't use the master node of your cluster as your driver machine. Many organizations submit Spark jobs from what's called an edge node, which is a separate machine that isn't used to store data or perform computation. Since the edge node is separate from the cluster, it can go down without affecting the rest of the cluster. Edge nodes are also used for data science work on aggregate data that has been retrieved from the cluster. For example, a data scientist might submit a Spark job from an edge node to transform a 10 TB dataset into a 1 GB aggregated dataset, and then do analytics on the edge node using tools like R and Python. If you plan on setting up an edge node, make sure that machine doesn't have the DataNode or HostManager components installed, since these are the data storage and compute components of the cluster. You can check this on the host tab in Ambari.

## Summary

In this tutorial we learned how to set up an Integrated Developing Environment to write and deploy code to the Hortonworks Data Platform Sandbox and for a cluster running in the cloud. Utilizing the convenience of Pycharm along with the power of HDP you can create truly powerful applications and easily deploy them without compromise.

## Further Reading

- [Setting up a Spark Developing Environment with Java](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-java/)
- [Setting up a Spark Developing Environment with Scala](https://hortonworks.com/tutorial/setting-up-a-spark-development-environment-with-scala/)
- [Spark Tutorials](https://hortonworks.com/tutorials/?tab=product-hdp&filters=apache-spark)
