---
title: Sandbox Deployment and Install Guide
tutorial-id: 350
platform: hdp-2.6.0
tags: [sandbox, deploy, install, vmware]
---

# Deploying Hortonworks Sandbox on VMWare

## Introduction

This tutorial walks through installing the Hortonworks Sandbox onto VMware on your computer.

## Prerequisites

-   [Download the Hortonworks Sandbox](https://hortonworks.com/downloads/#sandbox)
-   VMWare Installed
    -   [VMWare Workstation For Linux](http://www.vmware.com/products/workstation-for-linux.html)
    -   [VMWare Workstation For Windows](http://www.vmware.com/products/workstation.html)
    -   [VMWare Fusion For Mac](http://www.vmware.com/products/fusion.html)
-   A computer with at least **8 GB of RAM to spare**.

## Outline

-   [Import the Hortonworks Sandbox](#import-the-hortonworks-sandbox)
-   [Further Reading](#further-reading)

## Import the Hortonworks Sandbox

Open your VMWare product and elect to add a new virtual machine.

On Mac OSX:

![VMWare Installation Method](assets/vmware-install.jpg)

Select "**Import an existing virtual machine**" and click the Continue button.

![choose_existing](assets/vmware-choose.jpg)

"**Choose File...**" to browse to and select the sandbox image you downloaded.  Click the Continue button.

Next, you're given the opportunity to save the virtual machine under a different name.  If you have no preference in renaming, you can just leave the default name and click Save.  You should then see the importing progress dialog:

![vmware_import_progress](assets/vmware-importing.jpg)

Once finished, the following screen is displayed:

![vmware_finish](assets/vmware-finish.jpg)

Click the **Finish** button and start your new virtual machine.  A window opens and displays the boot process.  Once the virtual machine fully boots up, you may begin using the sandbox.

Welcome to the Hortonworks Sandbox!

## Further Reading

-   Follow-up with the tutorial: [Learning the Ropes of the Hortonworks Sandbox](https://hortonworks.com/hadoop-tutorial/learning-the-ropes-of-the-hortonworks-sandbox)
-   [Browse all tutorials available on the Hortonworks site](https://hortonworks.com/tutorials/)
