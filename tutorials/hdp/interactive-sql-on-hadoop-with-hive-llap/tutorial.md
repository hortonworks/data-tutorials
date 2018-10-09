---
title: Interactive SQL on Hadoop with Hive LLAP
author: George Rueda de Leon
tutorial-id: 720
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: EDW Optimization
technology: Apache Ambari, Apache Hive, Tableau
release: hdp-2.6.0
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Hello World, HDP > Develop with Hadoop > Apache Hive
---


# Interactive SQL on Hadoop with Hive LLAP

## Introduction

**Hive LLAP** combines persistent query servers and intelligent in-memory caching to deliver blazing-fast SQL queries without sacrificing the scalability Hive and Hadoop are known for. This tutorial will show you how to try LLAP on your HDP Sandbox and experience its interactive performance firsthand using a BI tool of your choice (**Tableau** will be used in demo, but others will work as well).

![hive_llap_architecture](assets/hive_llap_architecture.png)

### Benefits of Hive LLAP include:

-   LLAP uses persistent query servers to avoid long startup times and deliver fast SQL.
-   LLAP shares its in-memory cache among all SQL users, maximizing the use of this scarce resource.
-   LLAP has fine-grained resource management and preemption, making it great for highly concurrent access across many users.
-   LLAP is 100% compatible with existing Hive SQL and Hive tools.

## Goals and Objectives

The goal of this tutorial is to learn how to enable interactive SQL query performance on the HDP Sandbox using **LLAP**, then to connect a BI tool to LLAP and run interactive SQL analytics.

## Prerequisites

-   This tutorial requires [HDP Sandbox](https://hortonworks.com/downloads/#sandbox).
-   Must have installed [Hortonworks ODBC Driver for Apache Hive](https://hortonworks.com/downloads/#addons)
-   Must have installed [Tableau](https://www.tableau.com/). For this tutorial, we’re using Tableau version 10.2.
-   This tutorial assumes you have a **16GB** memory (or more) computer and does its best to maximize available resources. Working on the sandbox is limited. If you’re looking to try Hive LLAP at big data scales, check out [Fast Analytics in the Cloud with Hive LLAP](https://hortonworks.com/tutorial/fast-analytics-in-the-cloud-with-hive-llap/).
-   This tutorial requires making some configurations to the Sandbox and allocating additional resources. In order to run this tutorial you will need to be able to allocate **11 GB RAM** to the Sandbox virtual machine.
-   If you are not familiar with HDP Sandbox, the following tutorial provides an introduction:
[Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)

## Outline

- [1. Hive LLAP Sandbox Setup](#hive_llap_sandbox_setup)
- [2. Connect with a BI Tool and Run Queries](#connect_with_bi_tool)
- [3. Connect LLAP to the Large Dataset (Optional, Advanced)](#connect_llap)
- [4. Enhanced Monitoring for Hive and LLAP](#enhanced_monitoring)
- [Further Reading](#further-reading)

## 1. Hive LLAP Sandbox Setup <a id="hive_llap_sandbox_setup"></a>

### Increase Sandbox Memory Size

To benefit from Hive LLAP’s in-memory processing we need a bit more memory than the Sandbox offers by default. In this tutorial we’ll use **11 GB** of RAM.

When you import the Sandbox in VirtualBox, change the Appliance settings to increase RAM from 8192 to **11264 MB**. When you first select the appliance to import you will see a screen similar to this one:

![import_appliance](assets/import_appliance.png)

-   click on **Import**
-   When import completes, start it by double-clicking the appliance.

### Enable Ambari Admin Login

We need to change the Sandbox configuration using Ambari to enable LLAP. This requires us to first [reset Ambari admin password](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#setup-ambari-admin-password) and then logon.

> NOTE: Confirm you can log into Ambari as **admin** before continuing.

### Generate a Larger Dataset to Analyze (Optional)

The Sandbox ships with a few small tables, but to get a more substantial feel of LLAP we can generate a larger dataset. This part is optional and if you’re in a hurry you can skip it. For this demo we will generate 2 GB of data based on the standard TPC-H benchmark. To simplify things, all data generation and loading are handled by a single bundle you can download and run on your Sandbox.

To get started, [log into the console](http://127.0.0.1:4200/), then follow these steps:

1\. Log in to the console as root.

2\. Become the hive user:

~~~
su - hive
~~~

3\. Download the data generator bundle:

~~~
wget  https://github.com/cartershanklin/sandbox-datagen/raw/master/datagen.tgz
~~~

4\. Extract the bundle:

~~~
tar -zxf datagen.tgz
~~~

5\. Enter the datagen directory:

~~~
cd datagen
~~~

6\. Generate the data:

~~~
sh datagen.sh 2
~~~

This step will take up to a few minutes.

### Stop Services We Don’t Need

Ambari enables a number of HDP services we don’t need to try Hive LLAP. Since LLAP relies heavily on caching and in-memory processing we will stop these to free memory to improve performance.

When you first login you will see these services. If the services show up as yellow rather than green, wait a moment until you see green checkmarks next to these services.

![initial_services](assets/initial_services.png)

To free up a bit more resources, let's stop the following services that are not needed for this tutorial:

-   Oozie
-   Flume
-   Zeppelin Notebook.

For every service (i.e. Oozie):

1\.  Select **Service Actions**, then select **Stop**

![service_actions](assets/service_actions.png)

2\.  Select **Turn On Maintenance Mode** for the serice you are stopping.

![final_services](assets/final_services.png)

### Increase YARN Memory in Ambari

We need to make sure we have sufficient memory in **YARN** to take advantage of Hive LLAP in-memory processing.

-   select **YARN** -> **Configs** -> **Setings**
-   set "Minimum Container Size (memory)" to **512 MB**
-   set "Maximum Container Size (memory)" to **4096 MB**

![yarn_memory](assets/yarn_memory.png)

-   Select **Save**
-   Confirm Dependent Configurations by pressing **OK**
-   Confirm Configurations by pressing **Proceed Anyway**

> Important: Must restart YARN before continuing. **Restart** -> **Restart All Affected**.

### Enable and Configure Interactive Query (Hive LLAP)

Enabling Hive LLAP is a simple and require the following modifications. Start with **Ambari** -> **Hive** -> **Configs** -> **Settings**:

1.  Set **Enable Interactive Query** to **Yes**
2.  Set **ACID Transactions** to **On**

![enable_interactive_query](assets/enable_interactive_query.png)

-   Select **Save**
-   Accept the default location to install HiveServer2 Interactive
-   Confirm Dependent Configurations by pressing **OK**
-   Confirm Configurations by pressing **Proceed Anyway**

> Important: HiveServer2 Interactive will automatically start. Restart any other affected services. Wait for all services to restart before continuing.

## 2. Connect with a BI Tool and Run Queries <a id="connect_with_bi_tool"></a>

Now we’re ready to connect a BI Tool to LLAP and try things out. This demo will use Tableau. If you prefer another tool you should adapt these instructions to your choice.

### Download and Install the ODBC driver

As a prerequisite, you should already have installed the latest [Hortonworks ODBC Driver for Apache Hive](https://hortonworks.com/downloads/#addons).

If you are on Windows: Create a DSN using the ODBC Driver Manager and point it to host `127.0.0.1`, port 10500, use Username/Password authentication with the credentials `hive/hive`.

![odbc_driver_setup](assets/odbc_driver_setup.png)

> **If you are on Mac**: Note that connecting using Tableau does not require the use of an ODBC Driver Manager, the driver will be loaded automatically. Other BI tools may require the use of an ODBC Driver Manager.

### Connect Tableau to LLAP and a Small Dataset

Start Tableau, connect “To a server” -> More Servers -> Hortonworks Hadoop Hive

![connect_tableau](assets/connect_tableau.png)

When prompted, connect using:

-   Server: **127.0.0.1**
-   Port: **10500**
-   Type: **HiveServer2**
-   Authentication: **User Name and Password**
-   Transport: **SASL**
-   Username: **hive**
-   Password: **hive**

![hortonworks_hive_connection](assets/hortonworks_hive_connection.png)

Next click `Select Schema` and click the magnifying glass to show available schema.

![select_schema](assets/select_schema.png)

Select `foodmart` and click the magnifying glass to reveal all tables.

![select_foodmart](assets/select_foodmart.png)

-   Drag **sales_fact_dec_1998** to the workspace.
-   Drag **product** to the workspace.

The model should look like this:

![model](assets/model.png)

Click on **Sheet 1** to work on new worksheet.

![sheet1](assets/sheet1.png)

The model we've created will help us visualize products that produced the most sales. We can explore this data interactively. Let’s create a horizontal bar graph as described below:

![bar_chart](assets/bar_chart.png)

To reproduce this chart:

1\. Drag the **Product Name** from Dimensions to the Rows shelf ![rows_icon](assets/rows_icon.png).

2\. Drag the **Product Name** from Dimensions to the Color icon ![color_icon](assets/color_icon.png).

3\. Drag the **Store Sales** from Measures to the Columns shelf ![columns_icon](assets/columns_icon.png).

4\. Drag the **Store Sales** from Measures to Filters ![](assets/icon_Filters.png).

-   Select **Sum**, then press Next.
-   Set `Range of values` between 1450 and 1600.
-   Select **Show filter**

![show_filter](assets/show_filter.png)

5\. Drag the **Store Sales** from Measures to the label icon ![icon_label](assets/icon_label.png).

6\. Save worksheet as `Top Products`.

The result should look like:

![top_product](assets/top_product.png)

Your visualization should now look like the diagram above. You can continue to explore this dataset interactively if you want. For example, you can adjust the **SUM(Store Sales) slider** to interactively modify which sales you want to see.

## 3. Connect LLAP to the Large Dataset (Optional, Advanced) <a id="connect_llap"></a>

If you generated the large dataset above, here’s how to load it into Tableau and explore it. The data schema has a total of 8 tables and it’s important to relate them correctly. Each BI tool will have its own way of doing that, and here we’ll talk about how to do that in Tableau.

First we optimize the dataset for analytics. This means 3 things:

1\. We convert the data to ORCFile format.

2\. Generate statistics.

3\. We create primary and foreign keys for the dataset. This allows BI tools to do what’s called “join elimination” to greatly improve performance.

To load the data, navigate back to `http://127.0.0.1:4200/` and run:

~~~
su - hive
cd datagen
sh load_data.sh
~~~

This process will take a couple of minutes. After it’s complete, connect Tableau to the llap schema and show all tables.

![llap_schema](assets/llap_schema.png)

There are 8 total tables here and for a realistic experience we should load all of them with the appropriate associations. Here’s the load order and associations you should make:

1.  drag `lineitem` table
   -  no join condition needed
2.  drag `orders` table
   - join condition: `L_Orderkey = O_Orderkey`
3. drag `customer` table
   - join condition: `O_Custkey = C_Custkey`
4.  drag `nation` table
   - join condition: `C_Nationkey = N_Nationkey`
5.  drag `region` table
   - join condition: `N_Regionkey = R_Regionkey`
6.  drag `partsupp` table
   - join condition: `L_Suppkey = Ps_Suppkey`
   - join condition: `L_Partkey = Ps_Partkey`
7.  drag `part` table
   - join condition: `Ps_Partkey = P_Partkey`
8.  drag `supplier` table
   - join condition: `Ps_Suppkey = S_Suppkey`

It is important to ensure these join conditions are established properly. If they aren’t, queries will run very slow. When you’re done, the table associations should look like this:

![table_association](assets/table_association.png)

At this point it’s a good idea to save your workbook to avoid having to do this again.

Click on an empty Sheet or create a new worksheet.

Here’s an example visualization you can do with this data:

-   Drag **L_Extendedprice** from lineitem Measure to the bottom right of the workspace.
-   Drag **L_Shipinstruct** from lineitem Dimension to the Columns shelf
-   Drag **L_Shipmode** from lineitem Dimension to the Rows shelf.

When you’re done you should see a table like this:

![shipinstruct_shipmode](assets/shipinstruct_shipmode.png)

As you’re interacting, these queries should take no longer than about 5 seconds on a system with adequate resources. If queries are taking longer, ensure the join conditions are set up properly, ensure you are using the latest ODBC driver and ensure the settings given above have all been applied. You can also use the Tez UI (covered below) to further diagnose queries.

## 4. Enhanced Monitoring for Hive and LLAP <a id="enhanced_monitoring"></a>

HDP includes some nice new ways to debug and diagnose Hive and Tez jobs.

First let’s look at the Tez View:

![click_tez_view](assets/click_tez_view.png)

Here you’ll see a screen that includes all the queries that have been run through Hive:

![tez_all_dags](assets/tez_all_dags.png)

If we drill into a particular query (DAG ID), we can see the exact query text that Tableau generated:

![tableau_generated_query](assets/tableau_generated_query.png)

This Tez View also includes a new Vertex Swimlane view for critical path analysis:

![tez_all_dags_vertex_swimlane](assets/tez_all_dags_vertex_swimlane.png)

## Further Reading

If you’re just getting started with Hive and want to learn about its SQL capabilities or data access options, see [Getting Started with Apache Hive](https://cwiki.apache.org/confluence/display/Hive/GettingStarted) on the wiki.

For a high-level overview of Hive 2, watch [Apache Hive 2.0: SQL Speed Scale](http://www.slideshare.net/HadoopSummit/apache-hive-20-sql-speed-scale).
