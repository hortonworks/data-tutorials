---
title: Sandbox Port Forwards - HDF 3.1.1
---

# Sandbox Port Forwards - HDF 3.1.1

## Introduction

Listed below are the ports that the CDF Sandbox forwards by default, and what software or purpose each port corresponds to.

In this release we began to use NGINX as a reverse proxy server. In general, we open all necessary ports for HDP and HDF to communicate with each other, hence, Connected Data Architecture (CDA).

## Port Forwards

```
12181 -> 2181    Zookeeper
13000 -> 3000    Grafana
14200 -> 4200    Ambari Shell
14557 -> 4557    NiFi DistributedMapCacheServer
16080 -> 6080    Ranger
18000 -> 8000    Storm Logviewer
9080  -> 8080    Ambari
18744 -> 8744    StormUI
18886 -> 8886    Ambari Infra
18888 -> 8888    Tutorials splash page
18993 -> 8993    Solr
19000 -> 9000    HST (Smartsense)
19090 -> 9090    NiFi
19091 -> 9091    NiFi SSL
43111 -> 42111   NFS
62888 -> 61888   LogsearchUI

12222 -> 22       Sandbox container SSH
25100 -> 15100    Port for custom use
25101 -> 15101    Port for custom use
25102 -> 15102    Port for custom use
25103 -> 15103    Port for custom use
25104 -> 15104    Port for custom use
25105 -> 15105    Port for custom use
17000 -> 17000    Reserved for services that require direct forwarding
17001 -> 17001    Reserved for services that require direct forwarding
17002 -> 17002    Reserved for services that require direct forwarding
17003 -> 17003    Reserved for services that require direct forwarding
17004 -> 17004    Reserved for services that require direct forwarding
17005 -> 17005    Reserved for services that require direct forwarding
```
