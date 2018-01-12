#!/bin/bash
echo "Waiting for docker daemon to start up:"
until docker ps 2>&1| grep STATUS>/dev/null; do  sleep 1; done;  >/dev/null
docker ps -a | grep sandbox-hdp
if [ $? -eq 0 ]; then
 docker start sandbox-hdp
else
docker run --name sandbox-hdp --hostname "sandbox-hdp.hortonworks.com" --privileged -d \
-p 15500:15500 \
-p 15501:15501 \
-p 15502:15502 \
-p 15503:15503 \
-p 15504:15504 \
-p 15505:15505 \
-p 1111:111 \
-p 4242:4242 \
-p 50079:50079 \
-p 6080:6080 \
-p 16000:16000 \
-p 16020:16020 \
-p 10502:10502 \
-p 33553:33553 \
-p 39419:39419 \
-p 15002:15002 \
-p 18080:18080 \
-p 10015:10015 \
-p 10016:10016 \
-p 2049:2049 \
-p 9090:9090 \
-p 3000:3000 \
-p 9000:9000 \
-p 8000:8000 \
-p 8020:8020 \
-p 2181:2181 \
-p 42111:42111 \
-p 10500:10500 \
-p 16030:16030 \
-p 8042:8042 \
-p 8040:8040 \
-p 2100:2100 \
-p 4200:4200 \
-p 4040:4040 \
-p 8032:8032 \
-p 9996:9996 \
-p 9995:9995 \
-p 8080:8080 \
-p 8088:8088 \
-p 8886:8886 \
-p 8889:8889 \
-p 8443:8443 \
-p 8744:8744 \
-p 8888:8888 \
-p 8188:8188 \
-p 8983:8983 \
-p 1000:1000 \
-p 1100:1100 \
-p 11000:11000 \
-p 10001:10001 \
-p 15000:15000 \
-p 10000:10000 \
-p 8993:8993 \
-p 1988:1988 \
-p 5007:5007 \
-p 50070:50070 \
-p 19888:19888 \
-p 16010:16010 \
-p 50111:50111 \
-p 50075:50075 \
-p 50095:50095 \
-p 18081:18081 \
-p 60000:60000 \
-p 8090:8090 \
-p 8091:8091 \
-p 8005:8005 \
-p 8086:8086 \
-p 8082:8082 \
-p 60080:60080 \
-p 8765:8765 \
-p 5011:5011 \
-p 6001:6001 \
-p 6003:6003 \
-p 6008:6008 \
-p 1220:1220 \
-p 21000:21000 \
-p 6188:6188 \
-p 2222:22 \
sandbox-hdp /usr/sbin/sshd -D
fi
docker exec -t sandbox-hdp /bin/sh -c 'echo "127.0.0.1 sandbox.hortonworks.com" >> /etc/hosts'
docker exec -t sandbox-hdp /bin/sh -c 'chown -R mysql:mysql /var/lib/mysql'
docker exec -t sandbox-hdp service mysqld start
docker exec -t sandbox-hdp service postgresql start
docker exec -t sandbox-hdp ambari-server start
docker exec -t sandbox-hdp ambari-agent start
docker exec -t sandbox-hdp /bin/sh -c 'rm -f /usr/hdp/current/oozie-server/libext/falcon-oozie-el-extension-*'
docker exec -t sandbox-hdp /bin/sh -c 'chown -R hdfs:hadoop /hadoop/hdfs'
docker exec -t sandbox-hdp /etc/init.d/shellinaboxd start


echo "Waiting for ambari agent to connect"
docker exec -t sandbox-hdp /bin/sh -c ' until curl --silent -u raj_ops:raj_ops -H "X-Requested-By:ambari" -i -X GET  http://localhost:8080/api/v1/clusters/Sandbox/hosts/sandbox-hdp.hortonworks.com/host_components/ZOOKEEPER_SERVER | grep state | grep -v desired | grep INSTALLED; do sleep 5; echo -n .; done;'

echo "Waiting for ambari services to start "
docker exec -t sandbox-hdp /bin/sh -c 'until curl --silent --user raj_ops:raj_ops -X PUT -H "X-Requested-By: ambari"  -d "{\"RequestInfo\":{\"context\":\"_PARSE_.START.HDFS\",\"operation_level\":{\"level\":\"SERVICE\",\"cluster_name\":\"Sandbox\",\"service_name\":\"HDFS\"}},\"Body\":{\"ServiceInfo\":{\"state\":\"STARTED\"}}}" http://localhost:8080/api/v1/clusters/Sandbox/services/HDFS | grep -i accept >/dev/null; do echo -n .; sleep 5; done;'

docker exec -t sandbox-hdp /bin/sh -c 'until curl --silent --user raj_ops:raj_ops -X PUT -H "X-Requested-By: ambari"  -d "{\"RequestInfo\":{\"context\":\"_PARSE_.START.ALL_SERVICES\",\"operation_level\":{\"level\":\"CLUSTER\",\"cluster_name\":\"Sandbox\"}},\"Body\":{\"ServiceInfo\":{\"state\":\"STARTED\"}}}" http://localhost:8080/api/v1/clusters/Sandbox/services | grep -i accept > /dev/null; do sleep 5; echo -n .; done; '

docker exec -t sandbox-hdp /bin/sh -c 'until /usr/bin/curl --silent --user raj_ops:raj_ops -H "X-Requested-By: ambari" "http://localhost:8080/api/v1/clusters/Sandbox/requests?to=end&page_size=10&fields=Requests" | tail -n 27 | grep COMPLETED | grep COMPLETED > /dev/null; do echo -n .; sleep 1; done;'

docker exec -t sandbox-hdp su - hue -c '/bin/bash /usr/lib/tutorials/tutorials_app/run/run.sh &>/dev/null'
docker exec -t sandbox-hdp su - hue -c '/bin/bash /usr/lib/hue/tools/start_scripts/update-tutorials.sh &>/dev/null'
docker exec -t sandbox-hdp touch /usr/hdp/current/oozie-server/oozie-server/work/Catalina/localhost/oozie/SESSIONS.ser
docker exec -t sandbox-hdp chown oozie:hadoop /usr/hdp/current/oozie-server/oozie-server/work/Catalina/localhost/oozie/SESSIONS.ser
docker exec -t sandbox-hdp /etc/init.d/tutorials start
docker exec -t sandbox-hdp /etc/init.d/splash
echo ""
echo "Started Hortonworks HDP container"
