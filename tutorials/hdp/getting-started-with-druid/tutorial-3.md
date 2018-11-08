---
title: Loading Batch Data into Druid
---

# Loading Batch Data into Druid

## Introduction

You will learn to write a Hadoop-based Ingestion Spec and run the Ingestion Task with that specification to load the **wikiticker** data into Druid on HDP.

## Prerequisites

- Setup the Development Environment

## Outline

- [Step 1: Analyzing the Dataset](#step-1-analyzing-the-dataset)
- [Step 2: Writing an Ingestion Spec](#step-2-writing-an-ingestion-spec)
- [Step 3: Running the Task](#step-3-running-the-task)
- [Summary](#summary)
- [Further Reading](#Further-reading)
- [Appendix A: Breakdown of Ingestion Spec](#appendix-a-breakdown-of-ingestion-spec)

## Step 1: Analyzing the Dataset

### Wikiticker JSON Dataset

First we should understand the incoming rows of data from our `/usr/hdp/3.0.1.0-187/druid/quickstart/wikiticker-2015-09-12-sampled.json.gz` dataset.

~~~json
{
    "time":"2015-09-12T00:47:05.474Z",
    "channel":"#en.wikipedia",
    "cityName":"Auburn",
    "comment":"/* Status of peremptory norms under international law */ fixed spelling of 'Wimbledon'",
    "countryIsoCode":"AU",
    "countryName":"Australia",
    "isAnonymous":true,
    "isMinor":false,
    "isNew":false,
    "isRobot":false,
    "isUnpatrolled":false,
    "metroCode":null,
    "namespace":"Main",
    "page":"Peremptory norm",
    "regionIsoCode":"NSW",
    "regionName":"New South Wales",
    "user":"60.225.66.142",
    "delta":0,
    "added":0,
    "deleted":0
}
~~~

Every row in our dataset will have the same keys as above with different values. Let's separate our **timestamp** (unique-identifier attribute), **dimensions** (String-typed attributes) and **metrics** (numeric-typed attributes) into their own groups:

### timestamp

~~~json
"time"
~~~

Timestamp can be found in the **time** field. If your dataset doesn't have a time field, you can tag all rows with either a fixed timestamp "2000-01-01T00:00:00.000Z" or you can insert the current time using your favorite programming language.

### dimensions

~~~json
  "channel",
  "cityName",
  "comment",
  "countryIsoCode",
  "countryName",
  "isAnonymous",
  "isMinor",
  "isNew",
  "isRobot",
  "isUnpatrolled",
  "metroCode",
  "namespace",
  "page",
  "regionIsoCode",
  "regionName",
  "user"
~~~

The above keys all have String-typed values

### metrics

~~~json
{
  "name" : "count",
  "type" : "count"
},
{
  "name" : "added",
  "type" : "longSum",
  "fieldName" : "added"
},
{
  "name" : "deleted",
  "type" : "longSum",
  "fieldName" : "deleted"
},
{
  "name" : "delta",
  "type" : "longSum",
  "fieldName" : "delta"
},
{
  "name" : "user_unique",
  "type" : "hyperUnique",
  "fieldName" : "user"
}
~~~

Some useful metrics to aggregate in regards to our dataset will be the total number of rows in the dataset, so the **count**. Another useful metric will be to aggregate or collect all the the **added** keys, then compute their sum using Druid's longSum Aggregator API. We can find the sum for the **deleted** keys, then for the **delta** keys. Another metric that we can collect is the **user** key since each row has their own unique user field. At index time, the unique user keys will be aggregated to hyperUnique metric set.

Now that we analyzed our dataset and separated into **timestamp**, **dimensions** and **metrics** groups, this information can help us in writing the Druid Ingestion Spec.

## Step 2: Writing an Ingestion Spec

Open your HDP Web Shell Client at http://sandbox-hdp.hortonworks.com:4200

There are two approaches, you could go with **approach 1** and use wget to download the ingestion spec directly into sandbox or you could go with **approach 2** to copy the ingestion spec into the text editor.

### Approach 1: Download Ingestion Spec

~~~bash
wget https://raw.githubusercontent.com/hortonworks/data-tutorials/73dfff5c49d732c692d135cb6b572f6ec2783f73/tutorials/hdp/getting-started-with-druid/assets/druid-spec/wikiticker-index.json

mv wikiticker-index.json /tmp
~~~

Now you have the ingestion spec, jump to step 3.

### Approach 2: Manually Create Ingestion Spec

Create `/tmp/wikiticker-index.json` using the following command:

~~~bash
touch /tmp/wikiticker-index.json
~~~

Open it in your favorite editor and follow along with writing the Druid Hadoop-based Batch Ingestion Spec.

For example, if using vi editor:

~~~bash
vi /tmp/wikiticker-index.json
~~~

Copy and paste the following ingestion spec:

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        "type" : "hadoop",
        "inputSpec" : {
          "type" : "static",
          "paths" : "quickstart/wikiticker-2015-09-12-sampled.json.gz"
        }
      },      
      "tuningConfig" : {
        "type" : "hadoop",
        "partitionsSpec" : {
          "type" : "hashed",
          "targetPartitionSize" : 5000000
        },
        "jobProperties" : {}
      }
    }
}
~~~

You just finished writing the Druid Ingestion Spec.

### Saving the Ingestion Spec

1\. Save the ingestion spec file.

For example, with the file open in vi editor:

~~~bash
press "esc" to escape, then type ":wq" and press enter to quit and save the file.
~~~

We just wrote up our Hadoop-based Ingestion Spec, now we are ready to run it as a task.

## Step 3: Running the Task

We must make sure that our indexing task can read our **wikiticker-2015-09-12-sampled.json.gz** data on HDFS.

Since we installed Druid on HDP, it is connected to Hadoop, so we can upload wikiticker-2015-09-12-sampled.json.gz to HDFS.

1\. Let's create the following HDFS directory:

~~~bash
su druid
hdfs dfs -mkdir -p /user/druid/quickstart
~~~

2\. Let's upload the json data file to HDFS:

~~~bash
hdfs dfs -put /usr/hdp/3.0.1.0-187/druid/quickstart/wikiticker-2015-09-12-sampled.json.gz /user/druid/quickstart/
hdfs dfs -chmod -R 777 /user/druid
exit
~~~

3\. Let's kickoff the indexing process by sending a POST request to Druid Overlord:

~~~bash
curl -X 'POST' -H 'Content-Type:application/json' -d @/tmp/wikiticker-index.json http://sandbox-hdp.hortonworks.com:8090/druid/indexer/v1/task
~~~

Open Druid Overload at http://sandbox-hdp.hortonworks.com:8090/console.html. Task will appear under running tasks:

![wikiticker-running-tasks](assets/images/wikiticker-running-task.jpg)

> Note: It will take around 5 - 15 minutes for the task to complete.

If all goes well with this task, then it should finish with the **status SUCCEEDED** in Druid Overlord UI. Visit "Task log" to troubleshoot problems if anything goes wrong.

![wikiticker-completed-task](assets/images/wikiticker-completed-task.jpg)

Head to the Druid Coordinator UI at http://sandbox-hdp.hortonworks.com:8081/#/ and you should see the **wikipedia** datasource.

![wikipedia-datasource](assets/images/wikipedia-datasource.jpg)

## Summary

Congratulations! You learned to analyze your dataset to separate out the **timestamp**, **dimensions** and **metrics**, wrote a **Druid Ingestion Spec** utilizing the data found in the analysis of the dataset, submitted the spec to Druid Overlord to specify how you want the Hadoop-based index task to be configured when it is run and **ingested batch data into the Druid datastore**. In the next tutorial, you will learn to create json files to query the data in Druid.

## Further Reading

- [Loading Data into Druid](http://druid.io/docs/latest/tutorials/ingestion.html)
- [Load Your Own Batch Data into Druid](http://druid.io/docs/latest/tutorials/tutorial-batch.html)
- [Hadoop-Based Batch Ingestion Spec](http://druid.io/docs/latest/ingestion/batch-ingestion.html)
- [Druid Ingestion Spec](http://druid.io/docs/latest/ingestion/index.html)
- [Data Formats for Druid Data Ingestion](http://druid.io/docs/latest/ingestion/data-formats.html)
- [Introduction to Indexing, Aggregation and Querying in Druid](https://zcox.wordpress.com/2015/04/05/introduction-to-indexing-aggregation-and-querying-in-druid/)

## Appendix A: Breakdown of Ingestion Spec

### Hadoop-based Batch Ingestion

The Druid [Hadoop-based batch Ingestion Spec](http://druid.io/docs/latest/ingestion/batch-ingestion.html) will start with the **type** of Spec.

### Add "type"

~~~json
{
    "type" : "index_hadoop"
    ...
}
~~~

- **type** - establishes the type of ingestion task that should be run when our ingestion spec is submitted to Druid Overlord. In our case, since we are using Hadoop, we chose "index_hadoop". Thus, a hadoop-based ingestion task will be run.

### Add "spec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        ...        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

The Druid ingestion **[spec](http://druid.io/docs/latest/ingestion/index.html)** (hadoop-index, index, etc) includes 3 parts:

- **dataSchema(JSON Object)** - identifies the objects in the incoming data.

- **ioConfig(JSON Object)** - identifies the HDFS location of the source data. On HDP, the hadoop-index task will store data in the Druid warehouse by default, so you won't need to include the destination.

- **tuningConfig(JSON Object)** - specifies how to configure ingestion parameters.

### Add "dataSchema"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          ...
        },
        "metricsSpec" : [
          ...
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

The Druid **dataSchema** includes 4 fields:

- **dataSource(String)** - the name of the ingested data file and can be interpreted as a table. In our case, we are calling our dataSource by **wikiticker** cause that is the name of our dataset.

- **parser(JSON Object)** - identifies how ingested data can be analyzed into logical syntactic components (ex: string parser would analyze each row in the data file and find a list of strings separated by spaces, commas, etc).

- **metricsSpec** - a list of [aggregators](http://druid.io/docs/latest/querying/aggregations.html). An aggregator is way that information is gathered and then expressed in a summary form. Druid has multiple aggregators for gathering all sorts of data from the data file: such as row count, sum of values as a signed integer, min of all values, etc.

- **granularitySpec** - specifies how segments should be created and data should be rolled up.

### Add "dataSchema" -> "parser"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            ...
          }
        },
        "metricsSpec" : [
          ...
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

The Druid **parser** includes 2 fields:

- **type** - the type of parser to use, in the above code, we use **hadoopyString** Parser for our Hadoop indexing job.

- **parseSpec** - indentifies the format, timestamp and dimensions of the data.

### Add "dataSchema" -> "parser" -> "parseSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              ...
            },            
            "dimensionsSpec" : {
              ...
            }
          }
        },
        "metricsSpec" : [
          ...
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

The purpose of the **parseSpec** is to determine the format of incoming rows from the static data file. Since our data file is json, we use json format. The **parseSpec** also serves to find the timestamp and dimensions of incoming rows.

For the Druid **parseSpec**, we use 3 fields:

- **format** - specifies the data format type of our file, we select json for our format due to **wikiticker-2015-09-12-sampled.json.gz** being a json file. If format is not specified, by default it will set to tsv. **NOTE:** if your data file is in CSV or TSV and your file's first row doesn't have headers, then you will need to include a **columns** field in **parseSpec**.

- **timestampSpec** - identifies the column and format of the timestamp.

- **dimensionSpec** - indentifies the dimensions of the data. Dimensions are attributes we can filter and split on.

- **columns** - only needed for CSV and TSV data files. It tells Druid about the columns of the data.

### Add "dataSchema" -> "parser" -> "parseSpec" -> "timestampSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              ...
            }
          }
        },
        "metricsSpec" : [
          ...
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For the Druid **timestampSpec** field, we use 2 fields:

- **format** - specifies the format our timestamp is in. We chose **auto** format to automatically identify the timestamp.

- **column** - specifies the column the timestamp can be found in. In our case, we tell the parser to look at the **time** column to get the timestamp.

### Add "dataSchema" -> "parser" -> "parseSpec" -> "dimensionSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          ...
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For the Druid **dimensionSpec**, we use 1 field:

- **dimensions** - a list of String-typed **dimension schema** objects denoted by their particular name. If this is an empty array, Druid will treat all columns as String-typed dimension columns except for ones that were marked under timestamp and metrics.

In our case, we added

~~~json
"dimensions" : [
  "channel",
  "cityName",
  "comment",
  "countryIsoCode",
  "countryName",
  "isAnonymous",
  "isMinor",
  "isNew",
  "isRobot",
  "isUnpatrolled",
  "metroCode",
  "namespace",
  "page",
  "regionIsoCode",
  "regionName",
  "user"
]
~~~

into the dimensions field because these objects are denoted as String-typed in our **wikiticker-2015-09-12-sampled.json** dataset.

**Dimension Schema**

- the **dimensionSpec** from the dataSchema ingests all columns as Strings under the **dimensions** field.

### Add "dataSchema" -> "metricsSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          ...
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For the Druid **metricsSpec**, we use 3 **[aggregators](http://druid.io/docs/latest/querying/aggregations.html)**:

- **Count Aggregator** - counts the number of ingested rows of data

~~~json
{
    "_comment" : "definition of count aggregator"
    {
        "type" : "count",
        "name" : <output_name>
    }
}
~~~

- **longSum Aggregator** - calculates the sum of values as a 64 bit signed integer. **name** is the output name for the summed result and **fieldName** is the name of the metric column to sum over

~~~json
    "_comment" : "definition of longSum aggregator"
    {
        "type" : "longSum",
        "name" : <output_name>,
        "fieldName" : <metric_name>
    }
~~~

In our case we want to compute the sum of all our metric column **added** values from our **wikiticker-2015-09-12-sampled.json** dataset and then store the result into the output name **added**.

~~~json
    "_comment" : "from our json file, longSum aggregator"
    {
        "name" : "added",
        "type" : "longSum",
        "fieldName" : "added"
    }
~~~

The same idea can be applied to the **deleted** and **delta** metric column in which all deleted key values in our dataset are computed for the sum, then stored into the output name **deleted** and **delta**.

- **HyperUnique Aggregator** - computes the estimated number of elements that were added to a set gathered at "hyperUnique" metric at indexing time.

~~~json
    "_comment" : "definition of hyperUnique aggregator"
    {
        "type" : "hyperUnique",
        "name" : <output_name>,
        "fieldName" : <metric_name>
    }
~~~

In our case, we are estimating the number of unique **users** within the wikiticker dataset in each day period, then storing it into output name **user_unique**.

~~~json
    "_comment" : "from our json file, hyperUnique aggregator"
    {
        "name" : "user_unique",
        "type" : "hyperUnique",
        "fieldName" : "user"
    }
~~~

### Add "dataSchema" -> "granularitySpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        ...
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For the **granularitySpec**, we have 4 fields:

- **type** - specifies what type of interval segments will be generated. In our case, we set it to be **uniform**.

- **segmentGranularity** - specifies the granularity to create segments at. In our case, we specify segments will be created per day.

~~~json
"segmentGranularity" : "day"
~~~

- **queryGranularity** - minimum granularity capable of querying results and granularity of data inside the segment. Currently, we specified that there will not be a minimum granularity for querying results.

~~~json
"queryGranularity" : "none"
~~~

- **intervals** - specifies the intervals for raw data to be ingested. In our case, **"2015-09-12/2015-09-13"**, we specify data will be ingested just for 1 day period. If we change the interval, we can ingest data over the span of a 30 day period, etc.

~~~json
"intervals" : ["2015-09-12/2015-09-13"]
~~~

### Add "ioConfig"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        "type" : "hadoop",
        "inputSpec" : {
          ...
        }
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For the **ioConfig**, we have 2 fields:

- **type** - always should be hadoop. In our case,  since we are using hadoop-based batch ingestion.

- **inputSpec** - contains the location of where in HDFS to pull static data in from.

### Add "ioConfig" -> "inputSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        "type" : "hadoop",
        "inputSpec" : {
          "type" : "static",
          "paths" : "quickstart/wikiticker-2015-09-12-sampled.json.gz"
        }
      },      
      "tuningConfig" : {
        ...
      }
    }
}
~~~

For **inputSpec**, we use 2 fields:

- **type** - denotes the type of inputSpec in which the static path to the data files is provided. In our case, we chose

~~~json
"type" : "static"
~~~

- **paths** - are input paths indicating where in HDFS the raw data can be found

~~~json
"paths" : "quickstart/wikiticker-2015-09-12-sampled.json.gz"
~~~

If the path specified to the raw data does not exist in HDFS, then we will get an error once we submit the task, Druid overlord will return the task failed to be submitted. If it does not exist, then create it, else verify the path takes Druid to the raw data in HDFS.

### Add "tuningConfig"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        "type" : "hadoop",
        "inputSpec" : {
          "type" : "static",
          "paths" : "quickstart/wikiticker-2015-09-12-sampled.json.gz"
        }
      },      
      "tuningConfig" : {
        "type" : "hadoop",
        "partitionsSpec" : {
          ...
        },
        "jobProperties" : {
          ...  
        }
      }
    }
}
~~~

For **tuningConfig**, we use 3 fields:

- **type** - the type of environment in which tuning the ingestion spec will take place. In our case, we are using hadoop to ingest data into Druid, so we can tune configure it.

- **partitionsSpec** - specifies how to partition every bucket into segments. If this property is not included, no partitioning will occur.

- **jobProperties** - a list of properties to incorporate into the Hadoop job configuration

### Add "tuningConfig" -> "partitionsSpec"

~~~json
{
    "type" : "index_hadoop",
    "spec" : {
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "parser" : {
          "type" : "hadoopyString",
          "parseSpec" : {
            "format" : "json",
            "timestampSpec" : {
              "format" : "auto",
              "column" : "time"
            },            
            "dimensionsSpec" : {
              "dimensions" : [
                "channel",
                "cityName",
                "comment",
                "countryIsoCode",
                "countryName",
                "isAnonymous",
                "isMinor",
                "isNew",
                "isRobot",
                "isUnpatrolled",
                "metroCode",
                "namespace",
                "page",
                "regionIsoCode",
                "regionName",
                "user"
              ]
            }
          }
        },
        "metricsSpec" : [
          {
            "name" : "count",
            "type" : "count"
          },
          {
            "name" : "added",
            "type" : "longSum",
            "fieldName" : "added"
          },
          {
            "name" : "deleted",
            "type" : "longSum",
            "fieldName" : "deleted"
          },
          {
            "name" : "delta",
            "type" : "longSum",
            "fieldName" : "delta"
          },
          {
            "name" : "user_unique",
            "type" : "hyperUnique",
            "fieldName" : "user"
          }
        ],
        "granularitySpec" : {
          "type" : "uniform",
          "segmentGranularity" : "day",
          "queryGranularity" : "none",
          "intervals" : ["2015-09-12/2015-09-13"]
        }        
      },
      "ioConfig" : {
        "type" : "hadoop",
        "inputSpec" : {
          "type" : "static",
          "paths" : "quickstart/wikiticker-2015-09-12-sampled.json.gz"
        }
      },      
      "tuningConfig" : {
        "type" : "hadoop",
        "partitionsSpec" : {
          "type" : "hashed",
          "targetPartitionSize" : 5000000
        },
        "jobProperties" : {}
      }
    }
}
~~~

How are segments partitioned?

Segments are partitioned on a timestamp. Druid provides support for two types of partitioning: hashed and dimension. Hashed is based on the hash of all dimensions in every row while dimension has to do with ranges of a single dimension.

We use hash partitioning. An advantage by using this approach is that it improves indexing performance and it creates more uniformly sized data segments.

For **partitionsSpec**, we use 2 fields:

- **type** - partitionSpec type that will be used. We used **hashed** partitioning. Hash Partitioning means first the number of segments will be selected, then rows will be partitioned across those segments based on the hash of all dimensions in each row.

- **targetPartitionSize** - is the number of rows to include in a partition. We used 5000000 bytes, which is 5MB.
