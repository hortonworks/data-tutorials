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

Open the HDF Sandbox Web Shell Client at `http://sandbox-hdf.hortonworks.com:4200` with login `root/hadoop`.

- **Setup NiFi**:

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-a-security-breach-analysis-application/application/setup/shell/setup-hdf.sh
bash setup-hdf.sh
~~~

_Testing setup-hdf.sh_ - does it work?

Open the HDP Sandbox Web Shell Client at `http://sandbox-hdp.hortonworks.com:4200` with login `root/hadoop`. After login, you will be prompted to change the password.

- **Setup Spark**:

~~~bash
wget https://raw.githubusercontent.com/james94/data-tutorials/master/tutorials/cda/building-a-security-breach-analysis-application/application/setup/shell/setup-hdp.sh
bash setup-hdp.sh
~~~

## Approach 2: Manually Setup Development Platforms via CLI

## Summary

## Further Reading
