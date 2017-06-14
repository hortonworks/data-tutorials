---
title: Sandbox Port Forwarding on VMWare
---

# Sandbox Port Forwarding on VMWare

## Introduction

In order to explain opening ports and port forwarding in the VMWare version of the Hortonworks Sandbox, it may be a good idea to first have a high level view of what the sandbox looks like. Have a look at the graphic below, which shows where the sandbox exists in relation to the outside world and the port forwarding that exists.

![VMWare Sandbox Architecture](assets/vmware-sandbox-architecture.jpg)

## Outline

-   [SSH Into the VM Running Docker](#ssh-into-the-vm-running-docker)
-   [Add Ports to the Docker Script](#add-ports-to-the-docker-script)
-   [Remove the Current Sandbox Container](#remove-the-current-sandbox-container)
-   [Restart the VM Running Docker](#restart-the-vm-running-docker)
-   [Summary](#summary)

## SSH Into the VM Running Docker

We need to login to the virtual machine that runs the sandbox container. If you use the standard sandbox `ssh -p 2222 root@sandbox.hortonworks.com`, you will actually log into the sandbox container, not the containing VM where Docker changes are made. You want to log into the VM running Docker with the following command:

```
ssh -p 2122 root@sandbox.hortonworks.com
```

> Note: The default password is `hadoop`.

## Add Ports to the Docker Script

The script in the VM that is responsible for creating the dockerized sandbox container is located at `/root/start_scripts/start_sandbox.sh`.

Open `/root/start_scripts/start_sandbox.sh` to reveal the docker script, which looks something like the following:

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

## Restart the VM Running Docker

We now restart the VM running Docker.  Upon restart, the script we modified above will be run in order to start the sandbox container.  Since we removed the container in the previous step, the sandbox container is first rebuilt with your newly specified port forwards.

One easy method of restarting the VM is executing the following command:

```
init 6
```

## Summary

That's it!  There is no need to make changes to your VMWare product as all ports are automatically opened and forwarded.

You've successfully modified the sandbox container's startup script and added in new port forwards.  The forwarded ports allow you to access processes running on the sandbox from your host system (i.e. your computer and browser).
