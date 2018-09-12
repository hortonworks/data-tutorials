---
title: Acquiring Twitter Data
---

# Acquiring Twitter Data

## Introduction

## Prerequisites

## Outline

- [Approach 1: Auto Deploy NiFi Flow via REST Call](#approach-1-auto-deploy-nifi-flow-via-rest-call)
- [Approach 2: Import NiFi AcquireNASALogs via UI](#approach-2-import-nifi-acquirenasalogs-via-ui)
- [Summary](#summary)
- [Further Reading](#further-reading)

## Approach 1: Auto Deploy NiFi Flow via REST Call

Open HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

~~~bash
KEY="<Your-Consumer-API-Key>"
SECRET_KEY="<Your-Consumer-API-Secret-Key>"
TOKEN="<Your-Access-Token>"
SECRET_TOKEN="<Your-Access-Token-Secret>"

# Downloads, Imports, Starts NiFi flow: AcquireTwitterData.xml

wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-detection-application/application/development/shell/nifi-auto-deploy.sh
bash nifi-auto-deploy.sh $KEY $SECRET_KEY $TOKEN $SECRET_TOKEN
~~~

Open HDF **NiFi UI** at `http://sandbox-hdf.hortonworks.com:9090/nifi`. Your NiFi was just uploaded, imported and started.

## Approach 2: Import NiFi AcquireNASALogs via UI



## Summary



## Further Reading
