---
title: Data Reporting with Excel
---

# Hadoop Tutorial – Getting Started with HDP

## Data Reporting with Excel

## Introduction

This step is optional as it requires you to have Excel and Power View, however feel free to connect from any reporting tool to do a similar exercise.   In this section, we will use Microsoft Excel Professional Plus 2013 to access the refined data. We will be using the ODBC connection.

## Prerequisites

The tutorial is a part of series of hands on tutorial to get you started on HDP using Hortonworks sandbox. Please ensure you complete the prerequisites before proceeding with this tutorial.

-   Lab 0: (Hortonworks sandbox set up)
-   Lab 1: Loading sensor data into HDFS
-   Lab 2: Data Manipulation with Apache Hive
-   Lab 3: Use Pig to compute Driver Risk Factor/ Lab 4: Use Spark to compute Driver Risk Factor
-   Install and configure [Hortonworks ODBC Driver](http://hortonworks.com/downloads/#addons)
-   Allow yourself around half an hour to complete this tutorial.

## Outline

-   [Step 6.b.1: Access Data in Microsoft Excel](#step6.b.1)
-   [Step 6.b.2: Visualize Data with Microsoft Excel](#step6.b.2)
-   [Summary](#summary)
-   [Further Reading](#further-reading)

## Step 6.b.1: Access Data in Microsoft Excel <a id="step6.b.1"></a>

The [Hive ODBC driver](http://hortonworks.com/downloads/#addons) can be found at the Hortonworks Add-on page.  For [Windows ODBC driver setup](https://hortonworks.com/tutorial/how-to-install-and-configure-the-hortonworks-odbc-driver-on-windows-7/) follow these instructions. Open the ODBC connection manager and open the connection you setup up. It should look like this.

**For Windows users**:-

1) Open a new blank workbook. Select **Data > From Other Sources > From Microsoft Query**.

![open_query](assets/17_open_query.png)

2) On the Choose Data Source pop-up, select the Hortonworks ODBC data source you installed previously, then click **OK**.

The Hortonworks ODBC driver enables you to access Hortonworks data with Excel and other Business Intelligence (BI) applications that support ODBC.

![data_source](assets/18_choose_data_source.png)

 We will import the avg_mileage table.

3)  Accept the defaults for everything and click through till you hit the Finish button. After you click on Finish, Excel will send the data request over to Hadoop. It will take awhile for this to happen. When the data is returned it will ask you to place the data in the workbook. We want to be in cell \$A\$1 like this.

![Lab5_6](assets/Lab5_61.png)

4)  The data is placed you will see the avg_mileage table imported into your spreadsheet.

![Lab5_7](assets/Lab5_7.jpg)

## Step 6.b.2: Visualize Data with Microsoft Excel <a id="step6.b.2"></a>

1)  So now we are going to insert a Power View report. Follow this [link](https://support.office.com/en-us/article/Turn-on-Power-View-in-Excel-2016-for-Windows-f8fc21a6-08fc-407a-8a91-643fa848729a) to set up the Power View Report if you do not have it. This will create a new tab in your workbook with the data inserted in the Power View page.

![Lab5_14](assets/Lab5_14.jpg)

2)  Select the design tab at the top and then select a column chart and use the stacked column version in the drop down menu. This will give you a bar chart. Grab the lower right of the chart and stretch it out to the full pane. Close the filter tab and the chart will expand and look like this.

![Lab5_9](assets/Lab5_9.jpg)

3)  So to finish off the tutorial I am going to create a map of the events reported in the geolocation table. I will show you how you can build up the queries and create a map of the data on an ad hoc basis.

4)  For a map we need location information and a data point. Looking at the geolocation table I will simply plot the location of each of the events. I will need the driverid, city and state columns from this table. We know that the select statement will let me extract these columns. So to start off I can just create the select query in the Query Editor.

5) Query subset of geolocation columns

~~~
select driverid, city, state from geolocation;
~~~

![Lab5_10](assets/Lab5_10.png)

6)  After I execute the query I see what results are returned. In a more complex query you can easily make changes to the query at this point till you get the right results. So the results I get back look like this.

![Lab5_11](assets/Lab5_11.png)

7)  Since my results look fine I now need to capture the result in a table. So I will use the select statement as part of my CTAS (create table select as) pattern. I will call the table events and the query now looks like this.

**Create table avg_mileage from existing trucks_mileage data**

~~~
CREATE TABLE events
STORED AS ORC
AS
SELECT driverid, city, state FROM geolocation;
~~~

![Lab5_12](assets/Lab5_12.png)

8)  I can execute the query and the table events gets created. As we saw earlier I can go to Excel and import the table into a blank worksheet. The imported data will look like this.

![Lab5_13](assets/Lab5_13.jpg)

9)  Now I can insert the PowerView tab in the Excel workbook. To get a map I just select the Design tab at the top and select the Map button in the menu bar.

![Lab5_8](assets/Lab5_8.jpg)

10)  Make sure you have a network connection because Power View using Bing to do the geocoding which translates the city and state columns into map coordinates. If we just want to see where events took place we can uncheck the driverid. The finished map looks like this.

![Lab5_15](assets/Lab5_15.jpg)

## Summary

We’ve shown how the Hortonworks Data Platform (HDP) can store and analyze geolocation data. In addition I have shown you a few techniques on building your own queries. You can easily plot risk factor and miles per gallon as bar charts. I showed you the basics of creating maps. A good next step is to only plot certain types of events. Using the pattern I gave you it is pretty straightforward to extract the data and visualize it in Excel.

Congratulations on finishing a comprehensive series on Hadoop and HDP. By now you should have a good understanding on fundamentals of Hadoop and its related ecosystem such as Map Reduce, YARN, HDFS, Hive, Pig and Spark.

## Further Reading
As a Hadoop practitioner you can choose three basic personas to build upon your skill:

-   Hadoop Developer- [Click Here!](https://hortonworks.com/tutorials/#tuts-developers)
-   Hadoop Administrator-[Click Here!](https://hortonworks.com/tutorials/#tuts-admins)
-   Data Scientist- [Click Here!](https://hortonworks.com/tutorials/#tuts-analysts)

**Case Studies**

Learn more about Hadoop through these case studies:

-   Analytics- [New types of data and new opportunities](https://hortonworks.com/solutions/advanced-analytic-apps/)
-   Data Architecture Optimization: [Reduce cost by moving data and processing to Hadoop](https://hortonworks.com/solutions/data-architecture-optimization/)
-   Industry specific: [Examples of Hadoop across Industries](https://hortonworks.com/industry/)
-   [The Definitive Guide by O`Reilly](http://hadoopbook.com/)
-   [Hadoop for Dummies](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118607554.html)
