---
title: Acquiring Twitter Data
---

# Acquiring Twitter Data

## Introduction

## Prerequisites

## Outline

- [Approach 1: Build a NiFi AcquireTwitterData Process Group](#approach-1-build-a-nifi-acquiretwitterdata-process-group)
- [Approach 2: Import NiFi AcquireTwitterData via UI](#approach-2-import-nifi-acquiretwitterdata-via-ui)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Approach 1: Build a NiFi AcquireTwitterData Process Group

After starting your sandbox, open HDF **NiFi UI** at `http://sandbox-hdf.hortonworks.com:9090/nifi`.

### Create AcquireTwitterData Process Group

Drop the process group icon ![process_group](assets/images/acquire-twitter-data/process_group.jpg) onto the NiFi canvas.

Insert the Process Group Name: `AcquireTwitterData` or one of your choice.

![acquiretwitterdata](assets/images/acquire-twitter-data/acquiretwitterdata.jpg)

Double click on the process group to dive into it. At the bottom of the canvas, you will see **NiFi Flow >> AcquireTwitterData** breadcrumb. Let's began connecting the processors for data ingestion, preprocessing and storage.

### Ingest Twitter Data Source

Drop the processor icon onto the NiFi canvas. Add the **GetTwitter**.

![gettwitter](assets/images/acquire-twitter-data/gettwitter.jpg)

Hold **control + mouse click** on **GetHTTP** to configure the processor:

**Table 1: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Name | GrabGardenHose |

**Table 2: Scheduling Tab**

| Scheduling     | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 3: Properties Tab**

| Property     | Value     |
| :------------| :---------|
| **Twitter Endpoint**  | `Filter Endpoint` |
| **Consumer Key**  | `<Your-Consumer-API-Key>` |
| **Consumer Secret**  | `<Your-Consumer-API-Secret-Key>` |
| **Access Token**  | `<Your-Access-Token>` |
| **Access Token Secret**  | `<Your-Access-Token-Secret>` |
| Terms to Filter On | `AAPL,ORCL,GOOG,MSFT,DELL` |

Click **APPLY**.

### Pull Key Attributes from JSON Content of FlowFile

Drop the processor icon onto the NiFi canvas. Add the **EvaluateJsonPath**.

Create connection between **GetTwitter** and **EvaluateJsonPath** processors. Hover
over **GetTwitter** to see arrow icon, press on processor and connect it to
**EvaluateJsonPath**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | success (**checked**) |

Click **ADD**.

![gettwitter_to_evaluatejsonpath](assets/images/acquire-twitter-data/gettwitter_to_evaluatejsonpath.jpg)

Configure **EvaluateJsonPath** processor:

**Table 4: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Name | `PullKeyAttributes` |
| Bulletin Level | ERROR |
| Automatically Terminate Relationships | failure (**checked**) |
| Automatically Terminate Relationships | unmatched (**checked**) |

**Table 5: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Concurrent Tasks       | `4`       |
| Run Schedule       | `1 sec`       |

**Table 6: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Destination**       | `flowfile-attribute` |
| twitter.handle       | `$.user.screen_name` |
| twitter.hashtags       | `$.entities.hashtags[0].text` |
| twitter.language       | `$.lang` |
| twitter.location       | `$.user.location` |
| twitter.msg       | `$.text` |
| twitter.time       | `$.created_at` |
| twitter.time_zone       | `$.user.time_zone` |
| twitter.tweet_id       | `$.id` |
| twitter.unixtime       | `$.timestamp_ms` |
| twitter.user       | `$.user.name` |

Click **APPLY**.

### Route FlowFiles Attributes Containing Non-Empty Tweets

Drop the processor icon onto the NiFi canvas. Add the **RouteOnAttribute**.

Create connection between **EvaluateJsonPath** and **RouteOnAttribute** processors. Hover
over **EvaluateJsonPath** to see arrow icon, press on processor and connect it to
**RouteOnAttribute**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | matched (**checked**) |

Click **ADD**.

![evaluatejsonpath_to_routeonattribute](assets/images/acquire-twitter-data/evaluatejsonpath_to_routeonattribute.jpg)

Configure **RouteOnAttribute** processor:

**Table 7: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Name | `FindOnlyTweets` |
| Automatically Terminate Relationships | unmatched (**checked**) |

**Table 8: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Concurrent Tasks       | `2`       |
| Run Schedule       | `1 sec`       |

**Table 9: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Routing Strategy**       | `Route to Property name` |
| tweet       | `${twitter.msg:isEmpty():not()}` |

Click **APPLY**.

### Stream Contents of FlowFile to Solr Update Handler

Drop the processor icon onto the NiFi canvas. Add the **PutSolrContentStream** processor.

Create connection between **RouteOnAttribute** and both **PutSolrContentStream** processors. Hover
over **RouteOnAttribute** to see arrow icon, press on processor and connect it to
**PutSolrContentStream**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | tweet (**checked**) |

Click **ADD**.

![routeonattribute_to_putsolr](assets/images/acquire-twitter-data/routeonattribute_to_putsolr.jpg)

Configure **PutSolrContentStream** processor for relationship connection **tweet**:

**Table 10: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Automatically Terminate Relationships | connection_failure (**checked**) |
| Automatically Terminate Relationships | failure (**checked**) |
| Automatically Terminate Relationships | success (**checked**) |

**Table 11: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 12: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Solr Type**       | `Cloud` |
| **Solr Location**       | `sandbox-hdp.hortonworks.com:2181/solr` |
| Collection       | `tweets` |
| Commit Within       | `1000` |
| f.1       | `id:/id` |
| f.2       | `text_t:/text` |
| f.3       | `screenName_s:/user/screen_name` |
| f.4       | `language_s:/lang` |
| f.5       | `twitter_created_at_dt:/created_at` |
| f.6       | `tag_ss:/entities/hashtags` |
| f.7       | `originalposter_s:/retweeted_status/user/screen_name` |
| f.8       | `source_s:/source` |
| f.9       | `geo_s:/geo` |
| f.10       | `coordinates_s:/coordinates` |
| f.11       | `place_s:/place` |
| split       | `/` |

Click **APPLY**.

### Search and Replace Content of FlowFile via Regex

Drop the processor icon onto the NiFi canvas. Add the **ReplaceText** processor.

Create connection between **RouteOnAttribute** and both **ReplaceText** processors. Hover
over **RouteOnAttribute** to see arrow icon, press on processor and connect it to
**ReplaceText**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | tweet (**checked**) |

Click **ADD**.

![routeonattribute_to_replacetext](assets/images/acquire-twitter-data/routeonattribute_to_replacetext.jpg)

Configure **ReplaceText** processor for relationship connection **tweet**:

**Table 13: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Automatically Terminate Relationships | failure (**checked**) |

**Table 14: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 15: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Search Value**       | `(?s:^(.*)$)` |
| **Replacement Value**       | `{"tweet_id":${twitter.tweet_id},"created_unixtime":${twitter.unixtime},"created_time":"${twitter.time}","lang":"${twitter.language}","displayname":"${twitter.handle}","time_zone":"${twitter.time_zone}","msg":"${twitter.msg:replaceAll('[$&+,:;=?@#|\'<>.^*()%!-]',''):replace('"',''):replace('\n','')}"}` |

Click **APPLY**.

### Merge FlowFiles Once a Set Number Has Accumulated

Drop the processor icon onto the NiFi canvas. Add the **MergeContent** processor.

Create connection between **ReplaceText** and both **MergeContent** processors. Hover
over **ReplaceText** to see arrow icon, press on processor and connect it to
**MergeContent**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | success (**checked**) |

Click **ADD**.

![replacetext_to_mergecontent](assets/images/acquire-twitter-data/replacetext_to_mergecontent.jpg)

Configure **MergeContent** processor:

**Table 16: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Automatically Terminate Relationships | failure (**checked**) |
| Automatically Terminate Relationships | original (**checked**) |

**Table 17: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 18: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Minimum Number of Entries**       | `20` |
| **Maximum Number of Entries**       | `1000` |
| Max Bin Age       | `120 seconds` |
| **Maximum number of Bins**       | `100` |

Click **APPLY**.

### Write Contents of FlowFile to Local File System

Drop the processor icon onto the NiFi canvas. Add the **PutFile** processor.

Create connection between **MergeContent** and both **PutFile** processors. Hover
over **MergeContent** to see arrow icon, press on processor and connect it to
**PutFile**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | merged (**checked**) |

Click **ADD**.

![mergecontent_to_putfile](assets/images/acquire-twitter-data/mergecontent_to_putfile.jpg)

Configure **PutFile** processor:

**Table 19: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Automatically Terminate Relationships | failure (**checked**) |
| Automatically Terminate Relationships | success (**checked**) |

**Table 20: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 21: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| **Directory**       | `/sandbox/tutorial-files/770/nifi/output/tweets` |

Click **APPLY**.

### Update Merged FlowFile Attribute Name

Drop the processor icon onto the NiFi canvas. Add the **UpdateAttribute** processor.

Create connection between **MergeContent** and both **UpdateAttribute** processors. Hover
over **MergeContent** to see arrow icon, press on processor and connect it to
**UpdateAttribute**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | merged (**checked**) |

Click **ADD**.

![mergecontent_to_updateattribute](assets/images/acquire-twitter-data/mergecontent_to_updateattribute.jpg)

Configure **UpdateAttribute** processor:

**Table 22: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 23: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| filename      | `tweets-${now():format("HHmmssSSS")}.json` |

Click **APPLY**.

### Write Contents of FlowFile to Hadooop Distributed File System

Drop the processor icon onto the NiFi canvas. Add the **PutHDFS** processor.

Create connection between **UpdateAttribute** and both **PutHDFS** processors. Hover
over **UpdateAttribute** to see arrow icon, press on processor and connect it to
**PutHDFS**.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | success (**checked**) |

Click **ADD**.

![updateattribute_to_puthdfs](assets/images/acquire-twitter-data/updateattribute_to_puthdfs.jpg)

Configure **PutHDFS** processor:

**Table 24: Settings Tab**

| Setting | Value     |
| :------------- | :------------- |
| Automatically Terminate Relationships | success (**checked**) |

**Table 25: Scheduling Tab**

| Scheduling | Value     |
| :------------- | :------------- |
| Run Schedule       | `1 sec`       |

**Table 26: Properties Tab**

To add a new user defined property in case one the following properties in the
table isn't defined, press the plus button **+**.

| Property | Value     |
| :------------- | :------------- |
| Hadoop Configuration Resources       | `/etc/hadoop/conf/core-site.xml,/etc/hadoop/conf/hdfs-site.xml` |
| **Directory**       | `/sandbox/tutorial-files/770/hive/tweets_staging` |
| **Conflict Resolution Strategy**       | `replace` |
| Replication       | `1` |

Click **APPLY**.

Create connection between **PutHDFS** and itself. Hover
over **PutHDFS** to see arrow icon, press on processor and connect it to itself.

Configure Create Connection:

| Connection | Value     |
| :------------- | :------------- |
| For Relationships     | failure (**checked**) |

Click **ADD**.

### Start Process Group Flow to Acquire Data

At the breadcrumb, select **NiFi Flow** level. Hold **control + mouse click** on the **AcquireTwitterData** process group, then click the **start** option.

![started_acquiretwitterdata_pg](assets/images/acquire-twitter-data/started_acquiretwitterdata_pg.jpg)

Once NiFi writes your sensor data to HDFS, which you can check by viewing data provenance, you can turn off the process group by holding **control + mouse click** on the **AcquireTwitterData** process group, then choose **stop** option.

### Verify NiFi Stored Data

Enter the **AcquireTwitterData** process group, press **control + mouse click** on PutHDFS processor of your choice, then press **View data provenance**.

![nifi_data_provenance](assets/images/acquire-twitter-data/nifi_data_provenance.jpg)

Press on **i** icon on the left row to view details about a provenance event. Choose the event with the type **SEND**. In the Provenance Event window, choose **CONTENT** tab. On **Output Claim**, choose **VIEW**.

![provenance_event](assets/images/acquire-twitter-data/provenance_event.jpg)

You will be able to see the data NiFi sent to the external process HDFS. The data below shows hvac_temperature dataset.

![view_event_hvac_temperature](assets/images/acquire-twitter-data/view_event_hvac_temperature.jpg)


## Approach 2: Import NiFi AcquireTwitterData via UI

## Summary

## Further Reading

- [NiFi User Guide](https://nifi.apache.org/docs/nifi-docs/html/user-guide.html)
