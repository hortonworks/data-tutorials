# Lab0: Download, Install and Start NiFi

## Introduction

In this tutorial, we will learn about our lab environment, how to install NiFi onto Hortonworks Sandbox or on a local machine and start NiFi.

## Pre-Requisites
- Downloaded and Installed Hortonworks Sandbox (Needed for Step 2 if you go with Option 1 for NiFi installation)
- For windows users, to run linux terminal commands in these tutorials, download [Git Bash](https://openhatch.org/missions/windows-setup/install-git-bash).

## Outline
- Step 1: Explore Lab Environment Before NiFi Installation
- Step 2: Download and Install NiFi on Sandbox (Option 1)
- Step 3: Download and Install NiFi on Local Machine (Option 2)
- Step 4: Start NiFi on Sandbox
- Step 5: Start NiFi on Local Machine

### Step 1: Explore Lab Environment Before NiFi Installation

The lab environment (NiFi) can run inside a single virtual machine or on your local computer. This version of the lab instructions are based on [Hortonworks DataFlow 1.2 GZipped](http://hortonworks.com/downloads/). There are 2 ways to download and install HDF 1.2: Option 1 on a Hortonworks Sandbox 2.4 Virtual Image or Option 2 on your local machine. HDF comes in 2 versions with only NiFi or with NiFi, Kafka and Storm, Zookeeper; however, for this lab series, we will download HDF that comes with only NiFi. The necessary components for this lab series:
- HDF 1.2 (NiFi only)
- Internet Access

### 1.1 Plan to Install HDF 1.2 on Sandbox

If you plan to install HDF on Hortonworks Sandbox, review the table, then proceed to step 2.

**Table 1: Hortonworks Sandbox Virtual Machine Information**

| Parameter  | Value (VirtualBox)  | Value(VMware)  | Value(MS Azure)  |
|---|---|---|---|
| Host Name  | 127.0.0.1  | 172.16.110.129  | 23.99.9.233  |
| Port  | 2222  | 2222  | 22  |
| Terminal Username  | root  | root  | {username-of-azure}  |
| Terminal Password  | hadoop  | hadoop  | {password-of-azure}  |


> Note: **Host Name** values are unique for VMware & Azure Sandbox compared to the table. For VMware and VirtualBox, **Host Name** is located on welcome screen. For Azure, **Host Name** is located under **Public IP Address** on Sandbox Dashboard. For Azure users, the terminal **username** and **password** is one you created while deploying the sandbox on azure. For VMware and VirtualBox users, terminal password changes after first login.

If it is your first time SSH'ing into the sandbox VM, it may prompt you to change the default 'hadoop' password. Please run this command and provide a stronger password:
```
ssh -p 2222 root@localhost
root@localhost's password:
You are required to change your password immediately (root enforced)
Last login: Wed Jun 15 19:47:44 2016 from 10.0.2.2
Changing password for root.
(current) UNIX password:
New password:
Retype new password:
[root@sandbox ~]#
```

### 1.2 Plan to Install HDF 1.2 on Local Machine

This section is important to read through if you want to install NiFi on your local machine. Refer to step 3 if you read this section.

Does your system meet HDF's installation requirements?

Supported OS for HDF Installation:
- Linux Red Hat/Cent OS 6 or 7) 64-bit
- Ubuntu 12.04 or 14.04 64-bit
- Debian 6 or 7
- SUSE Enterprise 11-SP3

Supported Browsers:
- Mozilla Firefox latest, Google Chrome latest, MS Edge, Safari 8

Supported JDKS:
- Open JDK7 or JDK8
- Oracle JDK 7 or JDK 8

Supported HDP Versions that Interoperate with HDF:
- HDP 2.3.x
- HDP 2.4.x

Apache Tools Included in HDF:
- NiFi 0.6.0
- Kafka 0.9.0.1
- Storm 0.10.0
- Zookeeper 3.4.6

For Hardware Sizing Recommendations, refer to HDF [Hardware Sizing Recommendations Documentation](http://docs.hortonworks.com/HDPDocuments/HDF1/HDF-1.2.0.1/bk_HDF_InstallSetup/content/hdf_isg_hardware.html). However, for the lab series, we won't have to worry about these specs.

If you plan to install and download HDF on your local machine, refer to step 3.

### Step 2: Download and Install NiFi on Hortonworks Sandbox (Option 1)

HDF will be installed on the Hortonworks Sandbox VirtualBox image because the sandbox does not come with HDF preinstalled.

The following instructions will guide you through the NiFi installation process. All the steps throughout the tutorial will be done using the latest Hortonworks Sandbox 2.4.

1\. Open a terminal window (Mac and Linux) or git bash (Windows) on **local machine**. Download the **install-nifi.sh** file from the github repo. Copy & paste the following commands:

~~~
cd
curl -o install-nifi.sh https://raw.githubusercontent.com/hortonworks/tutorials/hdp/assets/realtime-event-processing/install-nifi.sh
chmod +x ./install-nifi.sh
~~~

2\. Open a browser. NiFi can be downloaded from [HDF Downloads Page](http://hortonworks.com/downloads/). There are two package options one for HDF TAR.GZ file tailored to Linux and ZIP file more compatible with Windows. Mac can use either option. For the tutorial, let's download the latest HDF TAR.GZ:

![download_hdf_iot](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/download-hdf-learn-ropes-nifi.png)

3\. Run the install-nifi.sh script. Below is a definition of how the install nifi command works:

~~~
install-nifi.sh {location-of-HDF-download} {sandbox-host} {ssh-port} {hdf-version}
~~~

> Note: For VMware and Azure users, sandbox-host can be found at the welcome screen after starting your sandbox and ssh-port can be found in Table 1. hdf-version is the digits in the tar.gz name you downloaded, for example the numbers in bold HDF-**1.2.0.1-1**.tar.gz.

After you provide the file path location to HDF TAR.GZ file, sandbox hostname, ssh port number and HDF version, your command should look similar as follows:

~~~
./install-nifi.sh ~/Downloads/HDF-1.2.0.1-1.tar.gz localhost 2222 1.2.0.1-1
~~~

> Note: You will be asked if you want to continue the download, type `yes`. You will also be asked twice for your ssh password to install NiFi on your Hortonworks Sandbox.

The script automatically installs NiFi onto your virtual machine. After successful completion, NiFi is transported onto the Hortonworks Sandbox and the HDF folder will be located at `~` folder.

### Step 3: Download and Install NiFi on Local Machine (Option 2)

1\. Open a browser. NiFi can be downloaded from [HDF Downloads Page](http://hortonworks.com/downloads/). There are two package options one for HDF TAR.GZ file tailored to Linux and zip file more compatible with Windows. Mac can use either option. In this tutorial section, we will download the zip on mac:

![download_hdf_iot](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/download-hdf-learn-ropes-nifi.png)

2\. To install NiFi, extract the files to the location from which you want to run the application. For the tutorial, we moved the extracted HDF folder to the Applications folder.

### Step 4: Start NiFi on Sandbox <a id="step3-start-nifi"></a>

If you downloaded and installed NiFi on Hortonworks Sandbox, refer to this step, else go to step 5. We will start NiFi to run in the foreground.

1\. Open a terminal (Mac and Linux) or git bash (Windows). SSH into the Hortonworks Sandbox

~~~
ssh root@127.0.0.1 -p 2222
~~~

2\. Navigate to the `bin` directory using the following command:

~~~
cd hdf/HDF-1.2.0.1-1/nifi/bin
~~~

3\. Run the `nifi.sh` script to start NiFi:

~~~
./nifi.sh start
~~~

> Note: to stop NiFi, type `./nifi.sh stop`

Open the NiFi DataFlow at `http://sandbox.hortonworks.com:6434/nifi/` to verify NiFi started. Wait 1 minute for NiFi to load. If NiFi HTML interface doesn't load, verify the value in the nifi.properties file matches **nifi.web.http.port=6434**.

4\. Navigate to the **conf** folder and open nifi.properties in the vi editor.

~~~
cd ../conf
vi nifi.properties
~~~

5\. Type `/nifi.web.http.port` and press enter. Verify `6434` is the value of nifi.web.http.port as below, else change it to this value:

~~~
nifi.web.http.port=6434
~~~

To exit the vi editor, press `esc` and then enter `:wq` to save the file.
Now that the configuration in the nifi.properties file has been updated, we need to port forward a new port for NiFi through the Port Forward GUI because the virtual machine is not listening for the port **6434**, so NiFi will not load on the browser. If your using VirtualBox Sandbox, refer to section 4.1. For Azure Sandbox users, refer to section 4.2.

### 4.1 Forward Port with VirtualBox GUI

1\. Open VirtualBox Manager

2\. Right click your running Hortonworks Sandbox, click **settings**

3\. Go to the **Network** Tab

Click the button that says **Port Forwarding**. Overwrite NiFi entry with the following values:

| Name  | Protocol  | Host IP  | Host Port  | Guest IP  | Guest Port  |
|---|---|---|---|---|---|
| NiFi  | TCP  | 127.0.0.1  | 6434  |   | 6434  |

![port_forward_nifi_iot](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/port_forward_nifi_iot.png)


4\. Open NiFi at `http://sandbox.hortonworks.com:6434/nifi/`. You should be able to access it now. Wait 1 to 2 minutes for NiFi to load.

> Note: if you haven't configured the `sandbox.hortonworks.com` alias in `/etc/hosts`, try the `http://localhost:6434/nifi` URL as well.

### 4.2 Forward Port with Azure GUI

1\. Open Azure Sandbox.

2\. Click the sandbox with the **shield icon**.

![shield-icon-security-inbound.png](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/shield-icon-security-inbound.png)

3\. Under **Settings**, in the **General** section, click **Inbound Security Rules**.

![inbound-security-rule.png](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/inbound-security-rule.png)

4\. Scroll to **NiFi**, click on the row.

![list-nifi-port.png](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/list-nifi-port.png)

5\. Change the **Destination Port Range** value from 9090 to 6434.

![change-nifi-port.png](/assets/learning-ropes-nifi-lab-series/lab0-download-install-start-nifi/change-nifi-port.png)

6\. Open NiFi at `http://sandbox.hortonworks.com:6434/nifi/`. You should be able to access it now. Wait 1 to 2 minutes for NiFi to load.


### Step 5: Start NiFi on Local Machine

If you downloaded and installed NiFi on your local machine, refer to this step. Now let's start NiFi. There are 3 methods to start NiFi: launch NiFi in foreground, in the background or as a service. Refer to [Starting NiFi Documentation](http://docs.hortonworks.com/HDPDocuments/HDF1/HDF-1.2.0.1/bk_HDF_InstallSetup/content/starting-nifi.html) to learn more.

1\. We will start NiFi in the background: open a terminal window or git bash, navigate to NiFi installation directory and enter:

~~~bash
./HDF-1.2.0.1-1/nifi/bin/nifi.sh start
~~~

## Conclusion

Congratulations! You learned that NiFi can be installed on virtual machine or directly on your computer. You also learned to download, install and start NiFi. Now that NiFi is up and running, we are ready to build our dataflow.

## Further Reading

- For more information on NiFi Configuration, view [System Administrator's Guide](http://docs.hortonworks.com/HDPDocuments/HDF1/HDF-1.2.0.1/bk_AdminGuide/content/index.html)
