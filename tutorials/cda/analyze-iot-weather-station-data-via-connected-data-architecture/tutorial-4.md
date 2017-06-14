---
title: Analyze IoT Weather Station Data via Connected Data Architecture
tutorial-id: 820
platform: hdp-2.6.0
tags: [nifi, minifi, raspberry pi, connected data architecture, hbase, iot, weather]
---

# Store Data into HDP HBase

## Introduction

In the previous tutorial, you transported raw sensor data from MiNiFi to NiFi. Now you'll further enrich the NiFi flow by adding geographic location attributes to the dataset. You'll then convert the data to JSON format for storing into HBase.

## Prerequisites

- Completed **Collect Sense HAT Weather Data on CDA**

## Outline

- Step 1: Create HBase "sense_hat_logs"
- Step 2: Enhance NiFi Flow for HBase Storage
- Step 3: Verify HBase Table Populated
- Summary
- Further Readings

### Step 1: Create HBase "sense_hat_logs"

1\. SSH into your HDP Sandbox. Open HBase shell:

**SSH**

~~~bash
ssh root@sandbox.hortonworks.com -p 2222
~~~

**Open HBase**

~~~bash
hbase shell
~~~

2\. Create HBase Table:

~~~bash
create 'sense_hat_logs','weather'
~~~

### Step 2: Enhance NiFi Flow for HBase Storage

1\. Download the NiFi flow template to your local machine with the following commands:

~~~bash
cd ~/Downloads
wget <url-to-nifihbase-template>
~~~

2\. Head to NiFi UI from HDF sandbox:

~~~bash
sandbox-hdf.hortonworks.com:19090/nifi
~~~

3\. Import NiFi template you just downloaded:

![image1-importport]()

![image2-pick-nifi-template-open]()

4\. Drag and drop nifi template onto the canvas:

![drag-drop-nifi-flow]()

5\. Analysis of the NiFi flow:

- **Input Port**: `From_MiNiFi` ingests sensor data from MiNiFi. This port must have the same name specified by the input port attribute on the MiNiFi remote process group, else NiFi won’t receive data from MiNiFi.

- **ExtractText**: Extracts values from text using java regex expression and stores those values into attributes

| Property | Value    |
| :------------- | :------------- |
| Pressure_Pa     | `(?<=Pressure = )([\w+.-]+)`      |
| Public_IP     | `(?<=Public_IP: )([\w+.-]+)`      |
| Sensor_ID     | `(?<=Sensor_ID = )([\w+.-]+)`      |
| Temp_C     | `(?<=Temp = )([\w+.-]+)`      |
| Time     | `(?<=")([^\"]+)`      |
| Timestamp     | `(?<=")([^\"]+)`      |


- **GeoEnrichIP**: Takes Public IP and creates geographic attributes for Latitude, Longitude, City, Country, State (IP.geo.latitude, IP.ge.longitude, IP.geo.city, IP.geo.country and IP.geo.subdivision.isocode.N)

| Property | Value    |
| :------------- | :------------- |
| Geo Database File     | `/root/GeoFile/GeoLite2-City.mmdb`      |
| IP Address     | `Public_IP`      |

- **RouteOnAttribute**: Routes the Attributes to remaining dataflow based on certain criteria.
UpdateAttribute: Modifies the time attribute and adds onto it the flowfile’s UUID

Here is the NiFi Expressions used to establish the conditions for each flowfile to move onto the remaining processors:

| Property | Value    |
| :------------- | :------------- |
| Check_City     | `${Public_IP.geo.city:isEmpty():not()}`      |
| Check_IP     | `${Public_IP:isEmpty():not()}`      |
| Check_Pressure     | `${Pressure_Pa:lt(108000):and(${Pressure_Pa:gt(87000)})}`      |
| Check_Sensor_ID     | `${Sensor_ID:lt(100):and(${Sensor_ID:gt(0)})}`      |
| Check_State     | `${Public_IP.geo.subdivision.isocode.0:isEmpty():not()}`      |
| Check_Temp     | `${Temp_C:lt(88)}`      |
| Check_Time     | `${Time:isEmpty():not():and(${Timestamp:isEmpty():not()})}`      |


- GeoEnrichIP
- RouteOnAttribute
- **AttributesToJson**: Takes the attributes names and values and represents them in JSON format

| Property | Value    |
| :------------- | :------------- |
| **Attributes List**     | `Time, Timestamp, Public_IP.geo.city, Public_IP.geo.subdivision.isocode.0, Sensor_ID, Temp_C, Pressure_Pa`      |


- **UpdateAttribute**: Modifies each flowfile filename to be different.


| Property | Value    |
| :------------- | :------------- |
| **Filename**     | `weatherdata-${now():format("yyyy-MM-dd-HHmmssSSS")}-${UUID()}.json`      |



- **PutHBaseJSON**: Takes in JSON data and routes it to HBase table ‘sensor_readings’ rows.

| Property | Value    |
| :------------- | :------------- |
| **Hbase Client Service**     | **HBase_1_1_2_ClientService**       |
| **Table Name**     | **sense_hat_logs**       |
| Row Identifier Field Name     | Timestamp       |
| Row Identifier Encoding Strategy     | String       |
| **Column Family**     | **weather**       |
| **Batch Size**     | **25**       |
| **Complex Field Strategy**     | **Text**       |
| **Field Encoding Strategy**     | **String**       |

6\. Run the NiFi flow

![nifi-flow-running]()

### Step 3: Verify HBase Table Populated

1\. Use the HBase scan command to see if table has data:

~~~bash
scan 'sense_hat_logs'
~~~

### Summary

Congratulations! You just implemented a NiFi flow that sends compatible data to HBase that is running on HDP. In addition, you also brought more attributes to the dataset, so users will be aware of the location in which the weather readings were recorded. In the next tutorial, you will visualize the weather data with Zeppelin's Phoenix interpreter.

### Further Reading
