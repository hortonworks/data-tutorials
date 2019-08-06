---
title: Visualize Website Clickstream Data
author: sandbox-team
tutorial-id: 250
experience: Intermediate
persona: Data Scientist & Analyst
source: Hortonworks
use case: Data Discovery
technology: Apache Ambari, Apache Hive, Apache Zeppelin, HDFS
release: hdp-3.0.1
environment: Sandbox
product: HDP
series: HDP > Develop with Hadoop > Real World Examples, HDP > Hadoop for Data Scientists & Analysts > Real World Examples
---

# Visualize Website Clickstream Data

## Introduction

Your home page looks great. But how do you move customers on to bigger things - like submitting a form or completing a purchase? Get more granular with customer segmentation. Hadoop makes it easier to analyze, visualize and ultimately change how visitors behave on your website.

We will cover an established use case for Hadoop: deriving insights from large data sources such as web logs. By combining web logs with more traditional customer data, we can better understand customers and understand how to optimize future promotions and advertising.  We demonstrate how an online retailer can optimize buying paths to reduce bounce rate and improve conversion.

### Clickstream Data

Clickstream data is an information trail a user leaves behind while visiting a website. It is typically captured in semi-structured website log files.

These website log files contain data elements such as a date and time stamp, the visitor’s IP address, the URLs of the pages visited, and a user ID that uniquely identifies the user.

### Potential Uses of Clickstream Data

One of the original uses of Hadoop at Yahoo was to store and process their massive volume of clickstream data. Now enterprises of all types can use Hadoop and the Hortonworks Data Platform (HDP) to refine and analyze clickstream data. They can then answer business questions such as:

- What is the most efficient path for a site visitor to research a product, and then buy it?
- What products do visitors tend to buy together, and what are they most likely to buy in the future?
- Where should I spend resources on fixing or enhancing the user experience on my website?

In this tutorial, we will focus on the “path optimization” use case. Specifically: how can we improve our website to reduce bounce rates and improve conversion?

## Prerequisites

- Downloaded and deployed the [Hortonworks Data Platform (HDP)](https://www.cloudera.com/downloads/hortonworks-sandbox/hdp.html?utm_source=mktg-tutorial) Sandbox
- [Getting Started with Apache Zeppelin](https://hortonworks.com/tutorial/getting-started-with-apache-zeppelin/)
- Have sample retail data already loaded [by completing this tutorial](https://hortonworks.com/tutorial/loading-and-querying-data-with-hadoop/)

## Outline

- **Visualize Log Data with Apache Zeppelin** - Use Apache Zeppelin to analyze logs for customer demographics and their product interests.
- **Visualize Log Data with Microsoft Excel** - Use Microsoft Excel to map user demographics and graph log data.
