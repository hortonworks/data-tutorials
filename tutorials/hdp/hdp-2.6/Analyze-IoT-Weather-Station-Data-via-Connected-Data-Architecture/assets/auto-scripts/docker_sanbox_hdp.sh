#!/bin/bash
#!/bin/bash
echo "Start Docker HDP Sandbox..."
docker start sandbox-hdp
echo "Starting Ambari Services, may take 2.5 minutes..."
docker exec -d sandbox-hdp /etc/init.d/startup_script start
docker exec -d sandbox-hdp /etc/init.d/shellinaboxd start
docker exec -d sandbox-hdp /etc/init.d/tutorials start
sleep 150
echo "Successfully Started HDP Sandbox Container"
