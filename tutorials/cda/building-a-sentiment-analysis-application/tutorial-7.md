---
title: Visualizing Sentiment Scores
---

# Visualizing Sentiment Scores

## Introduction

You will use Zeppelin's JDBC Hive Interpreter to perform SQL queries against the noSQL HBase table "tweets_sentiment" for the sum of happy and sad tweets and perform visualizations of the results.

## Prerequisites

- Enabled Connected Data Architecture
- Setup the Development Environment
- Acquired Twitter Data
- Cleaned Raw Twitter Data
- Built a Sentiment Classification Model
- Deployed a Sentiment Classification Model

## Outline

- [Implement a Zeppelin Notebook to Visualize Sentiment Scores](#implement-a-zeppelin-notebook-to-visualize-sentiment-scores)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Implement a Zeppelin Notebook to Visualize Sentiment Scores

### Create Hive Table Mapping to HBase Table

To visualize the data stored in HBase, you can use zeppelin's JDBC Hive Interpreter:

~~~sql
%jdbc(hive)
CREATE EXTERNAL TABLE IF NOT EXISTS tweets_sentiment(`key` BIGINT, `handle` STRING, `language` STRING, `location` STRING, `sentiment` DOUBLE, `tweet_id` BIGINT)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES("hbase.columns.mapping" = ":key,social_media_sentiment:twitter.handle,social_media_sentiment:twitter.language,social_media_sentiment:twitter.location,social_media_sentiment:twitter.sentiment,social_media_sentiment:twitter.tweet_id")
TBLPROPERTIES("hbase.table.name" = "tweets_sentiment");
~~~

![create_hive_mapped_hbase_table](assets/images/visualizing-sentiment-scores/create_hive_mapped_hbase_table.jpg)

### Load a Sample of the Data

Load data from the Hive table:

~~~sql
%jdbc(hive)
SELECT * FROM tweets_sentiment;
~~~

![load_hive_tweets_sentiment_table](assets/images/visualizing-sentiment-scores/load_hive_tweets_sentiment_table.jpg)

### Visualize Sentiment Score Per Language in Bar Chart

To see each tweet's sentiment score per language, copy and paste the following query.


~~~sql
%jdbc(hive)
SELECT language, sentiment FROM tweets_sentiment;
~~~

![load_language_sentiment_score](assets/images/visualizing-sentiment-scores/load_language_sentiment_score.jpg)

## Summary

Congratulations! You just learned to write Hive code to access an HBase table, query against the table and visualize the data using Zeppelin's JDBC Hive Interpreter.

## Further Reading

- [Hive HBaseIntegration](https://cwiki.apache.org/confluence/display/Hive/HBaseIntegration)
