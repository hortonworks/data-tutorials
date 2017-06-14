---
title: Sandbox Port Forwarding on Docker
---

# Sandbox Port Forwarding on Docker

## Introduction

We'll walk through how to open a port for Docker so that outside connections may make their way into the sandbox.

## Outline

-   [Add Ports to the Docker Script](#add-ports-to-the-docker-script)
-   [Remove the Current Sandbox Container](#remove-the-current-sandbox-container)
-   [Recreate the Sandbox Container](#recreate-the-sandbox-container)
-   [Summary](#summary)

## Add Ports to the Docker Script

When you first deployed the sandbox on Docker, you used a script named something similar to `start-sandbox-hdx.sh`.  That script is responsible for instructing Docker how to create the dockerized sandbox container.  Find this script, as it is what we will be making changes to.

If you no longer have the script, the default scripts are listed below for you to download and edit.

-   For Linux/Mac: Use the [start-sandbox-hdp.sh](assets/start-sandbox-hdp.sh)
-   For Windows: Use the [start-sandbox-hdp.ps1](assets/start-sandbox-hdp.ps1)

Open the script, which looks something like the following:

```
docker run -v hadoop:/hadoop --name sandbox --hostname "sandbox.hortonworks.com" --privileged -d \
-p 6080:6080 \
-p 9090:9090 \
-p 9000:9000 \
-p 8000:8000 \
-p 8020:8020 \
-p 2181:2181 \
-p 42111:42111 \
...
```

Edit this file and add your desired port forward.  In this example, we're going to forward host port 15000 to sandbox port 15000.  The file should now look something like the following:

```
docker run -v hadoop:/hadoop --name sandbox --hostname "sandbox.hortonworks.com" --privileged -d \
-p 15000:15000 \
-p 6080:6080 \
-p 9090:9090 \
-p 9000:9000 \
-p 8000:8000 \
-p 8020:8020 \
-p 2181:2181 \
-p 42111:42111 \
...
```

## Remove the Current Sandbox Container

Terminate the existing sandbox container, and then remove it.

> Warning: Be aware that this deletes the sandbox, changes are not saved.  If you want to save the work you've done inside the sandbox, first run: `docker commit sandbox sandbox`.

```
docker stop sandbox
docker rm sandbox
```

## Recreate the Sandbox Container

To recreate the sandbox container, simply run the script you just modified.  Since we removed the container in the previous step, the script will first rebuild the sandbox container with your newly specified port forwards.

Below are common methods of running scripts.

For Linux/Mac:
```
/path/to/your/start-sandbox-script.sh
```

For Windows:
Right click on the script and click "**Run with PowerShell**"

## Summary

You've successfully modified the sandbox container's startup script and added new port forwards.  The forwarded ports allow you to access processes running on the sandbox from your host system (i.e. your computer and browser).
