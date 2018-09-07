---
title: Setting up the Development Environment
---

# Setting up the Development Environment

## Introduction

## Prerequisites

## Outline

- [Approach 1: Automatically Setup Development Platforms](#approach-1-automatically-setup-development-platforms)
- [Approach 2: Manually Setup Development Platforms via CLI](#approach-2-manually-setup-development-platforms-via-cli)
- [Summary](#summary)
- [Further Reading](#further-readings)

## Approach 1: Automatically Setup Development Platforms

Download the two setup scripts for HDF and HDP sandbox to prepare the services
to be used to develop the HVAC System Analysis Application. They perform the
following operations to setup the services needed for application development:

- **Setup NiFi**:

- **Setup HDP?**:

Open the HDF sandbox web shell client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-an-hvac-system-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh
~~~

Open the HDP sandbox web shell client at `http://sandbox-hdp.hortonworks.com:4200` with initial login `root/hadoop`,
once the password is entered, CentOS7 will prompt you to enter a new password. Note: write your new password down.

~~~bash
wget [setup-hdp.sh](application/setup/shell/setup-hdp.sh)
bash setup-hdp.sh
~~~

**Option 2:**

On Native Docker running on mac or linux:

~~~bash
wget [setup.sh](application/setup/shell/setup.sh)
bash setup.sh
~~~

Once the script finishes, you are now ready to move onto the next phase of development (the next tutorial), acquiring the data using NiFi.

## Approach 2: Manually Setup Development Platforms via CLI

## Setup Data-In-Motion Platform

Apache NiFi is a service that runs on Hortonworks DataFlow (HDF) Platform. HDF handles data-in-motion using flow management, stream processing and stream analytics. We will do some configurations, so later we can focus on building the NiFi dataflow application.

### Setting up NiFi

~~~bash
#!/bin/bash

# Adding Public DNS to resolve msg: unable to resolv s3.amazonaws.com
# https://forums.aws.amazon.com/thread.jspa?threadID=125056
tee -a /etc/resolve.conf << EOF
# Google Public DNS
nameserver 8.8.8.8
EOF
~~~

## Setup the Data-At-Rest Platform

## Summary

## Further Reading
