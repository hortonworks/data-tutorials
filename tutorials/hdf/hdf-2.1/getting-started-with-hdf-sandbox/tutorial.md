---
title: Getting Started with HDF Sandbox
tutorial-id: 760
platform: hdf-2.1
tags: [ambari]
---
# Getting Started with HDF Sandbox

## Introduction

In this tutorial, you will learn about the different features available in the HDF sandbox. HDF stands for Hortonworks DataFlow. HDF was built to make processing data-in-motion an easier task while also directing the data from source to the destination. You will learn about quick links to access these tools that way when you finish the tutorial, you will know how to access NiFi, Storm, Ranger and Ambari UIs. Therefore, you will be able to focus on using these apache tools for dealing with data-in-motion.

## Prerequisites

-   Downloaded and Installed [HDF Sandbox](https://hortonworks.com/downloads/)
-   Read [Hortonworks Sandbox Guide](https://hortonworks.com/hadoop-tutorial/hortonworks-sandbox-guide/)

## Outline

-   [Concepts](#concepts)
-   [Learn the Host Address of Your Environment](#learn-the-host-address-of-your-environment)
-   [Connect to the Welcome Screen](#connect-to-the-welcome-screen)
-   [Multiple Ways to Execute Terminal Commands](#multiple-ways-to-execute-terminal-commands)
-   [Explore Ambari](#explore-ambari)
-   [Summary](#summary)
-   [Further Reading](#further-reading)
-   [Appendix A: Troubleshoot](#appendix-a-troubleshoot)

> Note: It may be good idea for each procedure to start with an action verb (e.g. Install, Create, Implement, etc.)

## Concepts

### What is the Sandbox?

The Sandbox is a straightforward, pre-configured, learning environment that contains the latest developments from Apache Big Data related tools, specifically these tools were assembled together into Hortonworks DataFlow. The Sandbox comes packaged in a virtual environment that can run in the cloud or on your personal machine. The Sandbox allows you to learn and explore HDP on your own.

## Learn the Host Address of Your Environment

Once you installed the Sandbox VM or container, it resolves to the host on your environment, the address of which varies depending upon the Virtual Machine you are using(Vmware, VirtualBox, etc) or container (Docker, etc). As, a general thumb rule, wait for the installation to complete and confirmation screen will tell you the host your sandbox resolves to. For example:

In case of Docker: `host` would be `127.0.0.1`

## Connect to the Welcome Screen

Append the port number :18888 to your host address, open your browser, and access Sandbox Welcome page at `http://_host_:18888/.`

Click on `Launch Dashboard` to go to Ambari with a [Analyze Traffic Patterns with Aapche NiFi tutorial](#) and `Quick Links` to view some services of HDP environment.

## Multiple Ways to Execute Terminal Commands

> **Note:** For all methods below, the login credential instructions will be the same to access the Sandbox through the terminal.
- Login using username as **root** and password as **hadoop**.
- After first time login, you will be prompted to retype your current password, then change your password.
- If you are using Putty on Windows then go to terminal of your sandbox in oracle virtualBox --> Press `Alt+F5` --> enter username - **root** --> enter password - **hadoop** --> it will ask you to set new password --> set new password.

Open your terminal (mac and linux) or putty (windows). Type the following command to access the Sandbox through SSH:

~~~
# Usage:
      ssh <username>@<hostname> -p <port>;
# Example:
      ssh root@127.0.0.1 -p 12222;
~~~

#### Shell Web Client Method:

Open your web browser. Type the following text into your browser to access the Sandbox through the shell:

~~~
# Usage:
    #  _host_:14200
Example:
      127.0.0.1:14200
~~~

## Explore Ambari

Navigate to Ambari welcome page using the **url** given on Sandbox welcome page or access at `_host_:18080`.

> **Note:** Both the username and password to login are **admin**.

### Services Provided By the Ambari

| Service | URL |
|---------|-----:|
| Sandbox Welcome Page | [http://_host_:18888]()|
| Ambari Dashboard | [http://_host_:18080]()|
| NiFi UI | [http://_host_:19090/nifi]()|
| Ranger UI | [http://_host_:16080]()|
| Storm UI | [http://_host_:18744]()|
| Solr UI | [http://_host_:18886]()|
| Grafana UI | [http://_host_:13000]()|
| Log Search UI | [http://_host_:62888]()|

### The following Table Contains Login Credentials:

| Service | User | Password |
|---------|:------:|----------:|
| Ambari, OS | admin | refer to [setup ambari admin password](#setup-ambari-admin-password) |

### Setup Ambari admin Password Manually

1. Start your sandbox and open a terminal (mac or linux) or putty (windows)
2. SSH into the sandbox as root using `ssh root@127.0.0.1 -p 2222`. For Azure and VMware users, your `_host_` and `_port_` will be different.
3. Type the following commands:

~~~
# Updates password
ambari-admin-password-reset
# If Ambari doesn't restart automatically, restart ambari service
ambari-agent restart
~~~

> **Note:** Now you can login to ambari as an admin user to perform operations, such as starting and stopping services.

### Explore Ambari Welcome Screen 5 Key Capabilities

Enter the **Ambari Welcome URL** and then you should see the following options:

1.  “**Operate Your Cluster**” will take you to the Ambari Dashboard which is the primary UI for Hadoop Operators
2.  “**Manage Users + Groups**” allows you to add & remove Ambari users and groups
3.  “**Clusters**” allows you to grant permission to Ambari users and groups
4.  “**Ambari User Views**” list the set of Ambari Users views that are part of the cluster
5.  “**Deploy Views**” provides administration for adding and removing Ambari User Views

### Explore Ambari Dashboard Links

Enter the **Ambari Dashboard URL** and Click on:

1\.  **Metrics**, **Heatmap** and **Configuration**

and then the

2\.  **Dashboard**, **Services**, **Hosts**, **Alerts**, **Admin** and User Views icon (represented by 3×3 matrix ) to become familiar with the Ambari resources available to you.

## Summary

Congratulations, you've finished your first tutorial! Now you know about the different features available in the HDF sandbox. You know how to access NiFi, Storm, Ranger and Ambari UIs. Therefore, you are now ready to focus on using these apache tools for dealing with data-in-motion. If you want to learn more about HDF, check out the documentation in the Further Reading section below.

## Further Reading

- [HDF Documentation](https://docs.hortonworks.com/HDPDocuments/HDF2/HDF-2.1.2/index.html)

## Appendix A: Troubleshoot

### Troubleshoot Problems <a id="troubleshoot-problems"></a>

Check [Hortonworks Community Connection](https://hortonworks.com/community/forums/)(HCC) for answers to problems you may come across during your hadoop journey.

### Technique for Finding Answers in HCC <a id="technique-for-finding-answers-hcc"></a>

-   Insert quotes around your tutorial related problem
-   Be specific by including keywords (error, tutorial name, etc.)
