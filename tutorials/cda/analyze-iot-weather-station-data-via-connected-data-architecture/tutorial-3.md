---
title: Analyze IoT Weather Station Data via Connected Data Architecture
tutorial-id: 820
platform: hdp-2.6.0
tags: [nifi, minifi, raspberry pi, connected data architecture, hbase, iot, weather]
---

# Collect Sense HAT Weather Data on CDA

## Introduction

You'll learn to collect sensor readings from the R-Pi Sense HAT for
temperature, humidity and barometric pressure. You'll also run MiNiFi
on top of the R-Pi to ingest the weather readings and route it to the location of
NiFi on HDF sandbox via Site-to-Site protocol. You'll also verify NiFi can
make contact with HDP by storing the data into Hadoop Distributed File System (HDFS).

## Prerequisites

- Completed **Deploy IoT Weather Station**

## Outline

- Step 1: Measure Weather Data with R-Pi
- Step 2: Build NiFi Flow to Store MiNiFi Data to HDFS
- Step 3: Build MiNiFi Flow to Push Data to NiFi
- Summary
- Further Reading
- Appendix A: Troubleshoot MiNiFi to NiFi Site-to-Site
- A.1: Check MiNiFi Logs
- A.2: Troubleshoot HDF Input Ports via OS X Firewall

### Step 1: Measure Weather Data with R-Pi

You will learn to create a Python script that collects weather readings from the Sense HAT.

### 1.1 Gather Weather Readings from Sense HAT

Temperature, humidity and barometric pressure will be gathered from the Sense HAT using the Adafruit Sense HAT python library to collect weather readings. For instance, sense.get_temperature grabs a temperature reading and stores it into the temp variable.

~~~python
# Attempt to get sensor reading.
temp = sense.get_temperature()
temp = round(temp, 1)
humidity = sense.get_humidity()
humidity = round(humidity, 1)
pressure = sense.get_pressure()
pressure = round(pressure, 1)
~~~

### 1.2 Print Weather Attribute Values to Screen

With print statements, the variables values can be outputted to standard output and displayed on the screen:

~~~python
print "Temperature_C = ", temp
print "Humidity = ", humidity
print "Pressure = ", pressure, "\n"
~~~



### 1.3 Download Python weather-station.py

Open R-Pi terminal and download the python script:

~~~
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/master/tutorials/cda/analyze-iot-weather-station-data-via-connected-data-architecture/assets/WeatherStation.py
chmod 750 WeatherStation.py
~~~

### 1.4 Python weather-station.py Reference

This code is an adaptation of Ramin Sangesori's code. However, our code just outputs weather sensor data to standard output and can display it on the 8x8 LED matrix.

~~~Python
#!/usr/bin/python

import json
import sys
import time
import datetime

# libraries
import sys
import urllib2
import json
from sense_hat import SenseHat

sense = SenseHat()
sense.clear()
print 'Weather Logs'

# Attempt to get sensor reading.
temp = sense.get_temperature()
temp = round(temp, 1)
humidity = sense.get_humidity()
humidity = round(humidity, 1)
pressure = sense.get_pressure()
pressure = round(pressure, 1)

# 8x8 RGB
#sense.clear()
#info = 'Temperature (C): ' + str(temp) + 'Humidity: ' + str(humidity) + 'Pressure: ' + str(pressure)
#sense.show_message(info, text_colour=[255, 0, 0])

# Print
print "Temperature_C = ", temp
print "Humidity = ", humidity
print "Pressure = ", pressure, "\n"
~~~

### Step 2: Build NiFi Flow to Store MiNiFi Data to HDFS

### 2.1 Build NiFi to HDFS

1\. In NiFi, add an input port onto the canvas and name it `From_MiNiFi`.

~~~bash
# From_MiNiFi ---> PutHDFS NiFi Flow Picture
~~~

2\. Add a **PutHDFS** processor onto the canvas. Configure the PutHDFS properties by adding a property specified in Table 1 to **Hadoop Configuration Files**.

**Table 1: PutHDFS Property Values**

| Property | Value    |
| :------------- | :------------- |
| Hadoop Configuration Files     | /etc/hdfs/core-site.xml       |

3\. Connect input port **From_MiNiFi** to PutHDFS.

Now you will build the MiNiFi flow in NiFi.

### Step 3: Build MiNiFi Flow to Push Data to NiFi

You'll learn to build a flow for MiNiFi using NiFi by including only the processors that are compatible with MiNiFi.

### 3.1 Build MiNiFi Flow Using NiFi

1\. Create a new NiFi process group called `MiNiFi_Flow`

2\. Add the **ExecuteProcess** processor onto the NiFi canvas.

- ExecuteProcess: Executes the WeatherStation.py Python Script to bring the raw sensor data into MiNiFi every 5 seconds.

3\. Configure the properties in ExecuteProcess's Property Tab by adding the properties listed in Table 2:

**Table 2: ExecuteProcess Property Values**

| Property | Value    |
| :------------- | :------------- |
| Command      | python       |
| Command Arguments     | /home/pi/WeatherStation.py       |
| Batch Duration     | 5 sec       |


4\. Add the **Remote Process Group (RPG)** onto the canvas.

- Remote Process Group (RPG): sends sensor data from host machine to a remote NiFi instance running on a different computer

5\. Configure the properties in RPG's Property Tab by adding the properties listed in Table 3:

**Table 3: RPG Property Values**

| Property | Value    |
| :------------- | :------------- |
| URLs     | http://[pc-ip-addr]/nifi/       |

- URLs: MiNiFi uses this value to know the location of the remote NiFi instance. Also if the network changes, the remote NiFi will have a different IP address than before.

> Note: to find <pc-ip-addr>, type ifconfig | grep inet. For ex, in the office my pc shows 10.11.4.120, but the ip is different for each pc. Most homes will have a similar pattern to 192.168.x.x, x.x are usually the two digits that change.

6\. RPG connects MiNiFi to NiFi by referencing the name of NiFi's input port. Connect the **ExecuteProcess** processor to **RPG**, you will then be asked which input port to connect to, choose **From_MiNiFi**.

Here is a visualization of the MiNiFi flow in NiFi. Typically MiNiFi flow is built as a NiFi flow, saved as a NiFi template and converted to YAML using the MiNiFi toolkit.

![]()

### 3.2 Save MiNiFi Flow as a NiFi Template

1\. Hold Shift and hover over the NiFi dataflow that was built for MiNiFi. Hover to the operate panel, select the  **Save Template Icon.** Name it `weather-node`.

2\. In the top right corner, open the **Global Menu**, select **Templates**. Choose to download `weather-node` by selecting the Download icon. download the template file.

### 3.3 Convert NiFi Template to MiNiFi Template

1\. Run the MiNiFi Toolkit Converter from the location you downloaded it in the previous tutorial. Use the command to convert NiFi xml template to MiNiFi yaml template:

~~~bash
cd ~/Downloads
./minifi-toolkit-0.1.0/bin/config.sh transform weather-node.xml config.yml
~~~

2\. Validate there are no issues with the new MiNiFi file:

~~~bash
./minifi-toolkit-0.1.0/bin/config.sh validate config.yml
~~~

> Note: You should receive no errors were found while parsing the configuration file.

3\. Transport the config.yml file from our local machine to MiNiFi’s conf folder on our R-Pi. Write the command:

~~~bash
# Transport config.yml to MiNiFi on R-Pi
scp -P 22 config.yml pi@10.14.3.153:/home/pi/minifi-1.0.2.1.1.0-2/conf
~~~

> Note: 10.14.3.153 = <pi-ip-addr>, minifi-1.0.2.1.1.0-2 = <minifi-folder>

Starting the MiNiFi flow will be done in the next step since the weather data will be stored in HDFS and the NiFi to HDFS flow still needs to be built.

4\. In MiNiFi `bin` directory on R-Pi, start MiNiFi program with the command:

~~~bash
./bin/minifi.sh start
~~~

5\. In NiFi, hold shift and hover over the flow you built in step 2, then it should be highlighted. Start the NiFi flow. You should see the MiNiFi data is being received by way of the NiFi input port and that data is being routed to HDFS on HDP.


### Summary

Congratulations! You just learned how to build dataflows for MiNiFi through using NiFi. Additionally, you also built a flow that transports the weather edge node data from MiNiFi to NiFi on HDF to HDFS on HDP using Connected Data Architecture (CDA). Now you have the fundamental knowledge on how to transport data between systems using CDA.

### Further Reading

### Appendix A: Troubleshoot MiNiFi to NiFi Site-to-Site

### A.1: Check MiNiFi Logs

If you do not see data flowing into NiFi, the first place to check is the MiNiFi logs.

1\. From your R-Pi, navigate to the MiNiFi `logs` directory and open the `minifi-app.log`:

~~~bash
cd minifi-1.0.2.1.1.0-2/logs
less minifi-app.log
~~~

**WARNS, ERRORS** in the logs usually indicate the specific problem related to your dataflow.

### A.2: Troubleshoot HDF Input Ports via OS X Firewall

For MiNiFi to connect to HDF Docker Sandbox running on a MAC OS X, ports of the firewall need to open. Therefore, the NiFi port will be accessible by MiNiFi running on the R-Pi or other computers.

1\. Edit the `/etc/pf.conf` to make the necessary ports accessible by other computers:

~~~bash
sudo vi /etc/pf.conf
~~~

2\. Add the following two lines at the end of the file:

~~~bash
pass in proto tcp from any to any port 19090
pass in proto tcp from any to any port 15000
~~~

3\. Save and close the file. In vi, press escape key and `:wq` to exit the program.

4\. Open the network utility to verify the ports are open.

5\. Enter your computer's internal IP address and specify the range for ports as `14999 to 19100`.

![verify_ports_opened]()

> Note: open ports will appear in the port scan.
