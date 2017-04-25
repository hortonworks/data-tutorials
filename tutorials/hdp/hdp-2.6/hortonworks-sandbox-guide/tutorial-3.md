---
title: Hortonworks Sandbox Guide
tutorial-id: 730
platform: hdp-2.6.0
tags: [sandbox, ports, port forwarding]
---

# Sandbox Port Forwards - HDP 2.6

## Introduction

Listed below are the ports that the HDP Sandbox forwards by default, and what software or purpose each port corresponds to.

> Note: Last updated for HDP Sandbox 2.6.0.1.

## Port Forwards

```
1111 -> 111 -- NFS gateway
2049 -> 2049 -- NFS gateway
2181 -> 2181 -- Zookeeper
3000 -> 3000 -- Grafana
4040 -> 4040 -- Spark
4200 -> 4200 -- Ambari Shell
4242 -> 4242 -- NFS gateway
4557 -> 4557 -- NiFi DistributedMapCacheServer
6080 -> 6080 -- Ranger
6188 -> 6188 -- Ambari Metrics Timeline Server
8000 -> 8000 -- Storm Logviewer
8005 -> 8005 -- Sqoop / Common Tomcat port
8020 -> 8020 -- HDFS
8032 -> 8032 -- Yarn ResourceManager
8040 -> 8040 -- NodeManager
8042 -> 8042 -- NodeManager
8050 -> 8050 -- Yarn ResourceManager
8080 -> 8080 -- Ambari
8082 -> 8082 -- Namenode UI
8086 -> 8086 -- Namenode UI
8088 -> 8088 -- Yarn ResourceManager
8090 -> 8090 -- Namenode UI
8091 -> 8091 -- Namenode UI
8188 -> 8188 -- YarnATS
8443 -> 8443 -- Knox
8744 -> 8744 -- StormUI
8765 -> 8765 -- Phoenix
8886 -> 8886 -- Ambari Infra
8888 -> 8888 -- Tutorials splash page
8889 -> 8889 -- Jupyter
8983 -> 8983 -- SolrAdmin
8993 -> 8993 -- Solr
9000 -> 9000 -- HST (Smartsense)
9090 -> 9090 -- NiFi
9090 -> 9091 -- NiFi SSL
9995 -> 9995 -- Zeppelin
9996 -> 9996 -- Zeppelin
10015 -> 10015 -- Spark
10016 -> 10016 -- Spark
10000 -> 10000 -- HiveServer2
10001 -> 10001 -- HiveServer2Http
10500 -> 10500 -- HiveServer2v2
10502 -> 10502 -- HiveServer2 Interactive UI
11000 -> 11000 -- Oozie
15000 -> 15000 -- Falcon
15002 -> 15002 -- Hive LLAP
16000 -> 16000 -- HBase Master
16010 -> 16010 -- HBase Master Info
16020 -> 16020 -- HBase Regionserver
16030 -> 16030 -- HBase Regionserver Info
18080 -> 18080 -- SparkHistoryServer
18081 -> 18081 -- Spark2 History Server
19888 -> 19888 -- JobHistory
21000 -> 21000 -- Atlas
33553 -> 33553 -- Hive LLAP
39419 -> 39419 -- Hive LLAP
42111 -> 42111 -- NFS
50070 -> 50070 -- Webhdfs
50075 -> 50075 -- Datanode
50079 -> 50079 -- NFS gateway
50095 -> 50095 -- Accumulo
50111 -> 50111 -- WebHcat
61888 -> 61888 -- LogsearchUI

2222 -> 22 -- Sandbox container SSH
15500 -> 15500 -- Port for custom use
15501 -> 15501 -- Port for custom use
15502 -> 15502 -- Port for custom use
15503 -> 15503 -- Port for custom use
15504 -> 15504 -- Port for custom use
15505 -> 15505 -- Port for custom use
```
