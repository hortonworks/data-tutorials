---
title: Visualizing NASA Log Data
---

# Visualizing NASA Log Data

## Introduction

## Prerequisites

## Outline

- [Approach 1: Auto Deploy Zeppelin Notebook via REST Call](#approach-1-auto-deploy-zeppelin-notebook-via-rest-call)
- [Approach 2: Import Zeppelin Notebook via Zeppelin UI](#approach-2-import-zeppelin-notebook-via-ui)
- [Summary](#summary)
- [Further Reading](#further-reading)


## Approach 1: Auto Deploy Zeppelin Notebook via REST Call

Open HDP **sandbox web shell client** at `sandbox-hdp.hortonworks.com:4200`.

We will use the Zeppelin REST Call API to import a notebook that uses SparkSQL to analyze NASA's server logs for possible breaches.

~~~bash
NOTEBOOK_NAME="Visualizing-NASA-Log-Data"
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-detection-application/application/development/shell/zeppelin-auto-deploy.sh
bash zeppelin-auto-deploy.sh $NOTEBOOK_NAME
~~~

## Approach 2: Import Zeppelin Notebook via Zeppelin UI

## Summary

## Further Reading
