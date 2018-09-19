---
title: Visualizing the Classification Model in Real-Time
---

# Visualizing the Classification Model in Real-Time

## Introduction

## Prerequisites

- Enabled Connected Data Architecture
- Setup the Development Environment
- Acquired Twitter Data
- Cleaned Raw Twitter Data
- Built a Sentiment Classification Model

## Outline

You should also see Nifi pick up data from Kafka and send it to Solr.

To visualize the data stored in Solr, you can use banana by going to this url:
```
http://sandbox.hortonworks.com:8983/solr/banana/index.html#/dashboard
```
To see the sentiment scores, click on the configure tab of the tweets panel and add the sentiment field.

![banana](assets/banana.png)
You'll then be able to see a sentiment score for each tweet, where 1 indicates happy and 0 indicates unhappy or neutral.
