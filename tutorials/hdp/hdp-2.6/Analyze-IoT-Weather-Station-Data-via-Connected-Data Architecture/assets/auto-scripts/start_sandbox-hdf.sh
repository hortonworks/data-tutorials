#!/bin/bash
echo "Deploying HDF Sandbox Container:"
until docker ps 2>&1| grep STATUS>/dev/null; do  sleep 1; done;
>/dev/null docker ps -a | grep sandbox-hdf
if [ $? -eq 0 ]; then
 docker start sandbox-hdf
else
docker run -v hadoop:/hadoop --name sandbox-hdf --hostname "sandbox-hdf.hortonworks.com" --privileged -d \
-p 12181:2181 \
-p 13000:3000 \
-p 14200:4200 \
-p 16080:6080 \
-p 18000:8000 \
-p 9080:8080 \
-p 18744:8744 \
-p 18886:8886 \
-p 18888:8888 \
-p 18993:8993 \
-p 19000:9000 \
-p 19090:9090 \
-p 19091:9091 \
-p 43111:42111 \
-p 62888:61888 \
-p 25000:15000 \
-p 25001:15001 \
-p 25002:15002 \
-p 25003:15003 \
-p 25004:15004 \
-p 25005:15005 \
-p 17000:17000 \
-p 17001:17001 \
-p 17002:17002 \
-p 17003:17003 \
-p 17004:17004 \
-p 17005:17005 \
-p 12222:22 \
sandbox-hdf /usr/sbin/sshd -D
fi
echo "Starting Ambari Services, may take 2.5 minutes..."
#docker exec -t sandbox /etc/init.d/startup_script start
docker exec -d sandbox-hdf service mysqld start
docker exec -d sandbox-hdf service ambari-server start
docker exec -d sandbox-hdf service ambari-agent start
docker exec -d sandbox-hdf /root/start_sandbox.sh
docker exec -d sandbox-hdf /etc/init.d/shellinaboxd start
docker exec -d sandbox-hdf /etc/init.d/tutorials start
sleep 150
echo "Successfully Started HDF Sandbox Container"
