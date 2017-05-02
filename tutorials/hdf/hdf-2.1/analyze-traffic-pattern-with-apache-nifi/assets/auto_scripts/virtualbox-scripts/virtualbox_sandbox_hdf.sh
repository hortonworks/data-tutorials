#!/bin/bash
echo "Start VirtualBox VM's Docker HDF Sandbox..."
vboxmanage startvm "Hortonworks Docker Sandbox HDF"
echo "Starting Ambari Services, may take 2.5 minutes..."
sleep 150
