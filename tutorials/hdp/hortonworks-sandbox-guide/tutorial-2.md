---
title: Sandbox Docs - HDF 3.1.1
---

# Sandbox Docs - HDF 3.1.1

## Outline

- [Release Notes](#release-notes)
- [Behavior Changes](#behavior-changes)
- [System Information](#system-information)
  - [Databases Used](#databases-used)
- [Services Started Automatically](#services-started-automatically)
- [Services In Maintenance Mode](#services-in-maintenance-mode)
- [Further Reading](#further-reading)

## Release Notes

June 2018

- The VirtualBox and VMWare releases of the HDF sandbox had their OS-level packages updated, including a version update to Docker 18.03.0.

- Image MD5 Checksums:
  - VirtualBox release – **6eecb32e668af0ccc9215ebec0ee4810**
  - VMware release – **d09dbbb47b6d0e97e061cb21cf86178b**
  - Docker release – **c04d4be290778818cec526f99b5af294**

- HDF Stack and Ambari: The Sandbox uses the following versions of Ambari and HDF stack. Please use the following release note links provided to view Ambari and HDF stack specific information.
  - [HDF 3.1.1 Product Release Notes](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.1/bk_release-notes/content/ch_hdf_relnotes.html)
  - [Ambari 2.7.1 Release Notes](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.1.0/bk_ambari-release-notes/content/ch_relnotes-ambari-2.7.1.0.html)

## Behavior Changes

- Virtual machines are now Connected Data Architecture (CDA) ready

> NOTE: This statement is true for HDP 2.6.5 and HDF 3.1.1. CDA **Sandbox** is disabled for HDP 3.0.1 until further notice.

## System Information

Operating System and Java versions that the Sandbox has installed.

- CentOS release 7.5.1804
- Kernel: 4.17.1-1
- Java: OpenJDK version 1.8.0_171

Image File Sizes:

- Docker – 7 GB
- VMware – 8 GB
- Virtualbox – 8 GB

### Databases Used

These are a list of databases used within the CDF Sandbox along with the HDF components that use them.

- PostgreSQL: Ambari
- MySQL: Registry, Streaming Analytics Manager

## Services Started Automatically

When the sandbox is started, the following services are also started by default. Unless specified, assume all are java processes and the user that launches the process is named the same as the component (i.e. The Storm process is run by the user "storm").

- Ambari Server (run as root user)
- Ambari Agent (non-java)
- Zookeeper
- Storm
- Ambari Infra
- Kafka
- Log Search
- NiFi
- Schema Registry
- Streaming Analytics Manager (run as streamline user)

## Services In Maintenance Mode

Due to limited resources available in the sandbox's virtual environment, the following services are in maintenance mode and will not automatically start.

To fully use these services, you must allocate more memory to the sandbox's virtual machine or turn off existing services.  If you want these services to automatically start, turn off maintenance mode from within the Ambari dashboard.

- NiFi Registry

## Further Reading

- [Hortonworks Connected Data Platforms](https://hortonworks.com/products/data-platforms/)
- [HDF Documentation](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.1/index.html) Zookeeper
- Storm
- Ambari Infra
- Kafka
- Log Search
- NiFi
- Schema Registry
- Streaming Analytics Manager (run as streamline user)

## Services In Maintenance Mode

Due to limited resources available in the sandbox's virtual environment, the following services are in maintenance mode and will not automatically start.

To fully use these services, you must allocate more memory to the sandbox's virtual machine or turn off existing services.  If you want these services to automatically start, turn off maintenance mode from within the Ambari dashboard.

- NiFi Registry

## Further Reading

- [Hortonworks Connected Data Platforms](https://hortonworks.com/products/data-platforms/)
- [HDF Documentation](https://docs.hortonworks.com/HDPDocuments/HDF3/HDF-3.1.1/index.html)