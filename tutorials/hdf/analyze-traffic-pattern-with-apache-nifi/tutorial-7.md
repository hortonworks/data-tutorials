---
title: Integrate NextBus API To Pull In Transit Live Feed
---

# Integrate NextBus API To Pull In Transit Live Feed

## Introduction

You will learn to perform **rest calls** against the **NextBus API** to retrieve transit data. You will replace the SimulateXmlTransitEvents Process Group data seed with a new processor that pulls in live stream data from **San Francisco Muni Agency** on route **OceanView** into the NiFi DataFlow.

## Prerequisites
-   Completed the prior tutorials within this tutorial series

## Outline

- [Approach 1: Manually Integrate NextBus API into NiFi Flow](#approach2-manually-build-live-vehicle-routes-nifi-flow-7)
- [NextBus Live Feed API Basics](#nextbus-live-feed-api-basics-7)
- [Step 1: Add GetHTTP to Make Rest Calls and Ingest Data via NextBus API](#add-gethttp-to-make-rest-calls-and-ingest-data-via-nextbus-api-7)
- [Step 2: Modify PutFile in StoreDataAsJSONToDisk Process Group](#modify-putfile-in-storedataasjsontodisk-process-group-7)
- [Step 3: Run the NiFi DataFlow](#run-the-nifi-dataflow-7)
- [Approach 2: Import Live Vehicle Routes NiFi Flow](#approach1-import-live-vehicle-routes-nifi-flow-7)
- [Summary](#summary-tutorial-7)
- [Further Reading](#further-reading-tutorial-7)

If you prefer to build the dataflow manually step-by-step, continue on to **Approach 1**. Else if you want to see the NiFi flow in action within minutes, refer to **Approach 2**.

You will need to understand NextBus API, so that it will be easier to incorporate this API's data into the NiFi flow, which will be built in **Approach 1**.

## Approach 1: Manually Integrate NextBus API into NiFi Flow

## NextBus Live Feed API Basics

NextBus Live Feed provides the public with live information regarding passenger information, such as vehicle location information, prediction times on transit vehicles, routes of vehicles and different agencies (San Francisco Muni, Unitrans City of Davis, etc). We will learn to use NextBus's API to access the XML Live Feed Data and create an URL. In this URL we will specify parameters in a query string. The parameters for the tutorial will include the vehicle location, agency, route and time.

After viewing the Live Feed Documentation, we created the following URL for the GetHTTP processor:

~~~
http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni&r=M&t=0
~~~

Let’s break apart the parameters, so we can better understand how to create custom URLs. There are 4 parameters:

- commands: command = vehicleLocations
- agency: a=sf-muni
- route: r=M
- time: t=0

Refer to [NextBus’s Live Feed Documentation](https://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf) to learn more about each parameter.

### Step 1: Add GetHTTP to Make Rest Calls and Ingest Data via NextBus API

You will replace the **SimulateXmlTransitEvents** Process Group with **GetHTTP** processor.

1\. Check the queue between **SimulateXmlTransitEvents** and **ParseTransitEvents**, if the queue has FlowFiles, then empty the queue. Right click on the queue, click **Empty queue**.

![empty_queue](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/empty_queue.png)

2\. Right click on the queue again. Then press **Delete**.

3\. Enter the **SimulateXmlTransitEvents**, then verify if other queues have FlowFiles and empty those queues. Once all queues are empty, step out of the Process Group.

![simulate_nb_api_pg_empty_queues](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/simulate_nb_api_pg_empty_queues.png)

4\. Right click on **SimulateXmlTransitEvents** Process Group, select **Delete** to remove it. Add **GetHTTP** processor to replace **SimulateXmlTransitEvents**.

5\. Connect **GetHTTP** to **ParseTransitEvents**. Verify **success** is checked under For Relationships. Click **ADD**.

![gethttp_to_parsetransitevents](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/gethttp_to_parsetransitevents.png)

6\. Replace the text in the label above **GetHTTP** with the following: `Ingest Real-Time Transit Data via NextBus API`

![label_gethttp_updated](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/label_gethttp_updated.png)

2\. Open **GetHTTP** Config Property Tab window. We will need to copy and paste Nextbus XML Live Feed URL into the property value. Add the property listed in **Table 1**.

**Table 1:** Update GetHTTP Properties Tab

| Property  | Value  |
|:---|---:|
| `URL`  | `http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=sf-muni&r=M&t=0` |
| `Filename`  | `live_transit_data_${now():format("HHmmssSSS")}.xml` |

![getHTTP_liveStream_config_property_tab_window](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/getHTTP_config_property_tab_window.png)

3\. Now that each property is updated. Navigate to the **Scheduling tab** and change the **Run Schedule** from 0 sec to `6 sec`, so that the processor executes a task every 6 seconds.

4\. Open the processor config **Settings** tab, change the processor's Name from GetHTTP to `IngestNextBusXMLData`. Click **Apply** button.

### Step 2: Modify PutFile in StoreDataAsJSONToDisk Process Group

You will change the directory PutFile writes data to since data is coming in from the NextBus API live feed instead of the Simulator.

1\. Open **PutFile** Configure **Properties Tab**. Change the Directory property value from the previous value to the value shown in **Table 2**:

**Table 2:** Update PutFile Properties Tab

| Property  | Value  |
|:---|---:|
| `Directory`  | `/sandbox/tutorial-id/640/nifi/output/live_transit_data` |

**Directory** is changed to a new location for the real-time data coming in from NextBus live stream.

![modify_putFile_in_geo_enrich_section](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/modify_putFile_in_geo_enrich_section.png)

2\. Click **Apply**. Then go back to the **NiFi Flow** breadcrumb.

### Step 3: Run the NiFi DataFlow

Now that we added NextBus San Francisco Muni Live Stream Ingestion to our dataflow , let's run the dataflow and verify if we receive the expected results in our output directory.

1\. Go to the actions toolbar and click the start button ![start_button_nifi](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/start_button_nifi.png). Your screen should look like the following:

![live_stream_ingestion_flow](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/live_stream_ingestion_flow.png)

2\. Let's verify the data sent to the output directory is correct. Open the Data Provenance for the **PutFile** processor located in **StoreDataAsJSONToDisk** PG. Select **Provenance Event** and **View** its content.

Did you receive neighborhoods similar to the image below?

![data_provenance_neighborhoods_nearby](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/data_provenance_neighborhoods_nearby.png)

## Approach 2: Import NextBusAPIIntegration NiFi Flow

1\. Download the [tutorial-7-ingest-live-nextbus-api.xml](#assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/template/tutorial-7-ingest-live-nextbus-api.xml) template file. Then import the template file into NiFi.

2\. Hit the **start** button ![start_button_nifi](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/start_button_nifi.png) to activate the dataflow.

![live_stream_ingestion_flow](assets/tutorial-7-integrate-nextbus-api-to-pull-in-transit-live-feed/live_stream_ingestion_flow.png)

Overview of the NiFi Flow:

- **GetHTTP** ingests real-time transit observation data from NextBus API


- **ParseTransitEvents (Process Group)**
  - **Input Port** ingests data from SimulateXmlTransitEvents Process Group
  - **EvaluateXPath** extracts the timestamp of the last update for vehicle location data returned from each FlowFile.
  - **SplitXML** splits the parent's child elements into separate FlowFiles. Since vehicle is a child element in our xml file, each new vehicle element is stored separately.
  - **EvaluateXPath** extracts attributes: vehicle id, direction, latitude, longitude and speed from vehicle element in each FlowFile.
  - **Output Port** outputs data with the new FlowFile attribute (key/values) to the rest of the flow


- **ValidateGooglePlacesData (Process Group)**
  - **Input Port** ingests data from ParseTransitEvents Process Group
  - **RouteOnAttribute** checks the NextBus Simulator data by routing FlowFiles only if their attributes contain transit observation data (Direction_of_Travel, Last_Time, Latitude, Longitude, Vehicle_ID, Vehicle_Speed)
  - **InvokeHTTP** sends a rest call to Google Places API to pull in geo enriched data for transit location
  - **EvaluateJSONPath** parses the flowfile content for city and neighborhoods_nearby
  - **RouteOnAttribute** checks the new Google Places data by routing FlowFiles only if their attributes contain geo enriched data (city, neighborhoods_nearby)
  - **Output Port** outputs data with nonempty FlowFile attributes (key/values) to the rest of the flow


- **StoreTransitEventsAsJSONToDisk (Process Group)**
  - **Input Port** ingests data from ValidateGooglePlacesData Process Group
  - **AttributesToJSON** generates a JSON representation of the attributes extracted from the FlowFiles and converts XML to JSON format this less attributes.
  - **MergeContent** merges a group of JSON FlowFiles together based on a number of FlowFiles and packages them into a single FlowFile.
  - **UpdateAttribute** updates the attribute name for each FlowFile.
  - **PutFile** writes the contents of the FlowFile to a desired directory on the local filesystem.

## Summary

Congratulations! You learned how to use NextBus's API to connect to their XML Live Feed for vehicle location data. You also learned how to use the **GetHTTP** processor to ingest a live stream from NextBus San Francisco Muni into NiFi!

## Further Reading

- [NextBus XML Live Feed](https://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf)
- [Hortonworks NiFi User Guide](https://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.0.0/bk_user-guide/content/index.html)
- [Hortonworks NiFi Developer Guide](https://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.0.0/bk_developer-guide/content/index.html)
