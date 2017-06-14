---
title: Sandbox Deployment and Install Guide
author: Edgar Orendain
tutorial-id: 350
experience: Intermediate
persona: Administrator
source: Hortonworks
use case: Single View
technology: Sandbox
release: hdp-2.6.0
environment: Sandbox
product: HDP
series: HDP > Hadoop Administration > Hortonworks Sandbox
---


# Sandbox Deployment and Install Guide

## Introduction

Hortonworks Sandbox Deployment is available in three isolated environments: virtual machine, container or cloud. There are two sandboxes available: Hortonworks Data Platform (HDP) and Hortonworks DataFlow (HDF).

## Environments for Sandbox Deployment

**Virtual Machine**

A virtual machine is a software computer that, like a physical computer, runs an operating system and applications. The virtual machine is backed by the physical resources of a host. Every virtual machine has virtual devices that provide the same functionality as physical hardware and have additional benefits in terms of portability, manageability, and security.

**Container**

Containers are similar to virtual machines except without the hypervisor. Containers are applications, such as HDF or HDP, that run in isolated environments for testing, staging and sometimes production. A container is an instance of an image. Containers run directly on the host machine's kernel, which results in using less memory resources.

**Cloud**

The cloud is an alternative environment for deploying Hortonworks Sandbox in case users do not have adequate memory available. This approach is similar to using virtual machine management software, except the virtual machine is located in a cloud environment rather than the users host machine.

## Outline

The Hortonworks Sandbox can be installed in a myriad of virtualization/containerization platforms. Jump to the tutorial for the platform that you prefer.  This documentation applies to both HDP and HDF sandboxes.

1.  **Deploying Hortonworks Sandbox on VirtualBox**
2.  **Deploying Hortonworks Sandbox on VMWare**
3.  **Deploying Hortonworks Sandbox on Docker**
4.  **Deploying Hortonworks Sandbox on Microsoft Azure**
