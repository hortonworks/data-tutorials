#!/bin/bash
echo "Deploying HDF Sandbox Container:"
until docker ps 2>&1| grep STATUS>/dev/null; do  sleep 1; done; >/dev/null
docker ps -a | grep sandbox-hdf
if [ $? -eq 0 ]; then
 docker start sandbox-hdf
else
docker run --name sandbox-hdf --hostname "sandbox-hdf.hortonworks.com" --privileged -d \
-p 9999:9999 \
-p 12181:2181 \
-p 17010:17010 \
-p 51070:51070 \
-p 13000:13000 \
-p 14200:4200 \
-p 14557:4557 \
-p 16080:6080 \
-p 18000:8000 \
-p 9080:8080 \
-p 18088:18088 \
-p 18744:18744 \
-p 18886:18886 \
-p 28886:28886 \
-p 18888:8888 \
-p 18993:8993 \
-p 19000:9000 \
-p 19090:19090 \
-p 19091:9091 \
-p 42111:42111 \
-p 62888:62888 \
-p 25100:15100 \
-p 25101:15101 \
-p 25102:15102 \
-p 25103:15103 \
-p 25104:15104 \
-p 25105:15105 \
-p 27000:17000 \
-p 27001:17001 \
-p 27002:17002 \
-p 27003:17003 \
-p 27004:17004 \
-p 27005:17005 \
-p 18081:18081 \
-p 18090:18090 \
-p 19060:19060 \
-p 19089:19089 \
-p 19888:19888 \
-p 16667:6667 \
-p 17777:17777 \
-p 17788:17788 \
-p 17789:7789 \
-p 12222:22 \
sandbox-hdf /usr/sbin/sshd -D
fi
echo "Starting Ambari Services, may take 2.5 minutes..."
docker exec -d sandbox-hdf service mysqld start
docker exec -d sandbox-hdf service postgresql start
docker exec -t sandbox-hdf ambari-server start
docker exec -t sandbox-hdf ambari-agent start
docker exec -t sandbox-hdf  /bin/sh -c ' until curl -u admin:admin -H "X-Requested-By:ambari" -i -X GET  http://localhost:8080/api/v1/clusters/Sandbox/hosts/sandbox-hdf.hortonworks.com/host_components/ZOOKEEPER_SERVER | grep state | grep -v desired | grep INSTALLED; do sleep 1; done; sleep 10'
docker exec -d sandbox-hdf /root/start_sandbox.sh
docker exec -d sandbox-hdf /etc/init.d/tutorials start
docker exec -d sandbox-hdf /etc/init.d/shellinaboxd start
echo "Successfully Started HDF Sandbox Container"
sleep 150
