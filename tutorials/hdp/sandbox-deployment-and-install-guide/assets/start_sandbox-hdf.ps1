Write-Host "Checking docker daemon..."
If ((Get-Process | Select-String docker) -ne $null) {
    Write-Host "Docker is up and running"
}
Else {
    $Host.UI.WriteErrorLine("Please start Docker service. https://docs.docker.com/docker-for-windows/")
    return
}

If ((docker images | Select-String sandbox-hdf) -ne $null) {
    Write-Host "Found HDF Sandbox image"
}
Else {
    $Host.UI.WriteErrorLine("Please download and load the HDF Sandbox Docker image. https://hortonworks.com/downloads/#sandbox")
    return
}

If ((docker ps -a | Select-String sandbox-hdf) -ne $null) {
    Write-Host "HDF Sandbox container already exists"
}
Else {
    Write-Host "Running HDF Sandbox for the first time..."
    docker run --name sandbox-hdf --hostname "sandbox-hdf.hortonworks.com" --privileged -d `
    -p 9999:9999 `
    -p 12181:2181 `
    -p 26000:16000 `
    -p 17010:16010 `
    -p 17020:16020 `
    -p 17030:16030 `
    -p 51070:50070 `
    -p 13000:3000 `
    -p 14200:4200 `
    -p 14557:4557 `
    -p 16080:6080 `
    -p 18000:8000 `
    -p 9080:8080 `
    -p 18088:8088 `
    -p 18744:8744 `
    -p 28886:8886 `
    -p 38886:18886 `
    -p 18888:8888 `
    -p 18993:8993 `
    -p 19000:9000 `
    -p 9090:9090 `
    -p 9091:9091 `
    -p 43111:42111 `
    -p 62888:61888 `
    -p 15100:15100 `
    -p 15101:15101 `
    -p 15102:15102 `
    -p 15103:15103 `
    -p 15104:15104 `
    -p 15105:15105 `
    -p 17000:17000 `
    -p 17001:17001 `
    -p 17002:17002 `
    -p 17003:17003 `
    -p 17004:17004 `
    -p 17005:17005 `
    -p 28081:8081 `
    -p 18090:8090 `
    -p 19060:9060 `
    -p 19089:9089 `
    -p 29888:29888 `
    -p 16667:6667 `
    -p 17777:7777 `
    -p 17778:7778 `
    -p 17788:7788 `
    -p 17789:7789 `
    -p 12222:22 `
    -p 19090:19090 `
    sandbox-hdf /usr/sbin/sshd -D | Out-Null
}

If ((docker ps | Select-String sandbox-hdf) -ne $null) {
    Write-Host "HDF Sandbox started"
}
Else {
    Write-Host "Starting HDF Sandbox..."
    docker start sandbox-hdf | Out-Host
}

Write-Host "Starting processes on the HDF Sandbox..."

docker exec -d sandbox-hdf service mysqld start | Out-Host
docker exec -d sandbox-hdf service postgresql start | Out-Host
docker exec -t sandbox-hdf ambari-server start | Out-Host
docker exec -t sandbox-hdf ambari-agent start | Out-Host
docker exec -t sandbox-hdf  /bin/sh -c ' until curl --silent -u admin:admin -H "X-Requested-By:ambari" -i -X GET  http://localhost:8080/api/v1/clusters/Sandbox/hosts/sandbox-hdf.hortonworks.com/host_components/ZOOKEEPER_SERVER | grep state | grep -v desired | grep INSTALLED; do sleep 1; done; sleep 10' | Out-Host
docker exec -d sandbox-hdf /root/start_sandbox.sh | Out-Host
docker exec -d sandbox-hdf /etc/init.d/tutorials start | Out-Host
docker exec -d sandbox-hdf /etc/init.d/shellinaboxd start | Out-Host

Write-Host "HDF Sandbox is good to do.  Press any key to continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

return
