---
title: Build a NiFi Process Group to Validate the GeoEnriched Data
---

# Build a NiFi Process Group to Validate the GeoEnriched Data

## Introduction

With the transit data being pulled from NextBus API simulator, it shows location in form of latitude and longitude, but it does not indicate more meaningful insights like **neighborhoods** that the transits pass by on their routes. You will add that capability to the NiFi flow by integrating Google Places API. Additionally you will add the capability to automate validation of the geo enriched data. You will add a new process group called **ValidateGeoEnrichedTransitData**.

## Prerequisites

- Completed the prior tutorials within this tutorial series

## Outline

- [Google Places API Basics](#google-places-api-basics)
- [Approach 1: Manually Build ValidateGeoEnrichedTransitData Process Group (PG)](#approach-1-manually-build-validategeoenrichedtransitdata-process-group-pg)
- [Step 1: Obtain API Key for NiFi's InvokeHTTP Processor](#step-1-obtain-api-key-for-nifis-invokehttp-processor)
- [Step 2: Create Process Group and Label For It](#step-2-create-process-group-and-label-for-it)
- [Step 3: Add an Input Port to Ingest Data Into this PG](#step-3-add-an-input-port-to-ingest-data-into-this-pg)
- [Step 4: Add RouteOnAttribute to Validate NextBus Simulator Data](#step-4-add-routeonattribute-to-validate-nextbus-simulator-data)
- [Step 5: Add InvokeHTTP to Pull GeoEnriched Data from Google Places API](#step-5-add-invokehttp-to-pull-geoenriched-data-from-google-places-api)
- [Step 6: Add EvaluateJsonPath to Extract GeoEnriched Transit Data](#step-6-add-evaluatejsonpath-to-extract-geoenriched-transit-data)
- [Step 7: Add RouteOnAttribute to Validate Google Places Data](#step-7-add-routeonattribute-to-validate-google-places-data)
- [Step 8: Add an Output Port to Route Data Outside this PG](#step-8-add-an-output-port-to-route-data-outside-this-pg)
- [Step 9: Connect ParseTransitEvents to ValidateGeoEnrichedTransitData](#step-9-connect-parsetransitevents-to-validategeoenrichedtransitdata)
- [Step 10: Run the DataFlow](#step-10-run-the-dataflow)
- [Step 11: Verify GeoEnriched Data Routed by ValidateGooglePlacesData is Valid](#step-11-verify-geoenriched-data-routed-by-validategoogleplacesdata-is-valid)
- [Approach 2: Import ValidateGeoEnrichedTransitData Process Group](#approach-2-import-enriched-nifi-flow-via-places-api)
- [Summary](#summary)
- [Further Reading](#further-reading)

If you prefer to build the dataflow manually step-by-step, continue on to [Approach 1](#step-1-obtain-api-key-for-nifis-invokehttp-processor). Else if you want to see the NiFi flow in action within minutes, refer to [Approach 2](#step-2-create-process-group-and-label-for-it).

You will need to understand Google Places API, so that it will be easier to incorporate this API's data into the NiFi flow, which will be built in **Approach 1**.

## Google Places API Basics

Google Places API Web Service returns information about places: establishments, geographic locations and prominent points of interest based on Latitude and Longitude coordinates that are passed into HTTP requests. The Places API includes six place requests: **Place Searches**, **Place Details**, **Place Add**, **Place Photos**, **Place Autocomplete** and **Query Autocomplete**. Read more about these place requests in [Introducing the API](https://developers.google.com/places/web-service/intro).

All requests are accessed through an HTTP request and return either JSON or XML response.

What are the necessary components to use the Places API?

- https:// protocol
- API Key

## Approach 1: Manually Build ValidateGeoEnrichedTransitData Process Group (PG)

### Step 1: Obtain API Key for NiFi's InvokeHTTP Processor

For our dataflow, our task is to enrich the data by searching for neighborhoods within proximity of a vehicle's varying location. Currently location is represented as Latitude and Longitude coordinates. You will enhance these insights to retrieve two parameters from this location data: name of the neighborhoods and San Francisco Muni Transit Agency. So, you will integrate Nearby Search HTTP request with NiFi.

The Nearby Search request is an HTTP URL of the following definition, which we will need for NiFi:

~~~text
https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
~~~

The `output` can come in two formats: `json` or `xml`. We will use json for this tutorial.

Let's obtain the **required parameters** to initiate a Nearby Search request.

1\. You will need to [obtain an API key](https://developers.google.com/places/web-service/get-api-key), so it can identify our application for quota management and places added from the application are instantly available to our app (NiFi).

2\. You will use a standard Google Places API. Click on the blue **Get A Key** button to activate the API Web Service.

3\. A window will appear that says **Enable Google Places API Web Service**. Select **Yes**. Then **Create And Enable API**. Wait a few seconds for the new window to load.

4\. Now a screen with your unique API key will appear similar to the screen below:

![api_key](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/api_key.png)

Now you have the API Key parameter for our HTTP request. We also have the other required parameters: **location** and **radius**, which can be a distance that does not surpass 50,000 meters. You can use one optional parameter **type** to signify what type of place you are interested in searching for.

5\. Let's build the HTTP URL with the parameters below, so we can insert the URL as a property value into **InvokeHTTP** later in the tutorial.

- API Key = AIzaSyDY3asGAq-ArtPl6J2v7kcO_YSRYrjTFug
- Latitude = ${Latitude}
- Longitude = ${Longitude}
- radius = 500
- type = neighborhood

~~~text
https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${Latitude},${Longitude}&radius=500&type=neighborhood&key=AIzaSyDY3asGAq-ArtPl6J2v7kcO_YSRYrjTFug
~~~

> Note: Your **API Key** will be different than the one in the URL above. You will need to use the **ONE** you get from Google Places API Web Service.

### Step 2: Create Process Group and Label For It

1\. Add a Label ![label_icon](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/label_icon.png) onto the NiFi canvas for the new process group. Right click, **Change color** to **Purple**.

2\. Right click, select configure and name it `Geo Enrich via Google Places API and
Validate Transit Data for empty values`.

![label_for_ValidateGeoEnrichedTransitData](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/label_for_ValidateGeoEnrichedTransitData.png)

3\. Add a new Process Group onto the NiFi canvas and name it `ValidateGeoEnrichedTransitData`

![ValidateGeoEnrichedTransitData](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/ValidateGeoEnrichedTransitData.png)

4\. Double click on the new process group to enter it.

![ParseTransitEvents](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/breadcrumb_ValidateGeoEnrichedTransitData.png)

### Step 3: Add an Input Port to Ingest Data Into this PG

1\. Add the **Input Port** ![output_port](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/input_port.png) component onto the NiFi canvas. Name it `IngestParsedTransitEvents`.

![IngestParsedTransitEvents](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/IngestParsedTransitEvents.png)

### Step 4: Add RouteOnAttribute to Validate NextBus Simulator Data

1\. Add the **RouteOnAttribute** processor onto the NiFi canvas.

2\. Connect **IngestParsedTransitEvents** input port to **RouteOnAttribute** processor. When the Create Connection window appears, click **Add**.

![IngestParsedTransitEvents_to_RouteOnAttribute](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/IngestParsedTransitEvents_to_RouteOnAttribute.png)

**Figure 1:** Connect **IngestParsedTransitEvents** input port to **RouteOnAttribute** processor

3\. Open the processor configuration **properties** tab. Add a new dynamic property for NiFi expression, select the **( + )** button. Insert the following property name and value into your properties tab as shown in the table below:

**Table 1:** Add to **RouteOnAttribute** Properties Tab

| Property  | Value  |
|:---|:---|
| `ValidateTransitObservations`  | `${Direction_of_Travel:isEmpty():not():and(${Last_Time:isEmpty():not()}):and(${Latitude:isEmpty():not()}):and(${Longitude:isEmpty():not()}):and(${Vehicle_ID:isEmpty():not()}):and(${Vehicle_Speed:equals('0'):not()})}`|

~~~java
//Note: If after completing step 3 your processor shows a triangle with an exclamation mark stating that the ValidateTransitObservations is invalid, copy and paste the following into the value section of the property tab.

${Direction_of_Travel:isEmpty():not():and(
	${Last_Time:isEmpty():not()}):and(
		${Latitude:isEmpty():not()}):and(
			${Longitude:isEmpty():not()}):and(
				${Vehicle_ID:isEmpty():not()}):and(
					${Vehicle_Speed:equals('0'):not()}
)}

~~~

**Filter_Attributes** uses the FlowFile Attribute key values obtained from XPath Expressions to filter out any FlowFiles that either have at least one empty Attribute value or the speed attribute value equals 0. Else the FlowFiles are passed to the remaining processors.

4\. Open the processor config **Settings** tab, change the name from RouteOnAttribute to `ValidateNextBusData`. under Auto terminate relationships, check the **unmatched** checkbox. Click **Apply**.

### Step 5: Add InvokeHTTP to Pull GeoEnriched Data from Google Places API

1\. Add the **InvokeHTTP** processor onto the NiFi graph. Connect **ValidateNextBusData** to **InvokeHTTP** processor. When the Create Connection window appears, verify **ValidateTransitObservations** checkbox is checked, if not check it. Click **Add**.

![RouteOnAttribute_to_InvokeHTTP](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/RouteOnAttribute_to_InvokeHTTP.png)

**Figure 2:** Connect **ValidateNextBusData** to **InvokeHTTP**

2\. Open **InvokeHTTP** configure properties tab and add the property listed in **Table 2**.

**Table 2:** Update **InvokeHTTP** Properties Tab

| Property  | Value  |
|:---|:---|
| `Remote URL`  | `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${Latitude},${Longitude}&radius=500&type=neighborhood&key=AIzaSyDY3asGAq-ArtPl6J2v7kcO_YSRYrjTFug` |

**Remote URL** connects to the HTTP URL we created using Google Places API and feeds that data into the dataflow. Notice we use two NiFi expressions for location parameter. This is because those two values change as new FlowFiles pass through this processor.

3\. Navigate to the **Settings** tab, change the name from InvokeHTTP to `GoogleNearbySearchAPI`. Under Auto terminate relationships check the **Failure**, **No Retry**, **Original** and **Retry** checkboxes. Click **Apply** button.

### Step 6: Add EvaluateJsonPath to Extract GeoEnriched Transit Data

1\. Add the **EvaluateJsonPath** processor onto the NiFi graph. Connect **GoogleNearbySearchAPI** to **EvaluateJsonPath** processor. When the Create Connection window appears, select **Response** checkbox. Click Add.

![InvokeHTTP_to_EvaluateJsonPath](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/InvokeHTTP_to_EvaluateJsonPath.png)

**Figure 3:** Connect **GoogleNearbySearchAPI** to **EvaluateJsonPath**

2\. Open EvaluateJsonPath configure properties tab and update the original properties with the properties listed in **Table 3**. Note: add `city` and `neighborhoods_nearby` property by clicking the **( + )** button, then insert their values into the properties tab.

**Table 3:** Update **EvaluateJsonPath** Properties Tab

| Property  | Value  |
|:---|:---|
| `Destination`  | `flowfile-attribute`  |
| `Return Type`  | `json`  |
| `city`  | `$.results[0].vicinity`  |
| `neighborhoods_nearby`  | `$.results[*].name`  |

- **Destination** result from JSON Path Evaluation stored in FlowFile attributes.
- **2 user-defined attributes** each hold a value that is used in the NiFi Expression language filtering condition in the next processor.

3\. Navigate to the **Settings** tab, change the name from EvaluateJsonPath to `ExtractGeoEnrichedData`. Under Auto terminate relationships check the **unmatched** and **failure** checkboxes. Click **Apply** button.

### Step 7: Add RouteOnAttribute to Validate Google Places Data

1\. Add the **RouteOnAttribute** processor onto the NiFi graph. Connect **ExtractGeoEnrichedData** to **RouteOnAttribute** processor. When the Create Connection window appears, select **matched** checkbox. Click Add.

![EvaluateJsonPath_to_RouteOnAttribute](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/EvaluateJsonPath_to_RouteOnAttribute.png)

**Figure 4:** Connect **ExtractGeoEnrichedData** to **RouteOnAttribute**

2\. Open RouteOnAttribute configure properties tab and click on **New property** button to add `ValidateGooglePlacesData` to property name and insert its NiFi expression value listed in **Table 4**.

**Table 4:** Update **ValidateGooglePlacesData** Properties Tab

| Property  | Value  |
|:---|:---|
| Routing Strategy  | Route to 'matched' if all match |
| `IfCityIsNotEmpty`  | `${city:isEmpty():not()}`  |
| `IfNeighborhoodNotEmpty`  | `${neighborhoods_nearby:isEmpty():not()}`  |

~~~java
//Note: If after completing step 2 your processor shows a triangle with an exclamation mark stating that the ValidateGooglePLacesData is invalid, copy and paste into the value section of the property tab.

${city:isEmpty():not():and(
	${neighborhoods_nearby:isEmpty():not()})}
~~~

**ValidateGooglePlacesData** uses the FlowFile Attribute values obtained from JSON Path Expressions to filter out any FlowFiles that have at least one empty Attribute value. Else the FlowFiles are passed to the remaining processors.

3\. Navigate to the **Settings** tab, change the name from RouteOnAttribute to `ValidateGooglePlacesData`. Under Auto terminate relationships check the **unmatched** checkbox. Click **Apply** button.

### Step 8: Add an Output Port to Route Data Outside this PG

1\. Add the **Output Port** ![output_port](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/output_port.png) component onto the NiFi canvas. Name it `SendGeoEnrichedTransitEvents`.

2\. Connect **ValidateGooglePlacesData** to **SendGeoEnrichedTransitEvents** output port. When the Create Connection window appears ensure that the **For Relationship** field is **Matched**. Finally, click Add.

![ParseTransitEvents_dataflow_pg](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/RouteOnAttribute_to_SendGeoEnrichedTransitEvents.png)

**Figure 5:** Connect **ValidateGooglePlacesData** to **SendGeoEnrichedTransitEvents**

### Step 9: Connect ParseTransitEvents to ValidateGeoEnrichedTransitData

1\. Re-enter the `NiFi Flow` breadcrumb to exit **ValidateGeoEnrichedTransitData**.

2\. Connect **ParseTransitEvents** to **ValidateGeoEnrichedTransitData** process group. When the Create Connection window appears, verify **From Output = ParsedTransitEvents** and connects to **To Input = IngestParsedTransitEvents**. Click **Add**.

![SimulateXmlTransitEvents_to_ParseTransitEvents](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/ValidateGeoEnrichedTransitData_connect_rest_flow.png)

**Figure 6:** Connect **ParseTransitEvents** to **ValidateGeoEnrichedTransitData** Process Group

### Step 10: Run the DataFlow

1\. Hold **Shift** and drag your mouse across the entire dataflow. You should see the dataflow is highlighted.

![selected_entire_dataflow](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/selected_entire_dataflow.jpg)

**Figure 7:** Selected the entire dataflow

2\. In the **Operate** panel, you should see the header says **Multiple components are selected**. Press the **Start** button.

![start_dataflow](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/start_dataflow.jpg)

**Figure 8:** Started the entire dataflow

### Step 11: Verify GeoEnriched Data Routed by ValidateGooglePlacesData is Valid

Inside the **ValidateGeoEnrichedTransitData** process group, we will inspect **ValidateGooglePlacesData** processor. We will look at the flowfiles that pass through this processor and analyze their attributes. We need to make sure that each flowfile's attribute keys **city** and **neighborhoods_nearby** do not have an empty corresponding value. FlowFile attributes are in **key/value** format.

1\. Jump into **ValidateGeoEnrichedTransitData** process group.

2\. Right click on the **ValidateGooglePlacesData** connector downstream from **ValidateGooglePlacesData** processor, select **List queue** to see provenance events.

![routenearbyneighborhoods_listqueue](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/ValidateGooglePlacesData_listqueue.png)

**Figure 9:** List Queue for Connector between **ValidateGooglePlacesData** and **SendGeoEnrichedTransitEvents**

3\. View any event by selecting the view provenance event icon ![i_symbol_nifi](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/i_symbol_nifi_lab1.png)

4\. Click on the **Attributes** tab. As long as you see that **city** and **neighborhoods_nearby** have values, you have verified the **ValidateGooglePlacesData** processor is successfully routing flowfiles based on this condition.

![verify_evaluateXPath_extracts_data](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/verify_data_routed_by_routeonattribute.png)

**Figure 10:** Data Provenance for FlowFile attribute (key/value): **city** contains **San Francisco**.

![verify_data_routed_by_routeonattribute_p2](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/verify_data_routed_by_routeonattribute_p2.png)

**Figure 11:** Data Provenance for FlowFile attribute (key/value): **neighborhoods_nearby** contains **["Saint Francis Wood","West Portal"]**

## Approach 2: Import Enriched NiFi Flow Via Places API

**Warning 1: If you Imported the Previous DataFlow, Read these steps first**

1\. In your process group, if there are any **queues** left with data, remove the data. Right click the queue, select **Empty queue**, click **EMPTY**.

2\. Navigate back to the **NiFi Flow** breadcrumb level to delete your flow.

To delete your previous flow, hold **command** or **ctrl** and press **A** to highlight your dataflow, then press **delete** or **backspace**.

**Import the New DataFlow Template**

3\. Download the [tutorial-5-ValidateGeoEnrichedTransitData.xml](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/template/tutorial-5-ValidateGeoEnrichedTransitData.xml) template file. Then upload the template file into NiFi.

4\. Use the template icon ![nifi_template_icon](assets/tutorial-4-build-nifi-process-group-to-parse-transit-events/nifi_template_icon.png) located in the **Operate** Palette.

5\. **Browse**, find the template file, click **Open** and hit **Upload**.

6\. From the **Components Toolbar**, drag the template icon ![nifi_template_icon](assets/tutorial-4-build-nifi-process-group-to-parse-transit-events/add_nifi_template.png) onto the graph and select the **tutorial-5-ValidateGeoEnrichedTransitData.xml** template file.

**Warning 2: If you didn't Obtain Google API Key, then follow the steps**

7\. Refer to [Step 1](#step-1-obtain-api-key-for-nifis-invokehttp-processor) in **Approach 1** to obtain the Google API key and set up **Google Places API: HTTP URL**.

8\. Replace the **InvokeHTTP** processor's **Remote URL** property value with the new **Google Places API: HTTP URL** value.

9\. Hit the **start** button ![start_button_nifi_iot](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/start_button_nifi_iot.png). to activate the dataflow.

![complete_dataflow_lab2_geoEnrich](assets/tutorial-5-build-a-nifi-process-group-to-validate-the-geoenriched-data/ValidateGeoEnrichedTransitData_pg.png)

**Figure 12:** **tutorial-5-ValidateGeoEnrichedTransitData.xml** template includes a NiFi Flow that pulls in San Francisco Muni Transit Events from the XML Simulator, parses through the data to extract key values and stores the transit observations as a JSON file.

Overview of the Process Groups and their Processors:

- **SimulateXmlTransitEvents (Process Group)**
  - **GetFile** fetches the vehicle location simulator data for files in a directory.
  - **UnpackContent** decompresses the contents of FlowFiles from the traffic simulator zip file.
  - **ControlRate** controls the rate at which FlowFiles are transferred to follow-on processors enabling traffic simulation.
  - **UpdateAttribute** renames every FlowFile to give them unique names
  - **PutFile** stores data to local file system
  - **Output Port** makes the connection for the process group to connect to other components (process groups, processors, etc)

- **ParseTransitEvents (Process Group)**
  - **Input Port** ingests data from SimulateXmlTransitEvents Process Group
  - **ExtractTimestamp** extracts the timestamp of the last update for vehicle location data returned from each FlowFile.
  - **SplitXML** splits the parent's child elements into separate FlowFiles. Since vehicle is a child element in our xml file, each new vehicle element is stored separately.
  - **ExtractTransitObservations** extracts attributes: vehicle id, direction, latitude, longitude and speed from vehicle element in each FlowFile.
  - **Output Port** outputs data with the new FlowFile attribute (key/values) to the rest of the flow

- **ValidateGooglePlacesData (Process Group)**
  - **Input Port** ingests data from ParseTransitEvents Process Group
  - **ValidateNextBusData** checks the NextBus Simulator data by routing FlowFiles only if their attributes contain transit observation data (Direction_of_Travel, Last_Time, Latitude, Longitude, Vehicle_ID, Vehicle_Speed)
  - **InvokeHTTP** sends a rest call to Google Places API to pull in geo enriched data for transit location
  - **EvaluateJSONPath** parses the flowfile content for city and neighborhoods_nearby
  - **ValidateGooglePlacesData** checks the new Google Places data by routing FlowFiles only if their attributes contain geo enriched data (city, neighborhoods_nearby)
  - **Output Port** outputs data with nonempty FlowFile attributes (key/values) to the rest of the flow

## Summary

Congratulations! For the Geo Enrichment section of the dataflow, you learned to use **InvokeHTTP** to access geographic location of nearby places with Google Places Search API. You learned to add NiFi expression variables into InvokeHTTP property RemoteURL, so that the values for **latitude** and **longitude** constantly change in the URL when new FlowFiles pass through this processor. You learned to use **EvaluateJsonPath** similar to EvaluateXPath, except JSON Expression is used to extract JSON elements **(neighborhoods_nearby & city)** from a JSON structure. Now you know how to incorporate external API's into NiFi further enhance the dataflow.

## Further Reading

- [Google Places API](https://developers.google.com/places/)
- [HTTP Protocol Overview](http://code.tutsplus.com/tutorials/http-the-protocol-every-web-developer-must-know-part-1--net-31177)
- [JSON Path Expressions](http://goessner.net/articles/JsonPath/index.html#e2)
- [JSON Path Online Evaluator](http://jsonpath.com/)
- [NiFi Expression Language Guide](https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html)
