---
title: Loading Sensor Data into HDFS
---

# Hadoop Tutorial – Getting Started with HDP

## Loading Sensor Data into HDFS

## Introduction

In this section, you will download the sensor data and load that into HDFS using Ambari User Views. You will get introduced to the Ambari Files User View to manage files. You can perform tasks like create directories, navigate file systems and upload files to HDFS.  In addition, you’ll perform a few other file-related tasks as well.  Once you get the basics, you will create two directories and then load two files into HDFS using the Ambari Files User View.

## Prerequisites

The tutorial is a part of series of hands on tutorial to get you started on HDP using Hortonworks sandbox. Please ensure you complete the prerequisites before proceeding with this tutorial.

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline

- [HDFS backdrop](#hdfs-backdrop)
- [Download and Extract Sensor Data Files](#download-and-extract-sensor-data-files)
- [Load the Sensor Data into HDFS](#load-the-sensor-data-into-hdfs)
- [Summary](#summary)
- [Further Reading](#further-reading)

## HDFS backdrop

A single physical machine gets saturated with its storage capacity as the data grows. This growth drives the need to partition your data across separate machines. This type of File system that manages storage of data across a network of machines is called Distributed File Systems. [HDFS](https://hortonworks.com/blog/thinking-about-the-hdfs-vs-other-storage-technologies/) is a core component of Apache Hadoop and is designed to store large files with streaming data access patterns, running on clusters of commodity hardware. With Hortonworks Data Platform (HDP), HDFS is now expanded to support [heterogeneous storage](https://hortonworks.com/blog/heterogeneous-storage-policies-hdp-2-2/) media within the HDFS cluster.

## Download and Extract Sensor Data Files

1.  Download the sample sensor data contained in a compressed (.zip) folder here:  [**Geolocation.zip**](assets/datasets/Geolocation.zip)
2.  Save the **Geolocation.zip** file to your computer, then extract the files. You should see a Geolocation folder that contains the following files:
    - **geolocation.csv** – This is the collected geolocation data from the trucks. It contains records showing _truck location, date, time, type of event, speed, etc_.
    - **trucks.csv** – This is data was exported from a relational database and it shows information on _truck models, driverid, truckid, and aggregated mileage info_.

## Load the Sensor Data into HDFS

1\.   Logon to Ambari using: **maria_dev**/**maria_dev**

2\.   Go to Ambari Dashboard and open **Files View**.

![files-view](assets/files-view.jpg)

3\.  Start from the top root of the HDFS file system, you will see all the files the logged in user (**maria_dev** in this case) has access to see:

![root-files-view](assets/root-files-view.jpg)

4\. Navigate to `/tmp/` directory by clicking on the directory links.

5\. Create directory `data`. Click the ![new_folder_icon_lab1](assets/new_folder_icon_lab1.png) button to create that directory. Then navigate to it. The directory path you should see: `/tmp/data`

![add-new-folder](assets/add-new-folder.jpg)

### Upload Geolocation and Trucks CSV Files to data Folder

1\. If you're not already in your newly created directory path `/tmp/data`, go to the **data** folder. Then click on the ![upload_icon_lab1](assets/upload_icon_lab1.png) button to upload the corresponding **geolocation.csv** and **trucks.csv** files into it.

2\. An **Upload file** window will appear, click on the cloud symbol.

![upload_file_lab1](assets/upload_file_lab1.jpg)

3\. Another window will appear, navigate to the destination the two csv files were downloaded. Click on one at a time, press open to complete the upload. Repeat the process until both files are uploaded.

![upload_file_window_lab1](assets/upload_file_window_lab1.png)

Both files are uploaded to HDFS as shown in the Files View UI:

![uploaded-files](assets/uploaded-files.jpg)

You can also perform the following operations on a file or folder by clicking on the entity's row: **Open**, **Rename**, **Permissions**, **Delete**, **Copy**, **Move**, **Download** and **Concatenate**.

### Set Write Permissions to Write to data Folder

1. click on the `data` folder's row, which is contained within the directory path `/tmp/`.
2. Click **Permissions**.
3. Make sure that the background of all the **write** boxes are checked (**blue**).

Refer to image for a visual explanation.

![edit-permissions](assets/edit-permissions.jpg)

## Summary

Congratulations! Let’s summarize the skills and knowledge we acquired from this tutorial. We learned **Hadoop Distributed File System (HDFS)** was built to manage storing data across multiple machines. Now we can upload data into the HDFS using Ambari’s HDFS **Files view**.

## Further Reading

- [HDFS](https://hortonworks.com/hadoop/hdfs/)
- [HDFS User Guide](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html)
- [HDFS Architecture Guide](https://hadoop.apache.org/docs/r1.0.4/hdfs_design.html)
- [HDP OPERATIONS: HADOOP ADMINISTRATION](https://hortonworks.com/training/class/hdp-operations-hadoop-administration-fundamentals/)
