---
title: Querying Data from Druid
---

# Querying Data from Druid

## Introduction

## Outline

- Query Data with JSON-based Queries
- Step 1: Write a TopN Query for the Most-edited Articles
- Step 2: Save the Query into a file
- Summary
- Further Reading
- Appendix A: Use Druid's other Query Types
- Appendix A: Further Reading

## Query Data with JSON-based Queries

The process of querying the Druid database for information you want is done in a few steps:

- Choose one of [Druid's available queries](http://druid.io/docs/latest/querying/querying.html) for your use case:
    - Aggregation Queries, Metadata Queries, Search Queries

- Construct your JSON-based Query
- Send a POST Request to Druid Coordinator to execute your Query Request

## Step 1: Write a TopN Query for the Most-edited Articles

1\. We will construct a JSON-based TopN Query. Open your favorite text editor (atom, ms visual studio code, sublime, etc)

### Complete JSON-based Query

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  "dimension" : "page",
  "metric" : "edits",
  "threshold" : 25,
  "aggregations" : [
    {
      "type" : "longSum",
      "name" : "edits",
      "fieldName" : "count"
    }
  ]
}
~~~

### Analysis of the JSON Query

Let's breakdown this JSON query to understand what is happening.

### queryType: TopN

The "query type" we selected to query Druid is the aggregation query:

~~~json
{
  "queryType" : "topN",
  ...
}
~~~

- **queryType** - Druid looks at this parameter to understand how to interpret the query

- **topN** - each node will rank their top K result and return only the top K results to the [Druid-broker component](http://sandbox-hdp.hortonworks.com:8080/#/main/services/DRUID/summary) (you can see it from Ambari Druid Service). We will see more of what this means as we construct more of the query.

### dataSource: wikiticker

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  ...
}
~~~

- **dataSource** - the name of the "data source" (similar to table in relational databases) you want to query

### intervals: ["2015-09-12/2015-09-13"]

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  ...
}
~~~

- **intervals** - specifies the time ranges to run the query over. In our case, we are running the query over a span of one whole day from 2015-09-12 to 2015-09-13.

### granularity: "all"

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  ...
}
~~~

- **granularity** - defines the how data gets bucked across the time dimension. In our case, we selected `all`, so we will get all the results combined into one bucket.

### dimension: "page"

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  "dimension" : "page",
  ...
}
~~~

- **dimension** - specifies the String or JSON object we are going to query the dataSources for. In our case, we are querying "page" column.

In the next part of the query, we will see what metric we are querying the "page" for.

### metric: "edits"

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  "dimension" : "page",
  "metric" : "edits",
  ...
}
~~~

- **metric** - specifies the String or JSON Object to sort by for the top list. In our cas, we are sorting by the JSON object "edits" to find the top list of page "edits". If you look in the dataSource, you will see it appears Druid is collecting everytime the String "edits" appear in the JSON Object "comment" found in each row and pairing it with the appropriate page that was edited.

### threshold: 25

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  "dimension" : "page",
  "metric" : "edits",
  "threshold" : 25,
  ...
}
~~~

- **threshold** - an integer that defines the maximum number of items `N` to return after topN list is computed.

### aggregations

~~~json
{
  "queryType" : "topN",
  "dataSource" : "wikiticker",
  "intervals" : ["2015-09-12/2015-09-13"],
  "granularity" : "all",
  "dimension" : "page",
  "metric" : "edits",
  "threshold" : 25,
  "aggregations" : [
    {
      "type" : "longSum",
      "name" : "edits",
      "fieldName" : "count"
    }
  ]
}
~~~

- **aggregations** - specifies the type of aggregators or mathematical computations to perform on specific JSON objects or count the number of rows for the entire dataSource

- **longSum Aggregator** - specified we want to compute the longSum or the sum of all page "edits" and store the result into output JSON Object "count".

Thus, for every page, there will be a result for the number of edits for that page. The query will return the top 25 pages with the most page edits from the "wikiticker" dataSource.

## Step 2: Save the Query into a file

2\. Open Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200/`. Login credentials are root and the password you set for ssh access.

3\. Open your favorite text editor in the sandbox web shell and copy/paste the complete JSON-based query into it. We will use vi editor:

~~~bash
mkdir -p /tmp/sandbox/tutorial-files/900/druid/query

vi /tmp/sandbox/tutorial-files/900/druid/query/wikiticker-top-pages.json
~~~

4\. Inside vi, press **i** to insert text, then copy/paste the query.

5\. Press **esc**, then **:wq** to save and quit the file.

6\. Submit JSON Query to Druid Coordinator over HTTP POST request for that query to be issued to the Druid-broker node to search the dataSource for the most-edited articles

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/tmp/sandbox/tutorial-files/900/druid/query/wikiticker-top-pages.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

The output you should see from the POST request by the Druid Coordinator is:

~~~bash
[ {
  "timestamp" : "2015-09-12T00:46:58.771Z",
  "result" : [ {
    "edits" : 33,
    "page" : "Wikipedia:Vandalismusmeldung"
  }, {
    "edits" : 28,
    "page" : "User:Cyde/List of candidates for speedy deletion/Subpage"
  }, {
    "edits" : 27,
    "page" : "Jeremy Corbyn"
  }, {
    "edits" : 21,
    "page" : "Wikipedia:Administrators' noticeboard/Incidents"
  }, {
    "edits" : 20,
    "page" : "Flavia Pennetta"
  }, {
    "edits" : 18,
    "page" : "Total Drama Presents: The Ridonculous Race"
  }, {
    "edits" : 18,
    "page" : "User talk:Dudeperson176123"
  }, {
    "edits" : 18,
    "page" : "Wikipédia:Le Bistro/12 septembre 2015"
  }, {
    "edits" : 17,
    "page" : "Wikipedia:In the news/Candidates"
  }, {
    "edits" : 17,
    "page" : "Wikipedia:Requests for page protection"
  }, {
    "edits" : 16,
    "page" : "Utente:Giulio Mainardi/Sandbox"
  }, {
    "edits" : 16,
    "page" : "Wikipedia:Administrator intervention against vandalism"
  }, {
    "edits" : 15,
    "page" : "Anthony Martial"
  }, {
    "edits" : 13,
    "page" : "Template talk:Connected contributor"
  }, {
    "edits" : 12,
    "page" : "Chronologie de la Lorraine"
  }, {
    "edits" : 12,
    "page" : "Wikipedia:Files for deletion/2015 September 12"
  }, {
    "edits" : 12,
    "page" : "Гомосексуальный образ жизни"
  }, {
    "edits" : 11,
    "page" : "Constructive vote of no confidence"
  }, {
    "edits" : 11,
    "page" : "Homo naledi"
  }, {
    "edits" : 11,
    "page" : "Kim Davis (county clerk)"
  }, {
    "edits" : 11,
    "page" : "Vorlage:Revert-Statistik"
  }, {
    "edits" : 11,
    "page" : "Конституция Японской империи"
  }, {
    "edits" : 10,
    "page" : "The Naked Brothers Band (TV series)"
  }, {
    "edits" : 10,
    "page" : "User talk:Buster40004"
  }, {
    "edits" : 10,
    "page" : "User:Valmir144/sandbox"
  } ]
} ][root@sandbox-hdp ~]#
~~~

In the above query results at **timestamp** `2015-09-12T00:46:58.771Z`: we can see various Wikipedia pages in ascending order for their number of page edits.

If we look at the first entry returned,
we see that Wikipedia page **Wikipedia:Vandalismusmeldung** has 33 edits.

Similarily if we move to the 25th entry, we can see that **User:Valmir144/sandbox** has 10 edits.

## Summary

Congratulations! You just learned to write a JSON-based TopN query to search for the top Wikipedia page edits in our `wikiticker` dataSource.

Feel free to check out the appendix for more examples on how to query the dataSource using other Aggregation Queries, Metadata Queries and Search Queries.

## Further Reading

- [Druid Quickstart: Direct Druid queries](http://druid.io/docs/latest/tutorials/quickstart.html)
- [Druid Querying](http://druid.io/docs/latest/querying/querying.html)
- [TopN queries](http://druid.io/docs/latest/querying/topnquery.html)
- [Aggregation Granularity](http://druid.io/docs/latest/querying/granularities.html)

## Appendix A: Use Druid's other Query Types

Earlier, we learned how to write a JSON-based **TopN** aggregation query to retrieve most edited Wikipedia pages from our `wikiticker` dataSource.

### Wikiticker JSON Dataset

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

In case you may need to use Druid's other query types: Select, Aggregation, Metadata and Search, we put together a summarization of what the query does, an example that can query the `wikiticker` dataSource and the results from after the query is executed.

### Select Query

### Select

~~~json
{
  "queryType": "select",
  "dataSource": "wikiticker",
  "dimensions": [],
  "metrics": [],
  "intervals": [
    "2015-09-12/2015-09-13"
  ],
  "granularity": "all",
  "pagingSpec": {
    "pagingIdentifiers": {},
    "threshold": 5
  }
}
~~~

Returns the "5" rows of data from the Druid dataSource "wikiticker".

1\. Open your favorite text editor in the Sandbox Web Shell client: `http://sandbox-hdf.hortonworks.com:4200/`. Login Credentials are root and the password you chose.

2\. We will use the vi editor to copy/paste the JSON query into a file called `wiki-select.json`.

~~~bash
vi wiki-select.json
~~~

3\. Save and the quit the file, if using vi, then enter the command:

~~~bash
:wq
~~~

4\. Send the JSON-based Query to the Druid Coordinator over HTTP POST request:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-select.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

Output result after Select query should be similar as below:

~~~
[ {
  "timestamp" : "2015-09-12T00:46:58.771Z",
  "result" : {
    "pagingIdentifiers" : {
      "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z" : 4
    },
    "dimensions" : [ "isRobot", "countryIsoCode", "regionName", "channel", "isUnpatrolled", "isNew", "isMinor", "isAnonymous", "cityName", "metroCode", "namespace", "comment", "countryName", "page", "user", "regionIsoCode" ],
    "metrics" : [ "deleted", "added", "count", "delta", "user_unique" ],
    "events" : [ {
      "segmentId" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
      "offset" : 0,
      "event" : {
        "timestamp" : "2015-09-12T00:46:58.771Z",
        "channel" : "#en.wikipedia",
        "cityName" : null,
        "comment" : "added project",
        "countryIsoCode" : null,
        "countryName" : null,
        "isAnonymous" : "false",
        "isMinor" : "false",
        "isNew" : "false",
        "isRobot" : "false",
        "isUnpatrolled" : "false",
        "metroCode" : null,
        "namespace" : "Talk",
        "page" : "Talk:Oswald Tilghman",
        "regionIsoCode" : null,
        "regionName" : null,
        "user" : "GELongstreet",
        "deleted" : 0,
        "added" : 36,
        "count" : 1,
        "delta" : 36,
        "user_unique" : "AQAAAQAAAAOmEA=="
      }
    }, {
      "segmentId" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
      "offset" : 1,
      "event" : {
        "timestamp" : "2015-09-12T00:47:00.496Z",
        "channel" : "#ca.wikipedia",
        "cityName" : null,
        "comment" : "Robot inserta {{Commonscat}} que enllaça amb [[commons:category:Rallicula]]",
        "countryIsoCode" : null,
        "countryName" : null,
        "isAnonymous" : "false",
        "isMinor" : "true",
        "isNew" : "false",
        "isRobot" : "true",
        "isUnpatrolled" : "false",
        "metroCode" : null,
        "namespace" : "Main",
        "page" : "Rallicula",
        "regionIsoCode" : null,
        "regionName" : null,
        "user" : "PereBot",
        "deleted" : 0,
        "added" : 17,
        "count" : 1,
        "delta" : 17,
        "user_unique" : "AQAAAQAAAADsAQ=="
      }
    }, {
      "segmentId" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
      "offset" : 2,
      "event" : {
        "timestamp" : "2015-09-12T00:47:05.474Z",
        "channel" : "#en.wikipedia",
        "cityName" : "Auburn",
        "comment" : "/* Status of peremptory norms under international law */ fixed spelling of 'Wimbledon'",
        "countryIsoCode" : "AU",
        "countryName" : "Australia",
        "isAnonymous" : "true",
        "isMinor" : "false",
        "isNew" : "false",
        "isRobot" : "false",
        "isUnpatrolled" : "false",
        "metroCode" : null,
        "namespace" : "Main",
        "page" : "Peremptory norm",
        "regionIsoCode" : "NSW",
        "regionName" : "New South Wales",
        "user" : "60.225.66.142",
        "deleted" : 0,
        "added" : 0,
        "count" : 1,
        "delta" : 0,
        "user_unique" : "AQAAAQAAAAEhAQ=="
      }
    }, {
      "segmentId" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
      "offset" : 3,
      "event" : {
        "timestamp" : "2015-09-12T00:47:08.770Z",
        "channel" : "#vi.wikipedia",
        "cityName" : null,
        "comment" : "fix Lỗi CS1: ngày tháng",
        "countryIsoCode" : null,
        "countryName" : null,
        "isAnonymous" : "false",
        "isMinor" : "true",
        "isNew" : "false",
        "isRobot" : "true",
        "isUnpatrolled" : "false",
        "metroCode" : null,
        "namespace" : "Main",
        "page" : "Apamea abruzzorum",
        "regionIsoCode" : null,
        "regionName" : null,
        "user" : "Cheers!-bot",
        "deleted" : 0,
        "added" : 18,
        "count" : 1,
        "delta" : 18,
        "user_unique" : "AQAAAQAAAAK8Aw=="
      }
    }, {
      "segmentId" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
      "offset" : 4,
      "event" : {
        "timestamp" : "2015-09-12T00:47:11.862Z",
        "channel" : "#vi.wikipedia",
        "cityName" : null,
        "comment" : "clean up using [[Project:AWB|AWB]]",
        "countryIsoCode" : null,
        "countryName" : null,
        "isAnonymous" : "false",
        "isMinor" : "false",
        "isNew" : "false",
        "isRobot" : "true",
        "isUnpatrolled" : "false",
        "metroCode" : null,
        "namespace" : "Main",
        "page" : "Atractus flammigerus",
        "regionIsoCode" : null,
        "regionName" : null,
        "user" : "ThitxongkhoiAWB",
        "deleted" : 0,
        "added" : 18,
        "count" : 1,
        "delta" : 18,
        "user_unique" : "AQAAAQAAAABSEA=="
      }
    } ]
  }
~~~

### Aggregation Queries

### Timeseries

- **timeseries query** measures how things change over time in which **time** is the primary axis.

**What does the time-series query track?**

It tracks changes to the JSON Object or String as inserts. So if we use time-series query to track page edits, now we can measure how it changes in the past, monitor how it is changing in the present and predict how it may change in the future.

**Timeseries Query Question to be Answered**

- What is the total number of Wikipedia page edits per hour?

~~~json
{
  "queryType": "timeseries",
  "dataSource": "wikiticker",
  "descending": "true",
  "granularity": "hour",
  "aggregations": [
    {
      "type": "longSum",
      "name": "edits",
      "fieldName": "count"
    }
  ],
  "intervals": [
    "2015-09-12/2015-09-13"
  ]
}
~~~

In the span of 24 hour interval, this query will count the total page edits per hour and store the result into variable "edits."

1\. Open your favorite text editor in the Sandbox Web Shell client: `http://sandbox-hdf.hortonworks.com:4200/`. Login Credentials are root and the password you chose.

2\. We will use the vi editor to copy/paste the JSON query into a file called `wiki-timeseries.json`.

~~~bash
vi wiki-timeseries.json
~~~

3\. Save and the quit the file, if using vi, then enter the command:

~~~bash
:wq
~~~

4\. Send the JSON-based Query to the Druid Coordinator over HTTP POST request:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-timeseries.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

The result shows the total page edits for each hour:

~~~json
[ {
  "timestamp" : "2015-09-12T23:00:00.000Z",
  "result" : {
    "edits" : 1482
  }
}, {
  "timestamp" : "2015-09-12T22:00:00.000Z",
  "result" : {
    "edits" : 1590
  }
}, {
  "timestamp" : "2015-09-12T21:00:00.000Z",
  "result" : {
    "edits" : 1766
  }
}, {
  "timestamp" : "2015-09-12T20:00:00.000Z",
  "result" : {
    "edits" : 1832
  }
}, {
  "timestamp" : "2015-09-12T19:00:00.000Z",
  "result" : {
    "edits" : 2013
  }
}, {
  "timestamp" : "2015-09-12T18:00:00.000Z",
  "result" : {
    "edits" : 2170
  }
}, {
  "timestamp" : "2015-09-12T17:00:00.000Z",
  "result" : {
    "edits" : 2300
  }
}, {
  "timestamp" : "2015-09-12T16:00:00.000Z",
  "result" : {
    "edits" : 1959
  }
}, {
  "timestamp" : "2015-09-12T15:00:00.000Z",
  "result" : {
    "edits" : 1965
  }
}, {
  "timestamp" : "2015-09-12T14:00:00.000Z",
  "result" : {
    "edits" : 1873
  }
}, {
  "timestamp" : "2015-09-12T13:00:00.000Z",
  "result" : {
    "edits" : 2073
  }
}, {
  "timestamp" : "2015-09-12T12:00:00.000Z",
  "result" : {
    "edits" : 1709
  }
}, {
  "timestamp" : "2015-09-12T11:00:00.000Z",
  "result" : {
    "edits" : 1624
  }
}, {
  "timestamp" : "2015-09-12T10:00:00.000Z",
  "result" : {
    "edits" : 1792
  }
}, {
  "timestamp" : "2015-09-12T09:00:00.000Z",
  "result" : {
    "edits" : 1704
  }
}, {
  "timestamp" : "2015-09-12T08:00:00.000Z",
  "result" : {
    "edits" : 1622
  }
}, {
  "timestamp" : "2015-09-12T07:00:00.000Z",
  "result" : {
    "edits" : 2237
  }
}, {
  "timestamp" : "2015-09-12T06:00:00.000Z",
  "result" : {
    "edits" : 2120
  }
}, {
  "timestamp" : "2015-09-12T05:00:00.000Z",
  "result" : {
    "edits" : 1260
  }
}, {
  "timestamp" : "2015-09-12T04:00:00.000Z",
  "result" : {
    "edits" : 824
  }
}, {
  "timestamp" : "2015-09-12T03:00:00.000Z",
  "result" : {
    "edits" : 815
  }
}, {
  "timestamp" : "2015-09-12T02:00:00.000Z",
  "result" : {
    "edits" : 1102
  }
}, {
  "timestamp" : "2015-09-12T01:00:00.000Z",
  "result" : {
    "edits" : 1144
  }
}, {
  "timestamp" : "2015-09-12T00:00:00.000Z",
  "result" : {
    "edits" : 268
  }
} ]
~~~

From the result, we see for every hour within the interval specified in our query, a count for all page edits is taken and the sum is stored into the field name "edits" for each hour.

In a relational database scenario, the database would need to scan over all rows and then count them at query time. However with Druid, at indexing time, we already specified our count aggregation, so when Druid performs a query that needs this aggregation, Druid just returns the count.

### Enrich Query with Selector Filter

Now coming back to the previous result, what if we wanted to get insight about how page edits happened for Wiki pages in Australia, we would write the following query `wiki-enrich-timeseries.json`:

~~~json
{
  "queryType": "timeseries",
  "dataSource": "wikiticker",
  "descending": "true",
  "filter": {
    "type": "selector",
    "dimension": "countryName",
    "value": "Australia"
  },
  "granularity": "hour",
  "aggregations": [
    {
      "type": "longSum",
      "name": "edits",
      "fieldName": "count"
    }
  ],
  "intervals": [
    "2015-09-12/2015-09-13"
  ]
}
~~~

Feel free to test it in your Sandbox web shell client. You will probably notice some page edits per hour show up as null, which occurs since Wiki page edits related to Australia were not edited.

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-enrich-timeseries.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

### GroupBy

- **GroupBy query** - used when you want to group multiple dimensions (JSON Objects or Strings) from the dataSource together to answer a question(s)

**GroupBy Query Question to be Answered**

- In Australia, who were the "users", which "pages" did they edit and how many "edits" did they make?

Name of the GroupBy query: `wiki-groupby.json`.

~~~json
{
  "queryType": "groupBy",
  "dataSource": "wikiticker",
  "granularity": "hour",
  "dimensions": [
    "page", "user"
  ],
  "filter": {
    "type": "selector",
    "dimension": "countryName",
    "value": "Australia"
  },  
  "aggregations": [
    {
      "type": "longSum",
      "name": "edits",
      "fieldName": "count"
    }
  ],
  "intervals": [
    "2015-09-12/2015-09-13"
  ]
}
~~~

- **"queryType": "groupBy"** - specifies you want Druid to run the groupBy query type
- **"dataSource": "wikiticker"** - specifies the `wikiticker` set of data will be queried (like a table in relational database)
- **"granularity": "hour"** - specifies the data will be queried in hour intervals
- **"dimensions": [ "page", "user" ]** - specifies the groupBy action will be performed on `page and user` dimensions
- **filter** - specifies a filter to use only certain fields in the query
  - **"type": "selector"** - matches a specific dimension with a expected value, Equivalent Ex: `WHERE <dimension_string> = '<expected_dimension_value>`
  - **"dimension": "countryName"** - specifies the JSON Object or String from the dataSource you want to select
  - **"value": "Australia"** - specifies the specific dimension value you want to match with your dimension
- **"aggregations"** - specifies a particular computation to perform on a metric (JSON Object with numeric value) of your dataSource
    - **"type": "longSum"** - specifies you want to compute sum of a particular field's value within the dataSource
    - **"name": "edits"** - states the result from the computed sum will be stored in a JSON Object called "edits"
    - **"fieldName": "count"** - specifies the metric variable "count" value will be computed for the sum
- **"intervals"** - defines the time ranges to run the query over
    - **"2015-09-12/2015-09-13"** - a JSON Object represented across a 1 day time period (ISO-8601)

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-groupby.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

Feel free to run the query in the sandbox web shell client. Heres an example of output you would see:

~~~json
[ {
  "version" : "v1",
  "timestamp" : "2015-09-12T00:00:00.000Z",
  "event" : {
    "page" : "Peremptory norm",
    "user" : "60.225.66.142",
    "edits" : 1
  }
}, {
  "version" : "v1",
  "timestamp" : "2015-09-12T01:00:00.000Z",
  "event" : {
    "page" : "2015 Roger Federer tennis season",
    "user" : "14.201.22.221",
    "edits" : 1
  }
},
...
~~~

Notice how we extracted `page` and `user` into our JSON output using the GroupBy query. We just brought more insight to which page was edited, who did it and how many times they changed something.

### Metadata Queries

### Time Boundary

- **time boundary query** - used when you want to return the earliest and latest data points of a data source

~~~json
{
  "queryType": "timeBoundary",
  "dataSource": "wikiticker"
}
~~~

- **"queryType": "timeBoundary"** - specifies you want Druid to run the timeBoundary query type

Run the query `wiki-timeboundary-query.json` in sandbox web shell client:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-timeboundary-query.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

You should see similar output:

~~~json
[ {
  "timestamp" : "2015-09-12T00:46:58.771Z",
  "result" : {
    "maxTime" : "2015-09-12T23:59:59.200Z",
    "minTime" : "2015-09-12T00:46:58.771Z"
  }
} ]
~~~

As you can see the query returns the earliest and latest changes that were made in the data set.

### Segment Metadata

- **segment metadata queries** - returns per-segment information. Some data one may find is the uniqueness of data values in all columns in the segment, min/max values of string type columns, number of rows stored in the segment, segment id, etc.

~~~json
{
  "queryType": "segmentMetadata",
  "dataSource": "wikiticker",
  "intervals": [ "2015-09-12/2015-09-13" ]
}
~~~

Analysis of the above query:

- **"queryType": "segmentMetadata"** - specifies you want Druid to run the segmentMetadata query type
- **"dataSource": "wikiticker"** - specifies the `wikiticker` set of data will be queried
- **"intervals": [ "2015-09-12/2015-09-13" ]** - defines a 1 day time range to run the query over

Run the query `wiki-segment-query.json` in sandbox web shell client:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-segment-query.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

You should see similar output:

~~~json
[ {
  "id" : "wikiticker_2015-09-12T00:00:00.000Z_2015-09-13T00:00:00.000Z_2018-03-30T04:35:10.367Z",
  "intervals" : [ "2015-09-12T00:00:00.000Z/2015-09-13T00:00:00.000Z" ],
  "columns" : {
    "__time" : {
      "type" : "LONG",
      "hasMultipleValues" : false,
      "size" : 0,
      "cardinality" : null,
      "minValue" : null,
      "maxValue" : null,
      "errorMessage" : null
    },
    "added" : {
      "type" : "LONG",
      "hasMultipleValues" : false,
      "size" : 0,
      "cardinality" : null,
      "minValue" : null,
      "maxValue" : null,
      "errorMessage" : null
    },
    "channel" : {
      "type" : "STRING",
      "hasMultipleValues" : false,
      "size" : 0,
      "cardinality" : 51,
      "minValue" : "#ar.wikipedia",
      "maxValue" : "#zh.wikipedia",
      "errorMessage" : null
    },
    "cityName" : {
      "type" : "STRING",
      "hasMultipleValues" : false,
      "size" : 0,
      "cardinality" : 1006,
      "minValue" : "",
      "maxValue" : "Ōita",
      "errorMessage" : null
    },
    ...
  },
  "size" : 0,
  "numRows" : 39244,
  "aggregators" : null,
  "timestampSpec" : null,
  "queryGranularity" : null,
  "rollup" : null
}
~~~

In your console output, notice how all the metadata regarding each column is output onto the screen.

### Datasource Metadata

- **datasource metadata query** - returns metadata of the data source

~~~json
{
  "queryType": "dataSourceMetadata",
  "dataSource": "wikiticker"
}
~~~

Run the query `wiki-datasource-query.json` in sandbox web shell client:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-datasource-query.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

You should see output similar to the following data:

~~~json
[ {
  "timestamp" : "2015-09-12T23:59:59.200Z",
  "result" : {
    "maxIngestedEventTime" : "2015-09-12T23:59:59.200Z"
  }
} ]
~~~

**What kind of information does this query return?**

We can see a **timestamp** of the latest ingested event for the data source.

NOTE: this ingested event does not take consideration of roll-up.

### Search Queries

### Search

- **search** - returns the dimension values that match the search parameters

~~~json
{
  "queryType": "search",
  "dataSource": "wikiticker",
  "granularity": "hour",
  "searchDimensions": [
    "page",
    "user"
  ],
  "query": {
    "type": "insensitive_contains",
    "value": "truck"
  },
  "sort": {
    "type": "lexicographic"
  },
  "intervals": [
    "2015-09-12/2015-09-13"
  ]
}
~~~

**"query" -> "type": "insensitive_contains"** - a "match" will occur if any part of the dimension value contains the value noted in the query specification.

**"sort" -> "type": "lexicographic"** - sorts values by converting their Strings to UTF-8 byte array equivalents and comparing byte by byte.

Run the query `wiki-search-query.json` in sandbox web shell client:

~~~bash
curl -L -H 'Content-Type: application/json' -X POST --data-binary @/root/wiki-search-query.json http://sandbox-hdp.hortonworks.com:8082/druid/v2/?pretty
~~~

A sample of the output:

~~~json
[ {
  "timestamp" : "2015-09-12T00:00:00.000Z",
  "result" : [ {
    "dimension" : "page",
    "value" : "StarStruck (season 6)",
    "count" : 1
  }, {
    "dimension" : "page",
    "value" : "Wikipedia:Articles for deletion/Truck and Trailer South Africa",
    "count" : 1
  }, {
    "dimension" : "page",
    "value" : "ファイル:Truck SAGA station (opening day) Kyoto,JAPAN.jpg",
    "count" : 1
  } ]
} ]
~~~

As you can see we searched for "user" or "page" dimensions which contain the value "truck". You will see "truck" is not case sensitive "StarStruck", "Truck", etc.

## Appendix A: Further Reading

**Aggregation Query Reference**

- [Druid Timeseries Queries](http://druid.io/docs/latest/querying/timeseriesquery.html)
- [Druid GroupBy Queries](http://druid.io/docs/latest/querying/groupbyquery.html)

**Metadata Query Reference**

- [Druid Time Boundary Queries](http://druid.io/docs/latest/querying/timeboundaryquery.html)
- [Druid Segment Metadata Queries](http://druid.io/docs/latest/querying/segmentmetadataquery.html)
- [Druid Datasource Metadata Queries](http://druid.io/docs/latest/querying/datasourcemetadataquery.html)

**Search Query Reference**

- [Druid Search Queries](http://druid.io/docs/latest/querying/searchquery.html)

**Query Extra Features Reference**

- [Druid Query Filters](http://druid.io/docs/latest/querying/filters.html)
- [Druid Filtering with Extraction Functions](http://druid.io/docs/latest/querying/filters.html#filtering-with-extraction-functions)
- [What is time-series data?](https://blog.timescale.com/what-the-heck-is-time-series-data-and-why-do-i-need-a-time-series-database-dcf3b1b18563)
