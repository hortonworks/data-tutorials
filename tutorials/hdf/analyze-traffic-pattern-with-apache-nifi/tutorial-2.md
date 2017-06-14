---
title: Launch NiFi HTML UI
---

# Launch NiFi HTML UI

## Introduction

With the HDF Sandbox, Apache NiFi comes preinstalled in the Ambari Stack and preconfigured out of the box to utilize many of its features. In the tutorial, it shows you how to access the NiFi HTML UI in one of two ways: use autoscript to access the NiFi UI or manually access it via Ambari.

## Prerequisites
-   Completed Analyze Traffic Patterns with Apache NiFi Introduction
-   Read NiFi DataFlow Automation Concepts
-   Downloaded and installed [HDF Sandbox](https://hortonworks.com/products/sandbox/) for VMware, VirtualBox or Native Docker

## Outline
-   [Step 1: Download HDF NiFi Shell Script](#download-hdf-nifi-shell-script)
-   [Approach 1: Access NiFi HTML UI via Shell Script](#access-nifi-html-ui-via-shell-script)
-   [Approach 2: Access NiFi HTML UI via Ambari](#access-nifi-html-ui-via-ambari)
-   [Summary](#summary)

Refer to Approach 1 to quickly launch NiFi HTML UI via script,
else go to Approach 2 to launch NiFi HTML UI from Ambari,
but first complete Step 1.

### Step 1: Download HDF NiFi Shell Script

Download the auto-scripts and change permissions for the scripts:

Download [auto_scripts.zip](assets/auto_scripts.zip)

~~~bash
cd ~/Downloads
unzip auto_scripts.zip
chmod -R 755 auto_scripts
~~~

> Note: You will utilize these scripts throughout either section.

### Approach 1: Launch NiFi HTML UI via Shell Script

1\. Execute the script:

~~~bash
./auto_scripts/launch_nifi_ui.sh
~~~

NiFi HTML UI will open in your chrome browser as below:

![open_nifi_html_interface.png](assets/tutorial-0-launch-nifi-html-ui/open_nifi_html_interface.png)

### Approach 2: Access NiFi HTML UI via Ambari

1\. Start HDF Sandbox via Script:

~~~bash
./auto_scripts/launch_ambari_ui.sh
~~~

2\. Login to Ambari UI with credentials (admin/admin).

The Ambari Login UI will look as below:

![login_ambari_ui.png](assets/tutorial-0-launch-nifi-html-ui/login_ambari_ui.png)

3\. Verify the NiFi Service is running, it should have a green check mark:

![verify_nifi_running.png](assets/tutorial-0-launch-nifi-html-ui/verify_nifi_running.png)

4\. Select the NiFi Service, click on Quick Links dropdown and press the NiFi UI:

![open-nifi-ui-via-ambari.png](assets/tutorial-0-launch-nifi-html-ui/open-nifi-ui-via-ambari.png)

NiFi HTML UI will open as below:

![open_nifi_html_interface.png](assets/tutorial-0-launch-nifi-html-ui/open_nifi_html_interface.png)

## Summary

Congratulations! As a review, HDF Sandbox comes preinstalled and preconfigured with NiFi. Therefore, you launched NiFi HTML UI through Ambari or via Shell Script within a few minutes. Now that you have NiFi running, let's head to the next tutorial to began building our simple dataflow.
