---
title: Deploying Hortonworks Sandbox on VirtualBox
---

# Deploying Hortonworks Sandbox on VirtualBox

## Introduction

This tutorial walks through the general approach for installing the Hortonworks Sandbox (HDP or HDF) onto VirtualBox on your computer.

## Prerequisites

-   [Download the Hortonworks Sandbox](https://hortonworks.com/downloads/#sandbox)
-   [Install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
-   A computer with at least **8 GB of RAM to spare**.

## Outline

-   [Import the Hortonworks Sandbox](#import-the-hortonworks-sandbox)
-   [Start the Hortonworks Sandbox](#start-the-hortonworks-sandbox)
-   [Further Reading](#further-reading)

## Import the Hortonworks Sandbox

Start by importing the Hortonworks Sandbox into VirtualBox.  You can do this in two ways:

-   Double-click on the [sandbox image you download](https://hortonworks.com/downloads/#sandbox) from the prerequisites section above.
-   Or open VirtualBox and navigate to **File -> Import Appliance**.  Select the sandbox image you downloaded and click "**Next**".

You should end up with a screen like this:

![Appliance Settings](assets/vbox-appliance-settings.jpg)

> Note: Make sure to allocate at least 8 GB (8192 MB) of RAM for the sandbox.

Click "Import" and wait for VirtualBox to import the sandbox.

## Start the Hortonworks Sandbox

Once the sandbox has finished being imported, you may start it by selecting the sandbox and clicking "**Start**" from the VirtualBox menu.

![virtualbox_start_windows](assets/vbox-start.jpg)

A console window opens and displays the boot process.  Once the virtual machine fully boots up, you may begin using the sandbox.

Welcome to the Hortonworks Sandbox!

## Further Reading

-   Follow-up with the tutorial: [Learning the Ropes of the Hortonworks Sandbox](https://hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox)
-   [Browse all tutorials available on the Hortonworks site](https://hortonworks.com/tutorials/)
