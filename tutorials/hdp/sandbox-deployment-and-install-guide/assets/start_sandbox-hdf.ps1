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
    docker run -v hadoop:/hadoop --name sandbox-hdf --hostname "sandbox-hdf.hortonworks.com" --privileged -d `
    -p 12181:2181 `
    -p 13000:3000 `
    -p 14200:4200 `
    -p 14557:4557 `
    -p 16080:6080 `
    -p 18000:8000 `
    -p 9080:8080 `
    -p 18744:8744 `
    -p 18886:8886 `
    -p 18888:8888 `
    -p 18993:8993 `
    -p 19000:9000 `
    -p 19090:9090 `
    -p 19091:9091 `
    -p 43111:42111 `
    -p 62888:61888 `
    -p 25000:15100 `
    -p 25001:15101 `
    -p 25002:15102 `
    -p 25003:15103 `
    -p 25004:15104 `
    -p 25005:15105 `
    -p 17000:17000 `
    -p 17001:17001 `
    -p 17002:17002 `
    -p 17003:17003 `
    -p 17004:17004 `
    -p 17005:17005 `
    -p 12222:22 sandbox-hdf /usr/sbin/sshd -D | Out-Null
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
docker exec -d sandbox-hdf service ambari-server start |  Out-Host
docker exec -d sandbox-hdf service ambari-agent start | Out-Host
docker exec -d sandbox-hdf /root/start_sandbox.sh | Out-Host
docker exec -d sandbox-hdf /etc/init.d/shellinaboxd start | Out-Host
docker exec -d sandbox-hdf /etc/init.d/tutorials start | Out-Host

Write-Host "HDF Sandbox is good to do.  Press any key to continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

return
