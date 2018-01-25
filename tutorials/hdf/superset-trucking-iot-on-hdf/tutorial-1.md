---
title: Superset in Trucking IoT Use Case
---

# Superset in Trucking IoT Use Case

## Outline

-   [The IoT Use Case](#the-iot-use-case)
-   [Why Data Visualization](#why-data-visualization)
-   [Principles of Effective Visualization](#principles-of-effective-visualization)
-   [Graphs Used to Communicate Messages about Data](#common-graphs-used-to-communicate-messages-about-data)
-   [Apply Human Perception to Design an Intuitive Graph](#apply-human-perception-to-Design-an-intuitive-graph)
-   [Terminology in Visualization](#terminology-in-visualization)
-   [History of Data Visualization](#history-of-data-visualization)
-   [Why Superset](#why-superset)
-   [Superset Terminology](#superset-terminology)
-   [Next: Superset in Action](#next-superset-in-action)

## The IoT Use Case

To learn more about the Trucking IoT Use Case, visit [The IoT Use Case Sub Section](https://hortonworks.com/hadoop-tutorial/trucking-iot-hdf/#the-iot-use-case) from the "Trucking IoT on HDF" tutorial.

What is Superset's role in the Trucking IoT Application?

- Visually predict truck breakdowns and visually analyze driver habits on separate maps all to prevent drivers from getting into accidents

## Why Data Visualization

Effective visualization makes complex data accessible, understandable and usable. Thus, users can analyze and make decisions about data that affect the people and environment around them, such as companies, schools, climate, renewable resources, etc.

## Principles of Effective Visualization

There are principles or **characteristics of effective graphical displays** that should be applied to visualizing data, so it is clearly and efficiently communicated to users:

- 1\.  Know your audience
- 2\.  Show data
- 3\.  Avoid distorting the message from data
- 4\.  Present several numbers in an acute space
- 5\.  Make large datasets clear
- 6\.  Make distinct parts of data viewable to the eyes
- 7\.  Serve a clear purpose: description, exploration, tabulation or decoration
- 8\.  Integrate statistical and verbal descriptions with the dataset
- 9\.  Persuade the user to concentrate on the data topic (substance) rather than the technology
- 10\. Design graphics that are intuitive without any extra explanation from a report
- 11\. Design graphics that demonstrate the key message of the data

By applying these principles, you prevent creating misleading graphs, so the **message** from the dataset is accurately revealed to the user.

## Common Graphs Used to Communicate Messages about Data

As you experiment with ways to effectively visualize data, graphs you may want to utilize to communicate quantitative **messages** about your use case (Trucking IoT) include:

> Note: **try to make all the examples relate to the trucking iot dataset**

- 1\. Time Series: Single captured over a period of time.
    - **Ex:** _Line Chart_ can show the congestion level on a particular route over the span of weekdays, months, years, etc. The following line chart illustrates this information.

![time-series](assets/time-series.png)

- 2\. Ranking: Categorical subdivisions ranked in ascending or descending order.
    - **Ex:** _Bar Chart_ can rank in ascending order traffic congestion level (the measure) by route (the category) during a single period. The following bar chart illustrates this information.

![ranking](assets/ranking.png)

- 3\. Part-to-whole: Categorical subdivisions measured as a ratio to the whole (percentage of 100%).
    - **Ex:** _Pie Chart or Bar Chart_ can show the percentage of violation events by truck drivers: **Lane Departure**, **Unsafe Follow Distance**, **Speeding**, **Unsafe Tail Distance** as a ratio to the whole. The following pie chart illustrates this information.

![part-to-whole](assets/part-to-whole.png)

- 4\. Deviation: Categorical subdivisions compared against a reference.
    - **Ex:** _Bar Chart_ can show the actual vs budget expenses for several business departments over a time period.

- 5\. Frequency Distribution: Shows the observations of a variable for a given interval.
    - **Ex:** _Histogram or/and Box Plot_
        - _Histogram_ can show the traffic congestion levels in the data for `Des Moines to Chicago` and `Saint Louis to Chicago` during foggy, windy or rainy day. The following histogram illustrates this information.
        - _Box Plot_ can visualize the statistics about the traffic congestion levels on these routes: median, quartiles, outliers, etc.

![histogram-freq-dist](assets/histogram-freq-dist.png)

- 6\. Correlation: Comparison between two variables (x,y) to determine if they move in the same or opposite directions.
    - **Ex:** _Scatterplot_ can plot unemployment (x) and inflation (y) for a sample of months.

- 7\. Geographical or Geospatial: Comparison of a variable across a map or layout.
    - **Ex:** _Cartogram_ can show the number of persons on various floors of a building.

As you experiment with ways to visualize data to communicate meaningful messages and correlations, you will dabble into **Exploratory Data Analysis**, which is providing insight about the dataset through trial and error.

## Apply Human Perception to Design an Intuitive Graph

Human perception and cognition knowledge is essential for communicating the **message** you want to get across from the graph because all visualizations are created for human consumption. Human perception is the way humans visually process information. Thus, human visual processing involves detecting changes and making comparisons between quantities, sizes, shapes and variations in lightness. As long as **properties of symbolic data** are mapped to **visual properties represented by that data**, humans are able to browse through large volumes of data efficiently. Hence, data visualization allows the user to perform data explorations.

## Terminology in Visualization

These terms origin is from Statistics, there are **two types of data** that every Data Visualization Engineer/Scientist should be familiar with:

- 1\. Categorical: The nature of data is described by text labels, often will be seen in qualitative (non-numerical) data.
    - **Ex:** Age, Name

- 2\. Quantitative: Numerical measures.
    - **Ex:** "25" denotes the age in years

There are also **two main information display types**:

- 1\. Table: Rows and Columns that contain quantitative data with categorical labels. Mainly for looking up values.
    - Categorical columns may contain qualitative or quantitative data
    - Rows represent one unique sample with attributes, such as a person

- 2\. Graph: Shows the relationships among data and portrays values encoded as visual objects
    - **Ex:** lines, bars, points

## History of Data Visualization

The first documented trace of data visualization was a **Turin Papyrus Map** and can be tracked back to 1160BC. Maps illustrate information about the location of geological resources and how to extract those resources. Maps also can show a **thematic cartography**, which is a geographical illustration designed to show a theme connected with a specific geographic area. People have also found different forms of data visualization through cave wall drawings and physical artifacts from Mesopotamian, Inca and other indigenous groups.

The invention of paper and parchment was a major breakthrough for allowing further development of visualizations. In the 16th century, techniques and instruments were developed for accurately measuring physical quantities, geographic and celestial positions. With the development of **analytic geometry** and **two-dimensional coordinate system** by Rene Descartes and Pierre de Fermat, they have influenced the methods we use to display and calculate data values.

Fermat teamed up with Blaise Pascal and their work on **statistics and probability theory** laid the foundation for what conceptualize as data. John Tukey and Edward Tufte's work in refining data visualization techniques allowed for this field to be inhabited by more than just the people in the Statistics field. As this technology progressed, hand-drawn visualizations evolve into software visualizations. Software visualization applications have the ability to visualize in 2D, 3D, virtually reality and augmented reality. There are a wide range of programs for visualization that have been developed: Tableau, Zeppelin, AtScale, R, Python, **Superset**.

## Why Superset

Superset has an easy to use interface for exploring and visualizing data with integration for various databases (we'll use Druid). Superset has a rich set of visualizations and gives the user the ability to create dashboards to categorize your data tables. Superset also allows users to create visualization slices, which represent the actual visualization of the data table, and select the appropriate dashboard for your slice. Superset is enterprise-ready, extensible and has a high granularity security/permission model that allows intricate rules on who can access individual features and the dataset.

## Superset Terminology

- 1\. Sources: allows users to view databases, tables, druid clusters, druid datasources and

- 2\. Slices: graphical representations of the druid datasources that deliver a particular message about the data in the table to the customer

- 3\. Dashboards: group visualization slices together into particular categories, such as Trucking IoT, Weather IoT, Agriculture IoT, etc.

## Next: Superset in Action

We're now familiar with how Apache Superset ties into our Trucking IoT Application, let's see Superset in action and create some visualization slices of our data.
