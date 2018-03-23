---
title: Manage Files on HDFS with the Command Line
---

# Manage Files on HDFS via Cli/Ambari Files View

## Manage Files on HDFS with the Command Line

## Introduction

In this tutorial, we will walk through many of the common of the basic Hadoop Distributed File System (HDFS) commands you will need to manage files on HDFS. The particular datasets we will utilize to learn HDFS file management are San Francisco salaries from 2011-2014.

## Prerequisites
-   Downloaded and Installed latest [HDP Sandbox](https://hortonworks.com/downloads/#sandbox)
-   If you're planning to deploy your sandbox on Azure, refer to this tutorial: [Deploying the Sandbox on Azure](https://hortonworks.com/hadoop-tutorial/deploying-hortonworks-sandbox-on-microsoft-azure/)
-   [Learning the Ropes of the HDP Sandbox](https://hortonworks.com/hadoop-tutorial/learning-the-ropes-of-the-hortonworks-sandbox/)
-   Allow yourself around **1 hour** to complete this tutorial.

### Download San Francisco Salary Related Datasets

We will download **sf-salaries-2011-2013.csv** and **sf-salaries-2014.csv** data onto our local filesystems of the sandbox. The commands are tailored for mac and linux users.

1\. Open a terminal on your local machine, SSH into the sandbox:

~~~
ssh root@127.0.0.1 -p 2222
~~~

> Note: If you're on VMware or Azure, insert your appropriate IP address in place of 127.0.0.1. Azure users will need to replace port 2222 with 22.

2\. Copy and paste the commands to download the **sf-salaries-2011-2013.csv** and **sf-salaries-2014.csv** files. We will use them while we learn file management operations.

~~~
# download sf-salaries-2011-2013
wget https://github.com/hortonworks/data-tutorials/raw/master/tutorials/hdp/manage-files-on-hdfs-via-cli-ambari-files-view/assets/sf-salary-datasets/sf-salaries-2011-2013.csv
# download sf-salaries-2014
wget https://github.com/hortonworks/data-tutorials/raw/master/tutorials/hdp/manage-files-on-hdfs-via-cli-ambari-files-view/assets/sf-salary-datasets/sf-salaries-2014.csv
~~~

![sf_salary_datasets](assets/sf_salary_datasets.png)

## Outline
-   [Step 1: Create a Directory in HDFS, Upload a file and List Contents](#create-a-directory-in-hdfs-upload-a-file-and-list-contents)
-   [Step 2: Find Out Space Utilization in a HDFS Directory](#find-out-space-utilization-in-a-hdfs-directory)
-   [Step 3: Download Files From HDFS to Local File System](#download-files-hdfs-to-local-file-system)
-   [Step 4: Explore Two Advanced Features](#explore-two-advanced-features)
-   [Step 5: Use Help Command to Access Hadoop Command Manual](#use-help-command-access-hadoop-command-manual)
-   [Summary](#summary)
-   [Further Reading](#further-reading)

## Step 1: Create a Directory in HDFS, Upload a file and List Contents <a id="create-a-directory-in-hdfs-upload-a-file-and-list-contents"></a>

Let's learn by writing the syntax. You will be able to copy and paste the following example commands into your terminal. Let's login under **hdfs** user, so we can give root user permission to perform file operations:

~~~
su hdfs
cd
~~~

We will use the following command to run filesystem commands on the file system of hadoop:

~~~
hdfs dfs [command_operation]
~~~

> Refer to the [File System Shell Guide](https://hadoop.apache.org/docs/r2.7.1/hadoop-project-dist/hadoop-common/FileSystemShell.html) to view various command_operations.

### hdfs dfs -chmod:

-   Affects the permissions of the folder or file. Controls who has read/write/execute privileges
-   We will give root access to read and write to the user directory. Later we will perform an operation in which we send a file from our local filesystem to hdfs.

~~~
hdfs dfs -chmod 777 /user
~~~

-   Warning in production environments, setting the folder with the permissions above is not a good idea because anyone can read/write/execute files or folders.

Type the following command, so we can switch back to the root user. We can perform the remaining file operations under the **user** folder since the permissions were changed.

~~~
exit
~~~

### hdfs dfs -mkdir:

*   Takes the path URI's as an argument and creates a directory or multiple directories.

~~~
# Usage:
        # hdfs dfs -mkdir <paths>
# Example:
        hdfs dfs -mkdir /user/hadoop
        hdfs dfs -mkdir /user/hadoop/sf-salaries-2011-2013 /user/hadoop/sf-salaries /user/hadoop/sf-salaries-2014
~~~

### hdfs dfs -put:

*   Copies single src file or multiple src files from local file system to the Hadoop Distributed File System.

~~~
# Usage:
        # hdfs dfs -put <local-src> ... <HDFS_dest_path>
# Example:
        hdfs dfs -put sf-salaries-2011-2013.csv /user/hadoop/sf-salaries-2011-2013/sf-salaries-2011-2013.csv
        hdfs dfs -put sf-salaries-2014.csv /user/hadoop/sf-salaries-2014/sf-salaries-2014.csv
~~~

### hdfs dfs -ls:

*   Lists the contents of a directory
*   For a file, returns stats of a file

~~~
# Usage:
        # hdfs dfs  -ls  <args>
# Example:
        hdfs dfs -ls /user/hadoop
        hdfs dfs -ls /user/hadoop/sf-salaries-2011-2013
        hdfs dfs -ls /user/hadoop/sf-salaries-2011-2013/sf-salaries-2011-2013.csv
~~~

![list_folder_contents](assets/tutorial1/list_folder_contents.png)

## Step 2: Find Out Space Utilization in a HDFS Directory <a id="find-out-space-utilization-in-a-hdfs-directory"></a>

### hdfs dfs -du:

*   Displays size of files and directories contained in the given directory or the size of a file if its just a file.

~~~
# Usage:
    # hdfs dfs -du URI
# Example:
        hdfs dfs -du  /user/hadoop/ /user/hadoop/sf-salaries-2011-2013/sf-salaries-2011-2013.csv
~~~

![displays_entity_size](assets/tutorial1/displays_entity_size.png)

## Step 3: Download Files From HDFS to Local File System <a id="download-files-hdfs-to-local-file-system"></a>

### hdfs dfs -get:

*   Copies/Downloads files from HDFS to the local file system

~~~
# Usage:
        # hdfs dfs -get <hdfs_src> <localdst>
# Example:
        hdfs dfs -get /user/hadoop/sf-salaries-2011-2013/sf-salaries-2011-2013.csv /home/
~~~

## Step 4: Explore Two Advanced Features <a id="explore-two-advanced-features"></a>

### hdfs dfs -getmerge

*   Takes a source directory file or files as input and concatenates files in src into the local destination file.
*   Concatenates files in the same directory or from multiple directories as long as we specify their location and outputs them to the local file system, as can be seen in the **Usage** below.
*   Let's concatenate the San Francisco salaries from two separate directories and output them to our local filesystem. Our result will be the salaries from 2014 which are appended below the last row of 2011-2013.

~~~
# Usage:
        # hdfs dfs -getmerge <src> <localdst> [addnl]
        # hdfs dfs -getmerge <src1> <src2> <localdst> [addnl]
# Option:
        # addnl: can be set to enable adding a newline on end of each file
# Example:
        hdfs dfs -getmerge /user/hadoop/sf-salaries-2011-2013/ /user/hadoop/sf-salaries-2014/ /root/output.csv
~~~

> Merges the files in sf-salaries-2011-2013 and sf-salaries-2014 to output.csv in the root directory of the local filesystem. The first file contained about 120,000 rows and the second file contained almost 30,000 rows. This file operation is important because it will save you time from having to manually concatenate them.

### hdfs dfs -cp:

*   Copy file or directories recursively, all the directory's files and subdirectories to the bottom of the directory tree are copied.
*   It is a tool used for large inter/intra-cluster copying

~~~
# Usage:
        # hdfs dfs -cp <src-url> <dest-url>
# Example:
        hdfs dfs -cp /user/hadoop/sf-salaries-2011-2013/ /user/hadoop/sf-salaries-2014/ /user/hadoop/sf-salaries
~~~

> -cp: copies sf-salaries-2011-2013, sf-salaries-2014 and all their contents to sf-salaries

Verify the files or directories successfully copied to the destination folder:

~~~
hdfs dfs -ls /user/hadoop/sf-salaries/
hdfs dfs -ls /user/hadoop/sf-salaries/sf-salaries-2011-2013
hdfs dfs -ls /user/hadoop/sf-salaries/sf-salaries-2014
~~~

![visual_result_of_distcp](assets/tutorial1/visual_result_of_cp.png)

> Visual result of distcp file operation. Notice that both src1 and src2 directories and their contents were copied to the dest directory.

## Step 5: Use Help Command to access Hadoop Command Manual <a id="use-help-command-access-hadoop-command-manual"></a>

Help command opens the list of commands supported by Hadoop Data File System (HDFS)

~~~
# Example:
        hdfs dfs  -help
~~~

![hadoop_help_command_manual](assets/tutorial1/help_command.png)

Hope this short tutorial was useful to get the basics of file management.

## Summary
Congratulations! We just learned to use commands to manage our **sf-salaries-2011-2013.csv** and **sf-salaries-2014.csv** dataset files in HDFS. We learned to create, upload and list the the contents in our directories. We also acquired the skills to download files from HDFS to our local file system and explored a few advanced features of HDFS file management using the command line.

## Further Reading <a id="further-reading"></a>
-   [HDFS Overview](https://hortonworks.com/hadoop/hdfs/)
-   [Hadoop File System Documentation](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/FileSystemShell.html)
