#!/bin/bash
echo "Start Docker HDF Sandbox..."
docker start sandbox-hdf
echo "Starting Ambari Services, may take 2.5 minutes..."
docker exec -d sandbox-hdf /root/start_sandbox.sh
docker exec -d sandbox-hdf /etc/init.d/shellinaboxd start
docker exec -d sandbox-hdf /etc/init.d/tutorials start
sleep 150
