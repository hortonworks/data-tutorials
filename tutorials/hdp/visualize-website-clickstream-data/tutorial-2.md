---
title: Visualize Log Data with Microsoft Excel
---

# Visualize Log Data with Microsoft Excel

## Introduction

In this section, we will use Microsoft Excel to access refined clickstream data.

## Prerequisites

- Have installed the [Hortonworks ODBC driver for Apache Hive](https://hortonworks.com/downloads/#addons) (check [Getting Started with HDP Tutorial](https://hortonworks.com/tutorial/hadoop-tutorial-getting-started-with-hdp/section/7/) for help with installation)
- Have sample retail data already loaded [by completing this tutorial](https://hortonworks.com/tutorial/loading-data-into-the-hortonworks-sandbox)
- Have a version of Excel with Power View (i.e. Excel 2013), which is currently only offered for Windows computers.

## Outline

- [Import Data From Apache Hive](#import-data-from-apache-hive)
- [Visualize Data Using Power View](#visualize-data-using-power-view)
- [Summary](#summary)

## Import Data From Apache Hive

Open a new Excel workbook, then navigate to **Data > From Other Sources > From Microsoft Query**.

![From Microsoft Query](assets/excel-open-query.jpg)

On the Choose Data Source pop-up, select the Hortonworks ODBC data source you installed, then click **OK**. The Hortonworks ODBC driver enables you to access Hortonworks data with Excel and other Business Intelligence (BI) applications that support ODBC.

![Choose Data Source](assets/excel-choose-data-source.jpg)

After the connection to the sandbox is established, the **Query Wizard** appears. Select the `webloganalytics` table in the **Available tables and columns** box, then click the right arrow button to add the entire `webloganalytics` table to the query. Click **Next** to continue.

![Query Wizard 1](assets/excel-query-wizard-1.jpg)

On the **Filter Data** screen, click **Next** to continue without filtering the data.

![Query Wizard 2](assets/excel-query-wizard-2.jpg)

On the **Sort Order** screen, click **Next** to continue without setting a sort order.

![Query Wizard 3](assets/excel-query-wizard-3.jpg)

Click **Finish** on the **Query Wizard Finish** screen to retrieve the query data from the sandbox and import it into Excel.

![Query Wizard 4](assets/excel-query-wizard-4.jpg)

On the **Import Data** dialog box, click **OK** to accept the default settings and import the data as a table.

![Import Data](assets/excel-import-data.jpg)

The imported query data appears in the Excel workbook.

![Data Imported](assets/excel-data-imported.jpg)

Now that we have successfully imported Hortonworks Sandbox data into Microsoft Excel, we can use Excel's Power View feature to analyze and visualize the data.

## Visualize Data Using Power View

Data visualization can help you optimize your website and convert more visits into sales and revenue. In this section we will:

- Analyze the clickstream data by location
- Filter the data by product category
- Graph the website user data by age and gender
- Pick a target customer segment
- Identify web pages with the highest bounce rates

In the Excel workbook with the imported webloganalytics data, select **Insert > Power View** to open a new Power View report.

![Open Power View](assets/excel-open-power-view.jpg)

The Power View Fields area appears on the right side of the window, with the data table displayed on the left. Drag the handles or click the Pop Out icon to maximize the size of the data table.

![Power View Initial Popup](assets/excel-power-view-initial-popup.jpg)

Let’s start by taking a look at the countries of origin of our website visitors. In the **Power View Fields** area, leave the **country** checkbox selected, and clear all of the other checkboxes. The data table will update to reflect the selections.

![Country Selected](assets/excel-country-selected.jpg)

On the **Design** tab in the top menu, click **Map**.

![Open Map](assets/excel-open-map.jpg)

The map view displays a global view of the data. Now let’s take a look at a count of IP address by state. First, drag the **ip** field into the SIZE box.

![Add IP Count](assets/excel-add-ip-count.jpg)

Drag **country** from the Power View Fields area into the Filters area, then select the **usa** checkbox.

![Filter by USA](assets/excel-filter-by-usa.jpg)

Next, drag **state** into the LOCATIONS box. Remove the **country** field from the LOCATIONS box by clicking the down-arrow and then **Remove Field**.

![State to Locations](assets/excel-state-to-locations.jpg)

Use the map controls to zoom in on the United States. Move the pointer over each state to display the IP count for that state.

![IP Count by State](assets/excel-ip-count-by-state.jpg)

Our dataset includes product data, so we can display the product categories viewed by website visitors in each state. To display product categories in the map by color, drag the **category** field into the COLOR box.

![Category by Color](assets/excel-category-by-color.jpg)

The map displays the product categories by color for each state. Move the pointer over each state to display detailed category information. We can see that the largest number of page hits in Florida were for clothing, followed by shoes.

![Category by Color Florida](assets/excel-category-by-color-florida.jpg)

Now let’s look at the clothing data by age and gender so we can optimize our content for these customers. Select **Insert > Power View** to open a new Power View report.

![New Power View](assets/excel-new-power-view.jpg)

To set up the data, set the following fields and filters:

- In the Power View Fields area, select **ip** and **age**. All of the other fields should be unselected.
- Drag **category** from the Power View Fields area into the Filters area, then select the **clothing** checkbox.
- Drag **gender** from the Power View Fields area into the Filters area, then select the **M** (male) checkbox.

After setting these fields and filters, select **Column Chart > Clustered Column** in the top menu.

![Open Clusted Column](assets/excel-open-clustered-column.jpg)

To finish setting up the chart, drag **age** into the AXIS box. Also, remove **ip** from the AXIS box by clicking the down-arrow and then **Remove Field**. The chart shows that the majority of men shopping for clothing on our website are between the ages of 22 and 30. With this information, we can optimize our content for this market segment.

![Clothing by Age](assets/excel-clothing-by-age.jpg)

Let’s assume that our data includes information about website pages (URLs) with high bounce rates. A page is considered to have a high bounce rate if it is the last page a user visited before leaving the website. By filtering this URL data by our target age group, we can find out exactly which website pages we should optimize for this market segment. Select **Insert > Power View** to open a new Power View report.

![New Power View 2](assets/excel-new-power-view-2.jpg)

To set up the data, set the following fields and filters:

- Drag **age** from the Power View Fields area into the Filters area, then drag the sliders to set the age range from 22 to 30.
- Drag **gender** from the Power View Fields area into the Filters area, then select the **M** (male) checkbox.
- Drag **country** from the Power View Fields area into the Filters area, then select the **usa** checkbox.
- In the Power View Fields area, select **url**. All of the other fields should be unselected.
- In the Power View Fields area, move the pointer over **url**, click the down-arrow, and then select **Add to Table as Count.**

After setting these fields and filters, select **Column Chart > Clustered Column** in the top menu.

![Open Clustered Column 2](assets/excel-open-clusted-column-2.jpg)

The chart shows that we should focus on optimizing four of our website pages for the market segment of men between the ages of 22 and 30. Now we can redesign these four pages and test the new designs based on our target demographic, thereby reducing the bounce rate and increasing customer retention and sales.

![URLs for Age Group](assets/excel-urls-for-age-group.jpg)

You can use the controls in the upper left corner of the map to sort by Count of URL in ascending order.

![URLs for Age Group Sorted](assets/excel-urls-for-age-group-sorted.jpg)

## Summary

You have successfully analyzed and visualized log data with Microsoft Excel.  This, and other BI tools can be used with the Hortonworks Data Platform to derive insights about customers from various data sources.

The data stored in the Hortonworks Data Platform can be refreshed frequently and used for basket analysis, A/B testing, personalized product recommendations, and other sales optimization activities.
