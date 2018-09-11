---
title: Acquiring NASA Server Log Data
---

# Acquiring NASA Server Log Data

## Introduction

You have been brought onto the project as a Data Engineer with the following responsibilities: acquire the NASA Server Log data feed, preprocess the data to be readable and store it into a storage.

## Prerequisites

- Enabled CDA for your appropriate system.

## Outline

- [Approach 1: Auto Deploy NiFi Flow via REST Call](#approach-1-auto-deploy-nifi-flow-via-rest-call)
- [Approach 2: Import NiFi AcquireNASALogs via UI](#approach-2-import-nifi-acquirenasalogs-via-ui)
- [Summary](#summary)
- [Further Reading](#further-reading)
- [Appendix A: NiFi Reference](#appendix-a-nifi-reference)

## Approach 1: Auto Deploy NiFi Flow via REST Call

Open HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

~~~bash
wget https://github.com/james94/data-tutorials/raw/master/tutorials/cda/building-a-cybersecurity-breach-detection-application/application/development/shell/nifi-auto-deploy.sh
bash nifi-auto-deploy.sh
~~~

Open HDF **NiFi UI** at `http://sandbox-hdf.hortonworks.com:9090/nifi`. Your NiFi was just uploaded, imported and started.

## Approach 2: Import NiFi AcquireNASALogs via UI


## Summary

## Further Reading
