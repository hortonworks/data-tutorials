---
title: Analyze IoT Weather Station Data via Connected Data Architecture
tutorial-id: 820
platform: hdp-2.6.0
tags: [nifi, minifi, raspberry pi, connected data architecture, hbase, iot, weather]
---

# Visually Monitor Weather Data with Zeppelin's Phoenix Interpreter

## Introduction

You'll use Phoenix to perform SQL queries against the HBase table by mapping a phoenix table to HBase table. You'll visualize your results by running Phoenix in Zeppelin via the Phoenix Interpreter. You'll monitor temperature, humidity and barometric pressure readings via Line Graphs, Bar Graphs, Pie Charts and Map Visualization.

## Prerequisites

- Completed **Store Data into HDP HBase**

## Outline

- Step 1: Create Zeppelin Notebook
- Step 2: Create Phoenix Table Mapping to HBase Table
- Step 3: Monitor Sense HAT Weather Data
- Step 4: Visualize Weather Readings on a Map
- Summary
- Further Readings

### Step 1: Create Zeppelin Notebook

Select notebook next to the Zeppelin icon, and hit “Create new note” to create the Zeppelin Notebook. Name it `Visualize Weather Data with Phoenix SQL`.

### Step 2: Create Phoenix Table Mapping to HBase Table

We must create a phoenix table to map to our HBase table in order to perform SQL queries against HBase. Write or Copy/Paste the following query in the Zeppelin editor.

~~~SQL
%jdbc(phoenix)
CREATE TABLE IF NOT EXISTS "sensor_readings" ("row" VARCHAR primary key,"weather"."Sensor_ID" VARCHAR, "weather"."Time" VARCHAR, "weather"."Public_IP.geo.city" VARCHAR, "weather"."Public_IP.geo.subdivision.isocode.0" VARCHAR, "weather"."Temp_C" VARCHAR,
"weather"."Pressure_Pa" VARCHAR,"weather"."Sealevel_Pressure_Pa" VARCHAR,"weather"."Altitude_m" VARCHAR)
~~~

Run quick test to verify Phoenix table successfully mapped to HBase table.

Display the first 10 rows of the Phoenix table.

~~~SQL
%jdbc(phoenix)
select * from "sensor_readings" limit 10
~~~

### Step 3: Monitor Sense HAT Weather Data

### 3.1 Monitor AVG, MIN, MAX for Temperature in Table View

Perform Aggregate functions to find the AVG, MIN and MAX temperature out of all the records in our Phoenix table.

~~~SQL
%jdbc(phoenix)
select COUNT("Temp_C") AS COUNT_TEMP,
AVG(TO_NUMBER("Temp_C")) AS MEAN_TEMP,
MIN("Temp_C") AS MIN_TEMP,
MAX("Temp_C") AS MAX_TEMP
from "sensor_readings" where TO_NUMBER("Sensor_ID") = 1
~~~

**Visualize in temperature table**

### 3.2 Monitor AVG, MIN, MAX for Pressure in Table View

**Pressure**

~~~SQL
%jdbc(phoenix)
select COUNT("Pressure_Pa") AS COUNT_P,
AVG(TO_NUMBER("Pressure_Pa")) AS MEAN_P,
MIN("Pressure_Pa") AS MIN_P,
MAX("Pressure_Pa") AS MAX_P
from "sensor_readings" where TO_NUMBER("Sensor_ID") = 1
~~~

**Visualize in pressure table**


### 3.3 Monitor AVG for Temp, Pressure in Table View

~~~SQL
%jdbc(phoenix)
select AVG(TO_NUMBER("Temp_C")) AS MEAN_TEMP,
AVG(TO_NUMBER("Pressure_Pa")) AS MEAN_P
from "sensor_readings" where TO_NUMBER("Sensor_ID") = 1
~~~

**Visualize Sense HAT Weather Readings in table**

### 3.4 Monitor MIN Pressure per Hour in Line Graph

Let’s add line graph to visualize the Pressure across 4 hours. We will show the MIN pressure at each hour and the city of the recording.

~~~SQL
%jdbc(phoenix)
select
"Public_IP.geo.city", HOUR(TO_TIMESTAMP("Time")) AS HOUR, MIN("Pressure_Pa") AS MIN_PRESSURE
from "sensor_readings"
where TO_NUMBER("Pressure_Pa") > 101000 AND TO_NUMBER("Pressure_Pa") <= 103000
group by "Public_IP.geo.city", HOUR
order by HOUR
~~~

Analysis of the Line Graph: The MIN pressure at HOUR 16 in Fremont was 101,776 and at HOUR 19 in Fremont was 101,832.

### 3.5 Monitor MAX Temp per Hour in Line Graph

~~~SQL
%jdbc(phoenix)
select
"Public_IP.geo.city", HOUR(TO_TIMESTAMP("Time")) AS HOUR, MAX("Temp_C") AS MAX_TEMP
from "sensor_readings"
where TO_NUMBER("Temp_C") <= 22.4
group by "Public_IP.geo.city", HOUR
order by HOUR
~~~

The MAX temperature at HOUR 16 in Fremont was [fill_in](#) and at HOUR 19 in Fremont was [fill_in](#).

### Step 4: Visualize Weather Readings on a Map



### Summary

Congratulations, now you know how to write Phoenix SQL queries against an HBase table. You also know how to use some of the aggregate functions offered by Phoenix to tell us MAX, MIN, AVG. You also know how to use the Phoenix Interpreter integrated with Zeppelin to visualize the data associated with our weather sensor. Now you can generate Line Graphs in Zeppelin to show you the (MIN, MAX) temperature, pressure on a particular hour and the location that the those attributes were read for data analysis.
