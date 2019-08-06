---
title: Advanced Analytics With SparkR In Rstudio
author: sandbox-team
tutorial-id: 759
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Data Discovery
technology: Apache Spark, Apache SparkR, Machine Learning
release: hdp-3.0.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Apache Spark
---

# Advanced Analytics With SparkR In RStudio

## Introduction

R is a popular tool for statistics and data analysis. It has rich visualization capabilities and a large collection of libraries that have been developed and maintained by the R developer community. One drawback to R is that it’s designed to run on in-memory data, which makes it unsuitable for large datasets.

Spark is a distributed engine for processing many Terabytes of data. It is a versatile tool with capabilities for data processing, SQL analysis, streaming and machine learning. Because Spark is a distributed framework a Hortonworks cluster running Spark can process many Terabytes of data in a short amount of time.

SparkR combines the benefits of Spark and R by allowing Spark jobs to be called from within R. This allows the analyst to leverage Spark’s ability to build aggregate statistics over large, multi-Terabyte datasets and then bring the smaller aggregated data back into R for visualization and analysis.

In this tutorial we’ll show you how to leverage SparkR to gain insights on airline delays.

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/) to get used to Sandbox
- Follow this [article](https://community.hortonworks.com/articles/203564/installing-rstudio-on-hdp-sandbox.html) on Hortonworks Community to install RStudio on the Sandbox

## Outline

- [Download the Dataset](#download-the-dataset)
- [Setup SparkR on RStudio](#setup-sparkr-on-rstudio)
- [Prepare a Training Dataset](#prepare-a-training-dataset)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Download the Dataset

Every year approximately 20% of airline flights are delayed or cancelled, resulting in significant costs to both travelers and airlines. As our example use-case, we will build a supervised learning model that predicts airline delay from historical flight data. [Download the dataset from here](assets/airline_data.zip) and which includes details about flights in the US for 2015. Every row in the dataset has 16 attributes:

- Year
- Month
- Day of Month
- Day of Week
- Flight Number
- Origin
- Destination
- Departure Time
- Departure Delay
- Arrival Time
- Arrival Delay
- Cancelled
- Cancellation Code
- Air Time
- Distance

After you download the file, unzip it and upload train_df.csv and test_df.csv to the /tmp directory of HDFS using Files View. Open Ambari by going to [http://sandbox-hdp.hortonworks.com:8080](http://sandbox-hdp.hortonworks.com:8080) and use the credentials **amy_ds/amy_ds** to sign on. Once in Ambari, select “Files View” from the second menu in the upper right hand corner.

![amy-files-view](assets/amy-files-view.jpg)

Click on /tmp folder and upload these two files. Your screen should look like this:

![Files View 2](assets/fileView2.jpg)

## Setup SparkR on RStudio

Next, let us login to RStudio using credentials **amy_ds/amy_ds**. We have to create a SparkContext object which connects the R program to the cluster. You can create it using sparkR.init(). We also need a SqlContext object to work with data frames which can be created from SparkContext.

Let us start with creating an environment variable SPARK_HOME which has the location of Spark Libraries. We will load the SparkR package and we invoke sparkR.init() function to create SparkContext. We are also adding some Spark Driver properties and csv package so that the SparkR data frame can read csv files.

Type the following lines on RStudio console:

~~~r
Sys.setenv(SPARK_HOME = "/usr/hdp/current/spark2-client")
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
sc <- sparkR.session(master = "local[*]", sparkEnvir = list(spark.driver.memory="2g"),sparkPackages="com.databricks:spark-csv_2.10:1.4.0")
sqlContext <- sparkR.session()
~~~

![R1](assets/R1.png)

Press Enter

## Prepare a Training dataset

Before moving ahead, check out the SparkR [documentation](https://spark.apache.org/docs/2.3.1/api/R/index.html) to get used to SparkR API. You can either create a SparkR dataframe from the local R data frame or data sources in formats like csv or from Hive tables. We are going to use read.df() function to read the file from a data source (HDFS in our case), retain the schema and create the SparkR data frame. Type this line to create a dataframe taking the data from /tmp/train_df.csv file with headers included

~~~r
train_df <- read.df("/tmp/train_df.csv","csv", header = "true", inferSchema = "true")
~~~

After it gets loaded, you can view the dataframe by:

~~~r
head(train_df)
~~~

![R2](assets/R2.jpg)

It shows the top 6 records of the dataframe, you can also see the variables and the type of variables to the right side of the screen.

![R3](assets/R3.png)

Next, let us try to add some more columns to our dataframe to make the data more powerful and informative.

We will begin with deciding whether the following data is weekend or not. If it is weekend, enter 1 or else 0. The weekend starts from Friday and ends on Sunday. Enter the following:

~~~r
train_df$WEEKEND <- ifelse(train_df$DAY_OF_WEEK == 5 | train_df$DAY_OF_WEEK == 6 | train_df$DAY_OF_WEEK == 7,1,0)
~~~

It uses ifelse() function which checks whether the value of DAY_OF_WEEK variable is 5, 6 or 7 and adds the value(1,0) to the new column WEEKEND corresponding to that.

Next, create a new column called DEP_HOUR which will have extracted hour value from DEP_TIME column.

~~~r
train_df$DEP_HOUR <- floor(train_df$DEP_TIME/100)
~~~

Now, let us introduce one more column called DELAY_LABELED which has value 1 if the arrival delay(ARR_DELAY) is more than 15 minutes and 0 if ARR_DELAY is less than 15 minutes. That means all flights which are arrived 15 minutes delayed are considered to be delayed.

~~~r
train_df$DELAY_LABELED <- ifelse(train_df$ARR_DELAY > 15, 1, 0)
train_df$DELAY_LABELED <- cast(train_df$DELAY_LABELED,"integer")
~~~

We will keep only those flight records where it did not get cancelled. In the next statement, we are filtering out those records where the value of CANCELLED was 1

~~~r
train_df <- train_df[train_df$CANCELLED == 0,]
~~~

Next cleansing will be for NA values. After looking a dataset for a while, you will see that there are lot of NA values in ARR_DELAY column. We should keep only those where we have valid readings of ARR_DELAY.

~~~r
train_df <- dropna(train_df,cols = 'ARR_DELAY')
~~~

Next, if you want to know the datatype of columns in SparkR dataframe, just type

~~~r
printSchema(train_df)
~~~

You should see following console output:

![R4](assets/R4.png)

We should convert the type of ARR_DELAY and DEP_DELAY from string to integer so that we can perform mathematical operations on that.

~~~r
train_df$ARR_DELAY <- cast(train_df$ARR_DELAY,"integer")
train_df$DEP_DELAY <- cast(train_df$DEP_DELAY,"integer")
~~~

Type the command below to view the prepared dataframe:

~~~r
head(train_df)
~~~

![R5](assets/R5.png)

## Exploratory Data Analysis

At the end of this tutorial, we will be able to predict which flight is likely to be delayed. We can classify our dataset into two values- 0 or 1 (0 for flights on time and 1 for flights delayed). But before creating a model, let us visualize the data what we have right now.

We create a new dataframe called delay which will have two columns, DELAY_LABELED and the count of it. Basically it will have a count of delayed flights and ontime flights. We will be using aggregate function of SparkR where we group the dataframe by DELAY_LABELED and calculating the count using n().

~~~r
delay <- agg(group_by(train_df, train_df$DELAY_LABELED), count = n(train_df$DELAY_LABELED))
~~~

Introduce a new column called STATUS which will have value ontime if DELAY_LABELED is 0 and delayed if DELAY_LABELED is 1.

~~~r
delay$STATUS <- ifelse(delay$DELAY_LABELED == 0, "ontime", "delayed")
~~~

Delete a first column DELAY_LABELED because we do not need it anymore.

~~~r
delay <- delay[,-1]
~~~

Next, let us convert this SparkR dataframe to R dataframe using as.data.frame() function to visualize it using ggplot, let us call this new dataframe delay_r.

~~~r
delay_r <- as.data.frame(delay)
~~~

Add Percentage as one more column to this new dataframe.

~~~r
delay_r$Percentage <- (delay_r$count / sum(delay_r$count)) * 100
delay_r$Percentage <- round(delay_r$Percentage,2)
~~~

View the dataframe:

~~~r
head(delay_r)
~~~

![R6](assets/R6.png)

Next, install and import the package called ggplot2. ggplot2 is a plotting system for R based on the grammar of graphics. You can plot graphs like bar chart, stacked bar chart, line chart, pie chart, scatter plot and histograms.

~~~r
install.packages("ggplot2")
library(ggplot2)
~~~

Wait for it to get completed. Create a blank theme to delete the axis titles and ticks and setting the size for plot title.

~~~r
blank_theme <- theme_minimal()+
    theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_blank(),
        panel.grid=element_blank(),
        axis.ticks = element_blank(),
        plot.title=element_text(size=14, face="bold")
    )
~~~

We will draw a pie chart showing the percentage of delayed and ontime flights.

~~~r
ggplot(delay_r, aes(x="",y=Percentage,fill=STATUS)) + geom_bar(stat="identity",width=1,colour="green") + coord_polar(theta="y",start=0) + blank_theme + ggtitle("Pie Chart for Flights") + theme(axis.text.x=element_blank()) + geom_text(aes(y = Percentage/2,label = paste0(Percentage,"%"),hjust=2))
~~~

![R7](assets/R7.png)

Click on Zoom at the top of the chart to have a clearer view.

This graph shows that around 18.17% flights are getting delayed which is a very big figure.

Let us explore what effect Day_Of_Week has on the dataset. We will create two new dataframes called delay_flights and non_delay_flights which will have details for delayed and ontime flights respectively.

~~~r
delay_flights <- filter(train_df,train_df$DELAY_LABELED == 1)
non_delay_flights <- filter(train_df,train_df$DELAY_LABELED == 0)
~~~

Next, we will find the count of delayed and ontime flights grouped by Day_Of_Week.

~~~r
delay_flights_count <- agg(group_by(delay_flights,delay_flights$DAY_OF_WEEK), DELAY_COUNT = n(delay_flights$DELAY_LABELED))
non_delay_flights_count <- agg(group_by(non_delay_flights,non_delay_flights$DAY_OF_WEEK), NON_DELAY_COUNT = n(non_delay_flights$DELAY_LABELED))
~~~

Now, we can merge both delay_flights_count and non_delay_flights_count dataframes.

~~~r
dayofweek_count <- merge(delay_flights_count, non_delay_flights_count, by.delay_flights_count = DAY_OF_WEEK, by.non_delay_flights_count = DAY_OF_WEEK)
~~~

When you merge two dataframes, you get common column twice in the dataframe which is not required. Let us delete that by typing:

~~~r
dayofweek_count$DAY_OF_WEEK_y <- NULL
~~~

Rename the column using withColumnRenamed() function.

~~~r
dayofweek_count <- withColumnRenamed(dayofweek_count,"DAY_OF_WEEK_x","DAY_OF_WEEK")
~~~

Convert this SparkR Dataframe to R dataframe so that we can run visualization on it:

~~~r
dayofweek_count_r <- as.data.frame(dayofweek_count)
~~~

Let us view this new R dataframe:

~~~r
head(dayofweek_count_r)
~~~

![R8](assets/R8.png)

Introduce two columns, Delayed and Ontime, which have the percentage values for DELAY_COUNT and NON_DELAY_COUNT respectively.

~~~r
dayofweek_count_r$Delayed <- (dayofweek_count_r$DELAY_COUNT/(dayofweek_count_r$DELAY_COUNT+dayofweek_count_r$NON_DELAY_COUNT)) * 100
dayofweek_count_r$Ontime <- (dayofweek_count_r$NON_DELAY_COUNT/(dayofweek_count_r$DELAY_COUNT+dayofweek_count_r$NON_DELAY_COUNT)) * 100
dayofweek_count_r <- dayofweek_count_r[,-2:-3]
~~~

Next, add one more column which represents the ratio of delayed flights against ontime flights.

~~~r
dayofweek_count_r$Ratio <- dayofweek_count_r$Delayed/dayofweek_count_r$Ontime * 100
dayofweek_count_r$Ratio <- round(dayofweek_count_r$Ratio,2)
~~~

Now, if you look closely, our data is in wide format. The data is said to be in wide format if there is one observation row per subject with each measurement present as a different variable. We have to change it to long format which means there is one observation row per measurement thus multiple rows per subject. In R, we use reshape to do this:

~~~r
library(reshape2)
DF1 <- melt(dayofweek_count_r, id.var="DAY_OF_WEEK")
DF1$Ratio <- DF1[15:21,3]
~~~

View this new long format dataframe:

~~~r
DF1
~~~

![R9](assets/R9.png)

We will change this dataframe just to make the plot clearer.

~~~r
DF1 <- DF1[-15:-21,]
DF1[8:14,4] <- NA
~~~

Next, run the following line to see the stacked bar chart:

~~~r
install.packages("ggrepel")
library(ggrepel)
ggplot(DF1, aes(x=DAY_OF_WEEK,y=value,fill=variable)) + geom_bar(stat="identity") + geom_path(aes(y=Ratio,color="Ratio of Delayed flights against Non Delayed Flights")) + geom_text_repel(aes(label=Ratio), size = 3) + ggtitle("Percentage of Flights Delayed") + labs(x="Day of Week",y="Percentage")
~~~

Click on Zoom button.

![R10](assets/R10.png)

As you can see here, most delays are happening on Monday and Thursday. It drops during the start of the weekend but again rises up by Sunday.

Now we will look over Destination effect on the delays,

Create two new dataframes from delay_flights and non_delay_flights  dataframes respectively which will have the count of flights specific to some Destinations like LAX, SFO, HNL, PDX.

~~~r
destination_delay_count <- agg(group_by(delay_flights,delay_flights$DEST), DELAY_COUNT = n(delay_flights$DELAY_LABELED))
destination_delay_count <- destination_delay_count[(destination_delay_count$DEST == "LAX" | destination_delay_count$DEST == "SFO" | destination_delay_count$DEST == "HNL" | destination_delay_count$DEST == "PDX") ,]

destination_non_delay_count <- agg(group_by(non_delay_flights,non_delay_flights$DEST), NON_DELAY_COUNT = n(non_delay_flights$DELAY_LABELED))
destination_non_delay_count <- destination_non_delay_count[(destination_non_delay_count$DEST == "LAX" | destination_non_delay_count$DEST == "SFO") | destination_delay_count$DEST == "HNL" | destination_delay_count$DEST == "PDX" ,]

~~~

Lets merge these two new dataframes into one.

~~~r
destination_count <- merge(destination_delay_count, destination_non_delay_count, by.destination_delay_count = DEST, by.destination_non_delay_count = DEST)
destination_count$DEST_y <- NULL
destination_count <- withColumnRenamed(destination_count,"DEST_x","DEST")
~~~

And convert it into R Dataframe.

~~~r
destination_count_r <- as.data.frame(destination_count)
~~~

Bring up two new columns(Delayed and Ontime) which has the percentage values

~~~r
destination_count_r$Delayed <- (destination_count_r$DELAY_COUNT/(destination_count_r$DELAY_COUNT+destination_count_r$NON_DELAY_COUNT)) * 100
destination_count_r$Ontime <- (destination_count_r$NON_DELAY_COUNT/(destination_count_r$DELAY_COUNT+destination_count_r$NON_DELAY_COUNT)) * 100
destination_count_r <- destination_count_r[,-2:-3]
~~~

Introduce one more column called Ratio which has the proportion of delayed flights against ontime flights on the four aforementioned destinations

~~~r
destination_count_r$Ratio <- destination_count_r$Delayed/destination_count_r$Ontime * 100
destination_count_r$Ratio <- round(destination_count_r$Ratio,2)
~~~

As earlier, let us melt down this dataframe too to create a stacked bar chart. Use melt function of reshape package.

~~~r
DF2 <- melt(destination_count_r, id.var="DEST")
DF2$Ratio <- DF2[9:12,3]
DF2 <- DF2[-9:-12,]
DF2[5:8,4] <- NA
~~~

Draw a stacked bar chart:

~~~r
ggplot(DF2, aes(x=DEST,y=value,fill=variable)) + geom_bar(stat="identity") + geom_path(aes(y=Ratio,color="Ratio of Delayed flights against Non Delayed Flights"),group = 1) + geom_text_repel(aes(label=Ratio), size = 3) + ggtitle("Percentage of Flights Delayed by Destination") + labs(x="Destinations",y="Percentage")
~~~

![R11](assets/R11.png)

Looks like smaller city Destination has the most delayed ratio. Let us do the same thing with Origins also. Create two new dataframes having records only where Origins are SNA, ORD, JFK and IAH.

~~~r
origin_delay_count <- agg(group_by(delay_flights,delay_flights$ORIGIN), DELAY_COUNT = n(delay_flights$DELAY_LABELED))
origin_delay_count <- origin_delay_count[(origin_delay_count$ORIGIN == "SNA" | origin_delay_count$ORIGIN == "ORD" | origin_delay_count$ORIGIN == "JFK" | origin_delay_count$ORIGIN == "IAH") ,]
origin_non_delay_count <- agg(group_by(non_delay_flights,non_delay_flights$ORIGIN), NON_DELAY_COUNT = n(non_delay_flights$DELAY_LABELED))
origin_non_delay_count <- origin_non_delay_count[(origin_non_delay_count$ORIGIN == "SNA" | origin_non_delay_count$ORIGIN == "ORD" | origin_delay_count$ORIGIN == "JFK" | origin_delay_count$ORIGIN == "IAH") ,]
~~~

Merge dataframes by using merge function of SparkR API and convert it into R Dataframe:

~~~r
origin_count <- merge(origin_delay_count, origin_non_delay_count, by.origin_delay_count = ORIGIN, by.origin_non_delay_count = ORIGIN)
origin_count$ORIGIN_y <- NULL
origin_count <- withColumnRenamed(origin_count,"ORIGIN_x","ORIGIN")
origin_count_r <- as.data.frame(origin_count)
~~~

Add three columns - Delayed(Percentage), Ontime(Percentage) and Ratio(Delayed/Ontime)

~~~r
origin_count_r$Delayed <- (origin_count_r$DELAY_COUNT/(origin_count_r$DELAY_COUNT+origin_count_r$NON_DELAY_COUNT)) * 100
origin_count_r$Ontime <- (origin_count_r$NON_DELAY_COUNT/(origin_count_r$DELAY_COUNT+origin_count_r$NON_DELAY_COUNT)) * 100
origin_count_r <- origin_count_r[,-2:-3]
origin_count_r$Ratio <- origin_count_r$Delayed/origin_count_r$Ontime * 100
origin_count_r$Ratio <- round(origin_count_r$Ratio,2)
~~~

As earlier, make the dataframe in long format using melt() and draw the stacked bar chart:

~~~r
DF3 <- melt(origin_count_r, id.var="ORIGIN")
DF3$Ratio <- DF3[9:12,3]
DF3 <- DF3[-9:-12,]
DF3[5:8,4] <- NA

ggplot(DF3, aes(x=ORIGIN,y=value,fill=variable)) + geom_bar(stat="identity") + geom_path(aes(y=Ratio,color="Ratio of Delayed flights against Non Delayed Flights"),group = 1) + geom_text_repel(aes(label=Ratio), size = 3) + ggtitle("Percentage of Flights Delayed by Origin") + labs(x="Origins",y="Percentage")
~~~

![R12](assets/R12.png)

As you can see here, smaller city Origin(SNA) has a least delay ratio.

## Summary

Congratulations, you now know how to use SparkR to explore, transform, and visualize data to gain valuable insight. In the future we will expand this tutorial with prediction steps leveraging several popular supervised learning models.

## Further reading

If you want to learn more about using Apache Spark for machine learning and processing large datasets please check out these tutorials and videos:

- [Hands-On Tour of Apache Spark in 5 Minutes](https://hortonworks.com/tutorial/hands-on-tour-of-apache-spark-in-5-minutes/)
- [Intro to Machine Learning with Spark](https://hortonworks.com/tutorial/intro-to-machine-learning-with-apache-spark-and-apache-zeppelin/)
- [Data Science Starter Kit](https://hortonworks.com/info/data-science-cloud/)
- [Installing RStudio on HDP Sandbox](https://community.hortonworks.com/articles/203564/installing-rstudio-on-hdp-sandbox.html)
