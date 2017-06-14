---
title: Sandbox Port Forwards - HDF 2.1
---

# Sandbox Port Forwards - HDF 2.1

## Introduction

Listed below are the ports that the HDF Sandbox forwards by default, and what software or purpose each port corresponds to.

To allow multiple types of sandboxes to be running at once (e.g. HDP and HDF), the HDF Sandbox employs a port forwarding pattern so as to not overlap with HDP ports.

For reference, the port forwarding pattern is:
-   Add +10000 to the port, or +1000 if adding 10000 would mean an invalid or overlapping port (ex: 12181 -> 2181, 19000 -> 9000, 62888 -> 61888).
-   Ports 15100-15105 are custom ports that some tutorials might use temporarily.  Feel free to use these ports for your own purpose - they have already been opened and forwarded for you.
-   For processes that must absolutely have direct port forwarding, ports 17000-17005 are reserved for that purpose.

> Note: Last updated for HDF Sandbox 2.1.0.0.

## Port Forwards

```
12181 -> 2181 -- Zookeeper
13000 -> 3000 -- Grafana
14200 -> 4200 -- Ambari Shell
14557 -> 4557 -- NiFi DistributedMapCacheServer
16080 -> 6080 -- Ranger
18000 -> 8000 -- Storm Logviewer
9080  -> 8080 -- Ambari
18744 -> 8744 -- StormUI
18886 -> 8886 -- Ambari Infra
18888 -> 8888 -- Tutorials splash page
18993 -> 8993 -- Solr
19000 -> 9000 -- HST (Smartsense)
19090 -> 9090 -- NiFi
19091 -> 9091 -- NiFi SSL
43111 -> 42111 -- NFS
62888 -> 61888 -- LogsearchUI

12222 -> 22 -- Sandbox container SSH
25100 -> 15100 -- Port for custom use
25101 -> 15101 -- Port for custom use
25102 -> 15102 -- Port for custom use
25103 -> 15103 -- Port for custom use
25104 -> 15104 -- Port for custom use
25105 -> 15105 -- Port for custom use
17000 -> 17000 -- Reserved for services that require direct forwarding
17001 -> 17001 -- Reserved for services that require direct forwarding
17002 -> 17002 -- Reserved for services that require direct forwarding
17003 -> 17003 -- Reserved for services that require direct forwarding
17004 -> 17004 -- Reserved for services that require direct forwarding
17005 -> 17005 -- Reserved for services that require direct forwarding
```
