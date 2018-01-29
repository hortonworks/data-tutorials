---
title: Sandbox Docs - HDF 3.0.2.0
---

# Sandbox Docs - HDF 3.0.2.0

## Outline

-   [Release Notes](#release-notes)
-   [System Information](#system-information)
    -   [Databases Used](#databases-used)
-   [Services Started Automatically](#services-started-automatically)
-   [Services In Maintenance Mode](#services-in-maintenance-mode)
-   [Further Reading](#further-reading)

## Release Notes

January 2018
-   The VirtualBox and VMWare releases of the HDF sandox had their OS-level packages updated, including a version update of Docker from 17.09 to 17.12.
-   A patch was applied to the released VMs which updated them to the 4.14.14-1 kernel to address the Meltdown/Spectre vulnerability.
-   The VirtualBox and VMWare releases were reduced to a total size of about 10.4 GB.  As a result, a loading splash page will show up on first boot while the sandbox is decompressed and set up.
-   Minor splash page typo fixes.

December 2017
-   The Sandbox uses the following versions of Ambari, HDF and HDP. Please use the following release note links provided to view their respective release notes.
    -   [Ambari 2.6](https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.0.0/bk_ambari-release-notes/content/ch_relnotes-ambari-2.6.0.0.html)
    -   [HDF 3.0.2](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.0.2/bk_release-notes/content/ch_hdf_relnotes.html)
    -   [HDP 2.6.3](https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.6.3/bk_release-notes/content/ch_relnotes.html)

## System Information

Operating System and Java versions that the Sandbox has installed.
-   CentOS release 7.4.1708
-   Kernel: 4.14.14-1
-   Java: OpenJDK version 1.8.0_131

Image File Sizes:
-   Docker – 10 GB compressed, 13.9 GB uncompressed
-   VMware – 10.4 GB
-   Virtualbox – 10.4 GB

Image Checksums:
-   Docker release – **sha256:786dec2112d2f3054e8bd7a5f9ad194949909c6e60707d554b3c196ebf2117ba**
-   VMware release – **sha256:d84fc4e281d75c84901841bb370278c9c52b0036e55c4e329e3a5a03f24f9e31**
-   Virtualbox release – **sha256:e904282bbffbc16a9c462e556ba376d1965c143346c8c0cea774d8fd1339f27d**

### Databases Used

These are a list of databases used within the HDF Sandbox along with the HDF components that use them.

-   PostgreSQL: Ambari
-   MySQL: Registry, Streaming Analytics Manager, Druid, Superset

## Services Started Automatically

When the sandbox is started, the following services are also started by default. Unless specified, assume all are java processes and the user that launches the process is named the same as the component (i.e. The Storm process is run by the user "storm").

-   Ambari Server (run as root user)
-   Ambari Agent (non-java)
-   Zookeeper
-   Storm
-   Kafka
-   NiFi
-   Registry
-   Streaming Analytics Manager (run as streamline user)

## Services In Maintenance Mode

Due to limited resources avaialble in the sandbox's virtual environment, the following services are in maintenance mode and will not automatically start.

To fully use these services, you must allocate more memory to the sandbox's virtual machine or turn off existing services.  If you want these services to automatically start, turn off maintenance mode from within the Ambari dashboard.

-   HDFS
-   YARN
-   MapReduce2
-   HBase
-   Druid
-   Superset

## Further Reading
-   [About Hortonworks DataFlow](https://hortonworks.com/products/data-center/hdf/)
