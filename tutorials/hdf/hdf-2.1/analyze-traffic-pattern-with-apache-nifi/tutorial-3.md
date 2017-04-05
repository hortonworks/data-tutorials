---
title: Analyze Traffic Pattern with Apache NiFi
tutorial-id: 640
platform: hdf-2.1.0
tags: [nifi]
---

# Tutorial 1: Build A Simple NiFi DataFlow

## Introduction

In this tutorial, we will build a NiFi DataFlow to fetch vehicle location, speed, and other sensor data from a San Francisco Muni traffic simulator, look for observations of a specific few vehicles, and store the selected observations into a new file. Even though this aspect of the tutorial is not streaming data, you will see the importance of file I/O in NiFi dataflow application development and how it can be used to simulate streaming data.

In this tutorial, you will build the following dataflow:

![completed-data-flow-lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/completed-data-flow-lab1.png)

**Figure 1:** The completed dataflow contains three sections: ingest data from vehicle location XML Simulator, extract vehicle location detail attributes from FlowFiles and route these detail attributes to a JSON file as long as they are not empty strings. You will learn more in depth about each processors particular responsibility in each section of the dataflow.

## Prerequisites
- Completed Analyze Traffic Patterns with Apache NiFi Introduction
- Completed Tutorial 0: Launch NiFi HTML UI

## Outline
- [Approach 1: Import Simple NiFi Flow](#approach1-import-simple-nifi-flow)
- [Approach 2: Manually Build Simple NiFi Flow](#approach2-manually-build-simple-nifi-flow)
- [Step 1: Create a NiFi DataFlow](#create-nifi-dataflow)
- [Step 2: Build XML Simulator DataFlow Section](#build-xml-simulator-flow)
- [Step 3: Build Key Attribute Extraction DataFlow Section](#build-key-attributes-extraction)
- [Step 4: Build Filter and JSON Conversion DataFlow Section](#build-filter-json-conversion)
- [Step 5: Run the NiFi DataFlow](#run-nifi-dataflow-tutorial1)
- [Summary](#summary-tutorial1)
- [Further Reading](#further-reading-tutorial1)
- [Appendix A: Review of NiFi DataFlow](#appendix-a-review-dataflow)
- [Appendix B: Create Labels for Processor Groups](#appendix-b-create-labels)

If you want to see the NiFi flow in action within minutes, refer to **Approach 1**. Else if you prefer to build the dataflow manually step-by-step, continue on to **Approach 2**.

## Approach 1: Import Simple NiFi Flow

1\. Download the [Tutorial-1-simple-nifi-flow.xml](assets/tutorial-1-build-a-simple-nifi-dataflow/nifi-template/tutorial-1-simple-nifi-flow.xml) template file.

2\. Click on the template icon ![nifi_template_icon](assets/tutorial-1-build-a-simple-nifi-dataflow/nifi_template_icon.png) located in the actions toolbar (also known as Operate Panel).

3\. Click **Browse**, find the template file, click **Open** and hit **Import**.

4\. Hover over to the top left of the NiFi HTML interface, drag the template icon ![nifi_template_icon](assets/tutorial-1-build-a-simple-nifi-dataflow/add_nifi_template.png) onto the graph and select the **tutorial-1-simple-nifi-flow.xml** template file.

5\. Run the following shell script, so NiFi has Vehicle Location input source data:

~~~bash
./auto_scripts/init_nifi_in_src_data.sh
~~~

6\. Hit the **start** button ![start_button_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/start_button_nifi_iot.png). to activate the dataflow.

![run_dataflow_lab1_nifi_learn_ropes](assets/tutorial-1-build-a-simple-nifi-dataflow/run_dataflow_lab1_nifi_learn_ropes.png)

> Note: We highly recommend you read through the tutorial, so you become familiar with the process of building a dataflow.

## Approach 2: Manually Build Simple NiFi Flow

### Step 1: Create a NiFi DataFlow <a id="create-nifi-dataflow"></a>

The building blocks of every dataflow consist of processors. These tools perform actions on data to ingest, route, extract, split, aggregate or store it. Our dataflow will contain these processors, each processor includes a high level description of their role in the tutorial:

- **GetFile** reads vehicle location data from traffic stream zip file
- **UnpackContent** decompresses the zip file
- **ControlRate** controls the rate at which FlowFiles move to the flow
- **EvaluateXPath(x2)** extracts nodes (elements, attributes, etc.) from the XML file
- **SplitXml** splits the XML file into separate FlowFiles, each comprised of children of the parent element
- **UpdateAttribute** assigns each FlowFile a unique name
- **RouteOnAttribute** makes the filtering decisions on the vehicle location data
- **AttributesToJSON** represents the filtered attributes in JSON format
- **MergeContent** merges the FlowFiles into one FlowFile by concatenating their JSON content together
- **PutFile** writes filtered vehicle location data content to a directory on the local file system

Refer to [NiFi's Documentation](https://nifi.apache.org/docs.html) to learn more about each processor described above.

### 1.1 Learning Objectives: Overview of DataFlow Build Process
- Build a NiFi DataFlow to ingest, filter, convert and store moving data
- Establish connections and relationships between processors
- Troubleshoot problems that may occur
- Run the the NiFi DataFlow

Your dataflow will extract the following XML Attributes from the transit data listed in Table 1. We will learn how to do this extraction with the EvaluateXPath processor when we build our dataflow.

**Table 1: Extracted XML Attributes From Transit Data**

| Attribute Name  | Type  | Comment  |
|:---|:---:|---:|
| id  | string  | Vehicle ID |
| time  | int64  | Observation timestamp  |
| lat  | float64  | Latitude (degrees)  |
| lon  | float64  | Longitude (degrees)  |
| speedKmHr  | float64  | Vehicle speed (km/h)  |
| dirTag  | float64  | Direction of travel  |

After extracting, filtering and converting the data, your new file, which contains transit location data will be stored in the Output Directory listed in Table 2. We will learn how to satisfy the conditions in Table 2 with RouteOnAttribute, AttributesToJSON and PutFile processors.

**Table 2: Other DataFlow Requirements**

| Parameter  | Value  |
|:---|---:|
| Input Directory  | /tmp/nifi/input  |
| Output Directory  | /tmp/nifi/output/filtered_transitLoc_data  |
| File Format  | JSON  |
| Filter For  | id, time, lat, lon, speedKmHr, dirTag  |

Let's build our dataflow to fetch, filter, convert and store transit sensor data from San Francisco Muni, M-Ocean View route. Here is a visualization, courtesy of NextBus and Google, of the data NiFi generates using our Traffic XML Simulator:

![sf_ocean_view_route_nifi_streaming](assets/tutorial-1-build-a-simple-nifi-dataflow/live_stream_sf_muni_nifi_learning_ropes.png)

### 1.2 Add processors

1\. Go to the **components** toolbar, drag and drop the processor icon ![processor_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/processor_nifi_iot.png) onto the graph.

An **Add Processor** window will appear with 3 ways to find our desired processor: **processor list**, **tag cloud**, or **filter bar**

- processor list: contains almost 180 processors
- tag cloud: reduces list by category
- filter bar: search for desired processor

2\. Select the **GetFile** processor and a short description of the processor's function will appear.

Creates FlowFiles from files in a directory. NiFI will ignore files it doesn’t have at least read permissions for.

<!---
- **GetFile** fetches the vehicle location simulator data for files in a directory.
--->

Click the **Add** button to add the processor to the graph.

![add_processor_getfile_nifi-learn-ropes](assets/tutorial-1-build-a-simple-nifi-dataflow/add_processor_getfile_nifi-learn-ropes.png)

3\. Add the **UnpackContent, ControlRate, EvaluateXPath, SplitXML, UpdateAttribute, EvaluateXPath, RouteOnAttribute, AttributesToJSON, MergeContent** and **PutFile** processors using the processor icon.

Overview of Each Processor's Role in our DataFlow:

- **GetFile** fetches the vehicle location simulator data for files in a directory.
- **UnpackContent** decompresses the contents of FlowFiles from the traffic simulator zip file.
- **ControlRate** controls the rate at which FlowFiles are transferred to follow-on processors enabling traffic simulation.
- **EvaluateXPath** extracts the timestamp of the last update for vehicle location data returned from each FlowFile.
- **SplitXML** splits the parent's child elements into separate FlowFiles. Since vehicle is a child element in our xml file, each new vehicle element is stored separately.
- **EvaluateXPath** extracts attributes: vehicle id, direction latitude, longitude and speed from vehicle element in each FlowFile.
- **RouteOnAttribute** transfers FlowFiles to follow-on processors only if vehicle ID, speed, latitude, longitude, timestamp and direction match the filter conditions.
- **AttributesToJSON** generates a JSON representation of the attributes extracted from the FlowFiles and converts XML to JSON format this less attributes.
- **MergeContent** merges a group of JSON FlowFiles together based on a number of FlowFiles and packages them into a single FlowFile.
- **UpdateAttribute** updates the attribute name for each FlowFile.
- **PutFile** writes the contents of the FlowFile to a desired directory on the local filesystem.

Follow the step above to add these processors. You should obtain the image below:

![added_processors_nifi_part1](assets/tutorial-1-build-a-simple-nifi-dataflow/added_processors_nifi_part1.png)

> Note: To find more information on the processor, right click ExecuteProcess and click **usage**. An in app window will appear with that processor’s documentation. Also if you want to create color coded labels that act as a background for a processor group, refer to **Appendix B** at the bottom of the page.

### 1.3 Troubleshoot Common Processor Issues

Notice the eleven processors in the image above have warning symbols ![warning_symbol_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/warning_symbol_nifi_iot.png) in the upper left corner of the processor face. These warning symbols indicate the processors are invalid.

1\. To troubleshoot, hover over one of the processors, for instance the **GetFile** processor, and a warning symbol will appear. This message informs us of the requirements needed, so we can run this processor.

![error_getFile_processor_nifi_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/warning_getFile_processor_nifi_lab1.png)

The warning message indicates: we need to specify a directory path to tell the processor where to pull data and a connection for the processor to establish a relationship.
Each Processor will have its own alert message. Let’s configure and connect each processor to remove all the warning messages, so we can have a live data flow.


### 1.4 Configure & Connect processors

Now that we added some processors, we will configure our processors in the **Configure Processor** window, which contains 4 tabs: **Settings**, **Scheduling**, **Properties** and **Comments**. We will spend most of our time in the properties tab since it is the main place to configure specific information that the processor needs to run properly. The properties that are in bold are required for the processor to be valid. If you want more information on a particular property, hover over the help icon ![question_mark_symbol_properties_config_iot.png](assets/tutorial-1-build-a-simple-nifi-dataflow/question_mark_symbol_properties_config_iot.png) located next to the Property Name with the mouse to read a description of the property. While we configure each processor, we will also connect each processor together and establish a relationship for them to make the dataflow complete.

If you would like to read more about configuring and connecting processors, refer to [Hortonworks Apache NiFi User Guide](http://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.1.2/bk_dataflow-user-guide/content/ch_user-guide.html), Building a DataFlow: section 6.2 and 6.5.

### Step 2: Build XML Simulator DataFlow Section <a id="build-xml-simulator-flow"></a>

### 2.1 GetFile

1\. Right click on the **GetFile** processor and click **configure** from dropdown menu

![configure_processor_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/configure_processor_nifi_iot.png)

2\. Click on the **Properties** tab. Add the properties listed in Table 3 to the processor's appropriate properties and if their original properties already have values, update them. Click the **OK** button after changing a property.

**Table 3:** Update GetFile Property Values

| Property  | Value  |
|:---|---:|
| `Input Directory`  | `/tmp/nifi/input`  |
| `Keep Source File`  | `true`  |

- **Input Directory** location at which data is ingested into the dataflow

- **Keep Source File** source files in directory remain after all data is ingested

![getFile_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/getFile_config_property_tab_window.png)

**Figure 3:** GetFile Configuration Property Tab Window

3\. Now that each property is updated. Navigate to the **Scheduling tab** and change the **Run Schedule** from 0 sec to `1 sec`, so that the processor executes a task every 1 second. Therefore, overuse of system resources is prevented.

4\. Now that each required item is updated, click **Apply**. Connect **GetFile** to **UnpackContent** processor by dragging the arrow icon from the first processor to the next component. When the Create Connection window appears, verify **success** checkbox is checked, if not check it. Click Add.

### 2.2 UnpackContent

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 4 and if their original properties already have values, update them.

**Table 4:** Update UnpackContent Property Value

| Property  | Value  |
|:---|---:|
| `Packaging Format`  | `zip`  |

**Packaging Format** tells the processor of packaging format used to create the file

![unpackContent_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/unpackContent_config_property_tab_window.png)

**Figure 4:** UnpackContent Configuration Property Tab Window

2\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **original** checkboxes. Click **Apply**.

3\. Connect **UnpackContent** to **ControlRate** processor. When the Create Connection window appears, verify **success** checkbox is checked, if not check it. Click Add.

### 2.3 ControlRate

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 5 and if their original properties already have values, update them.

**Table 5:** Update ControlRate Property Values

| Property  | Value  |
|:---|---:|
| `Rate Control Criteria`  | `flowfile count`  |
| `Maximum Rate`  | `1`  |
| `Time Duration`  | `6 second`  |

- **Rate Control Criteria** instructs the processor to count the number of FlowFile before a transfer takes place

- **Maximum Rate** instructs the processor to transfer 1 FlowFile at a time

- **Time Duration** makes it so only 1 flowfile will transfer through this processor every 6 seconds.

![controlRate_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/controlRate_config_property_tab_window.png)

**Figure 5:** ControlRate Configuration Property Tab Window

2\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** checkbox. Click **Apply**.

3\. Connect **ControlRate** to **EvaluateXPath** processor. When the Create Connection window appears, verify **success** checkbox is checked, if not check it. Click Add.

### Step 3: Build Key Attribute Extraction DataFlow Section <a id="build-key-attributes-extraction"></a>

### 3.1 EvaluateXPath

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 6 and if the original properties already have values, update them. For the second property in Table 6, add a new dynamic property for XPath expression, select the **New property** button. Insert the following property name and value into your properties tab as shown in the table below:

**Table 6:** Update EvaluateXPath Property Values

| Property  | Value  |
|:---|---:|
| `Destination`  | `flowfile-attribute`  |
| `Last_Time`  | `//body/lastTime/@time`  |

- **Destination** result from XPath evaluation stored into FlowFile attribute

- **Last_Time** is a FlowFile Attribute and XPath expression that retrieves value of time node in the XML file

![evaluateXPath_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/evaluateXPath_config_property_tab_window.png)

**Figure 6:** EvaluateXPath Configuration Property Tab Window

3\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **unmatched** checkboxes. Click **Apply**.

4\. Connect **EvaluateXPath** to **SplitXML** processor. When the Create Connection window appears, verify **matched** checkbox is checked, if not check it. Click Add.

### 3.2 SplitXML

1\. Keep SplitXML configuration **properties** as default.

2\.  Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **original** checkboxes. Click Apply.

3\. Connect **SplitXML** to **EvaluateXPath** processor. When the Create Connection window appears, verify **split** checkbox is checked, if not check it. Click Add.

### 3.3 EvaluateXPath

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 7 and if their original properties already have values, update them. For the remaining properties in Table 7, add new dynamic properties for XPath expressions, click on the **New property** button. Insert the following property name and value into your properties tab as shown in the table below:

**Table 7:** Update EvaluateXPath Property Values

| Property  | Value  |
|:---|---:|
| `Destination`  | `flowfile-attribute`  |
| `Direction_of_Travel`  | `//vehicle/@dirTag`  |
| `Latitude`  | `//vehicle/@lat`  |
| `Longitude`  | `//vehicle/@lon`  |
| `Vehicle_ID`  | `//vehicle/@id`  |
| `Vehicle_Speed`  | `//vehicle/@speedKmHr`  |

- **Destination** set to FlowFile attribute because the result of values from XPath expressions need to be stored in FlowFile attributes.

- **5 user-defined attributes** each hold a value that is used in NiFi Expression language filtering condition in the next processor.

![evaluateXPath_extract_splitFlowFiles_config_property_tab](assets/tutorial-1-build-a-simple-nifi-dataflow/evaluateXPath_extract_splitFlowFiles_config_property_tab.png)

**Figure 8:** EvaluateXPath Configuration Property Tab Window

2\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **unmatched** checkboxes. Click **Apply**.

3\. Connect **EvaluateXPath** to **RouteOnAttribute** processor. When the Create Connection window appears, verify **matched** checkbox is checked, if not check it. Click Add.


### Step 4: Build Filter and JSON Conversion DataFlow Section <a id="build-filter-json-conversion"></a>

### 4.1 RouteOnAttribute

1\. Open the processor configuration **properties** tab. Add a new dynamic property for NiFi expression, select the **New property** button. Insert the following property name and value into your properties tab as shown in the table below:

**Table 8:** Add RouteOnAttribute Property Value

| Property  | Value  |
|:---|---:|
| `Filter_Attributes`  | `${Direction_of_Travel:isEmpty():not():and(${Last_Time:isEmpty():not()}):and(${Latitude:isEmpty():not()}):and(${Longitude:isEmpty():not()}):and(${Vehicle_ID:isEmpty():not()}):and(${Vehicle_Speed:equals('0'):not()})}`  |

**Filter_Attributes** uses the FlowFile Attribute values obtained from XPath Expressions to filter out any FlowFiles that either have at least one empty Attribute value or the speed attribute value equals 0. Else the FlowFiles are passed to the remaining processors.

![routeOnAttribute_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/routeOnAttribute_config_property_tab_window.png)

**Figure 9:** RouteOnAttribute Configuration Property Tab Window

2\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **unmatched** checkbox. Click **Apply**.

3\. Connect **RouteOnAttribute** to **AttributesToJSON** processor. When the Create Connection window appears, verify **Filter_Attributes** checkbox is checked, if not check it. Click Add.

### 4.2 AttributesToJSON

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 9 and if their original properties already have values, update them.

**Table 9:** Update AttributesToJSON Property Values

| Property  | Value  |
|:---|---:|
| `Attributes List`  | `Vehicle_ID, Direction_of_Travel, Latitude, Longitude, Vehicle_Speed, Last_Time`  |
| `Destination`  | flowfile-content  |

- **Attributes List** takes FlowFile attribute parameters and presents them in JSON format
- **Destination** stores the output as content in the FlowFile

![attributesToJSON_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/attributesToJSON_config_property_tab_window.png)

**Figure 10:** AttributesToJSON Configuration Property Tab Window

3\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** checkbox. Click **Apply**.

4\. Connect **AttributesToJSON** to **MergeContent** processor. When the Create Connection window appears, verify **success** checkbox is checked, if not check it. Click Add.

### 4.3 MergeContent

1\. Open the processor configuration **properties** tab. Add the properties listed in Table 10 and if their original properties already have values, update them.

**Table 10:** Update MergeContent Property Values

| Property  | Value  |
|:---|---:|
| `Minimum Number of Entries`  | `10`  |
| `Maximum Number of Entries`  | `15`  |
| `Delimiter Strategy`  | Text  |
| `Header`  | `[`  |
| `Footer`  | `]`  |
| `Demarcator` | `,` {now-press-shift-enter} |

- **Minimum Number of Entries** takes in at least specified amount of FlowFiles, then merges them into 1 FlowFiles
- **Maximum Number of Entries** takes in no more than specified amount of FlowFiles, then merges them
- **Delimiter Strategy** specifies that Header, Footer and Demarcator set the formatting conditions for text in the file
- **Header** inserts specified value at the beginning of the file
- **Footer** inserts specified value at the end of the file
- **Demarcator** inserts specified value(s) at the end of every line in the file

3\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **original** checkboxes. Click **Apply**.

4\. Connect **MergeContent** to **UpdateAttribute** processor. When the Create Connection window appears, verify **merged** checkbox is checked, if not check it. Click Add.

### 4.4 UpdateAttribute

1\. Add a new dynamic property for NiFi expression, click on the **New property** button. Insert the following property name and value into your properties tab as shown in the table below:

**Table 11:** Add UpdateAttribute Property Value

| Property  | Value  |
|:---|---:|
| `filename`  | `${UUID()}`  |

- **filename** updates each FlowFile with a unique identifier

![updateAttribute_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/updateAttribute_config_property_tab_window.png)

**Figure 7:** UpdateAttribute Configuration Property Tab Window

2\. Connect **UpdateAttribute** to **PutFile** processor. When the Create Connection window appears, verify **success** checkbox is checked, if not check it. Click Add.

### 4.5 PutFile

1\. Open the processor configuration **properties** tab. Add the property listed in Table 11 and if their original property already has a value, update it.

**Table 12:** Update PutFile Property Value

| Property  | Value  |
|:---|---:|
| `Directory`  | `/tmp/nifi/output/filtered_transitLoc_data`  |

![putFile_config_property_tab_window](assets/tutorial-1-build-a-simple-nifi-dataflow/putFile_config_property_tab_window.png)

**Figure 12:** PutFile Configuration Property Tab Window

3\. Open the processor config **Settings** tab, under Auto terminate relationships, check the **failure** and **success** checkboxes. Click **Apply**.

### Step 5: Run the NiFi DataFlow <a id="run-nifi-dataflow-tutorial1"></a>

1\. The processors are valid since the warning symbols disappeared. Notice that the processors have a red stop symbol ![stop_symbol_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/stop_symbol_nifi_iot.png) in the upper left corner and are ready to run. To select all processors, hold down the **shift-key** and drag your mouse across the entire data flow.

2\. Now that all processors are selected, go to the actions toolbar in the left window labeled Operate and click the start button ![start_button_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/start_button_nifi_iot.png). Your screen should look like the following:

![run_dataflow_lab1_nifi_learn_ropes](assets/tutorial-1-build-a-simple-nifi-dataflow/run_dataflow_lab1_nifi_learn_ropes.png)

3\. To quickly see what the processors are doing and the information on their faces, right click on the graph, click the **refresh status** button ![refresh_nifi_iot](assets/tutorial-1-build-a-simple-nifi-dataflow/refresh_nifi_iot.png)

There are two options for checking that the data stored in the destination is correct. Option 1 is to navigate by terminal to the folder where NiFi stores the data. Option 2 is to use Data Provenance to verify the data is correct.

### Check Data By Terminal (Option 1)

4\. To check that the data was written to a file, open your terminal or use NiFi's Data Provenance. Make sure to SSH into your sandbox. Navigate to the directory you wrote for the PutFile processor. List the files and open one of the newly created files to view filtered transit output. In the tutorial our directory path is: `/tmp/nifi/output/filtered_transitLoc_data`.

~~~
cd /tmp/nifi/output/filtered_transitLoc_data
ls
vi 19bad9c1-ae98-439f-8a8b-543fb3ab0ab0
~~~

![commands_enter_sandbox_shell_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/commands_enter_sandbox_shell_lab1.png)

![filtered_vehicle_locations_data_nifi_learn_ropes](assets/tutorial-1-build-a-simple-nifi-dataflow/filtered_vehicle_locations_data_nifi_learn_ropes.png)

> Note: to exit the vi editor, press `esc` and then type `:q`.

### Check Data By NiFi's Data Provenance (Option 2)

Data Provenance is a unique feature in NiFi that enables the user to check the data from any processor or component while the FlowFiles move throughout the dataflow. Data Provenance is a great tool for troubleshooting issues that may occur in the dataflow. In this section, we will check the Data Provenance for the PutFile processor.

1\. Right click on the PutFile processor. Select `Data Provenance`. It is the 4th item in the dropdown menu.

2\. NiFi will search for provenance events. The window will load with events, select any event. An event is a FlowFile that passes through a processor and the data that is viewable at that particular time. For the tutorial, let's select the first event by pressing on the view provenance event symbol ![i_symbol_nifi_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/i_symbol_nifi_lab1.png).

Provence Event Window:

![provenance_event_window_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/provenance_event_window_lab1.png)


3\. Once you select the event, a Provenance Event Dialog Window will appear. It contains Details, Attributes and Content regarding the particular event. Take a few minutes to view each tab. Let's navigate to the `Content` tab to view the data generated from the FlowFile. NiFi gives the user the option to download or view the content of the event. Click on the **View** button.

![provenance_content_tab_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/provenance_content_tab_lab1.png)

4\. NiFi gives the user the option view the data in multiple formats. We will view it in original format.

![event_content_view_window_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/event_content_view_window_lab1.png)

Did you receive the data you expected?

## Summary <a id="summary-tutorial1"></a>

Congratulations! You made it to the end of the tutorial and built a NiFi DataFlow that reads in a live stream simulation from NextBus.com, splits the parent’s children elements from the XML file into separate FlowFiles, extracts nodes from the XML file, makes a filtering decision on the attributes and stores that newly modified data into a file. You also learned how to use NiFi's Data Provenance feature to view data from a FlowFile that flows through a processor, a powerful feature that enables users to troubleshoot issues in real-time. Feel free to use this feature in the other tutorials. If you are interested in learning more about NiFi, view the following further reading section.

## Further Reading <a id="further-reading-tutorial1"></a>

-   [Apache NiFi](https://hortonworks.com/apache/nifi/)
-   [Hortonworks DataFlow Documentation](http://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.1.2/bk_dataflow-user-guide/content/ch_user-guide.html)
-   [NiFi Expression Language Guide](https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html)
-   [XPath Expression Tutorial](http://www.w3schools.com/xml/xpath_intro.asp)
-   [JSON Tutorial](https://www.w3schools.com/js/js_json_intro.asp)

## Appendix A: Review of the NiFi DataFlow <a id="appendix-a-review-dataflow"></a>

If you want a more in depth review of the dataflow we just built, read the information below, else continue onto the next tutorial.

Vehicle Location XML Simulation Section:
streams the contents of a file from local disk into NiFi, unpacks the zip file and transfers each file as a single FlowFile, controls the rate at which the data flows to the remaining part of the flow.

Extract Attributes From FlowFiles Section:
Splits XML message into many FlowFiles, updates each FlowFile filename attribute with unique name and User Defined XPath Expressions are evaluated against the XML Content to extract the values into user-named Attribute.

Filter Key Attributes to JSON File Section:
Routes FlowFile based on whether it contains all XPath Expressions (attributes) from the evaluation, writes JSON representation of input attributes to FlowFile as content, merges the FlowFiles by concatenating their content together into a single FlowFile and writes the contents of a FlowFile to a directory on the local filesystem.

## Appendix B: Create Labels for Processor Groups <a id="appendix-b-create-labels"></a>

NiFi DataFlows expand to become enormous pipelines to process data. In large dataflow, it can be difficult to understand what particular actions sections of the dataflow perform on data. Therefore, Labels can be used to make it easier for users to understand the different phases of the dataflow.

Let's create a label to signify the action that happens in the first phase of our dataflow.

1\. Drag the Label icon ![label_icon_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/label_icon_lab1.png) located in the components toolbar onto the canvas. To expand the label, hover toward the right corner, a arrow will appear, click on that edge and drag the label to surround the group of processors.

2\. Right click on the label, press configure. A Configure Label window will appear. Click in the Label Value field, type the name `Generate Vehicle Location XML Simulator` for the first phase of our dataflow. Choose `18px` for Font Size.

![label_first_phase_dataflow_lab1](assets/tutorial-1-build-a-simple-nifi-dataflow/label_first_phase_dataflow_lab1.png)

Reference the picture of the dataflow in Step 5 if you would like to assign similar labels used in the dataflow for this tutorial. Feel free to create your own as labels for each phase of the dataflow too.
