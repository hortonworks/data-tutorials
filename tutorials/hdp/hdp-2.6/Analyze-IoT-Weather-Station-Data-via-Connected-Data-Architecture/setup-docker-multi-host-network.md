docker multi-host networking

1. specify 1st host node is the manager (HDP)

~~~
[root@sandbox ~]# docker swarm init <ip-address>
~~~

2. Add a worker to this swarm, use command inside 2nd host node (HDF)

~~~
[root@sandbox-host ~]#     docker swarm join \
    --token SWMTKN-1-559yd7nvwvanddcsnrl4cynhd5nxzhbnskwnu05o4ajisqrz7w-dibnughqbyt8vs3s7u2aexnp2 \
    10.0.2.15:2377
~~~

ISSUE: Note: the command generated above will be different for every manager node, when user runs docker swarm init

command generates rpc error:

Error response from daemon: rpc error: code = 14 desc = grpc: the connection is unavailable

Why?
Answer pending

3. Check that worker node has been added to manager’s swarm

~~~
[root@sandbox ~]# docker node ls
~~~

4. Check if there are new networks being used internally:

~~~
[root@sandbox ~]# docker network ls
~~~

5. Create a new network to span both hosts. We’re using the overlay driver and calling it overnet (arbitrary name)

~~~
[root@sandbox ~]# docker network create -d overlay overnet
~~~

6. Check the network was created
docker network ls

7. Stick containers onto this new network. How to do that? Create a service with a couple of tasks.

~~~
[root@sandbox ~]#  docker service create --name myService \
--network overnet \
--replicas 2 \
sandbox-hdf sleep 1d
~~~

What’s happening in the command above?
First create a new service called myservice and attach it
to the overlay network overnet and tells it to running
two replicas of containers and telling it an image to use
the command to run.

8. Verify the service works:

~~~
[root@sandbox ~]# docker service ls
~~~

It should show the replicas of containers

9. Drill a bit deeper to verify one replica is running on each of our two nodes:

~~~
[root@sandbox ~]# docker service ps myservice
~~~

The next two commands will be used to verify both containers are running on the same network:

10. inspect our network, use command on node 1:

~~~
[root@sandbox ~]# docker network inspect overnet
~~~

It'll show our local container running and it's IP. Reference the IP of container running on node 1: `10.0.0.3`.

11. Jump to node 2. Run same command to inspect network on node 2:

~~~
[root@sandbox-host ~]# docker network inspect overnet
~~~

You'll see the 2nd container is connected to the same overlay network as the 1st container. Check under Options to verify both containers are on the same network.

What we see with the container running on node 2 is that it has a different IP address than node 1. Container on node 2 has different IP: `10.0.0.4`, but the container is on the same layer 2 subnet.

12. Log onto that container, we need it's `Container ID`: `77bef16771a5`. Use command to execute a shell session on node 2 container:

~~~
[root@sandbox-host ~]# docker exec -it 77bef16771a5 sh
~~~

The moment of truth, can we ping the container on node 1 from container running on node 2?

13. Check with the ping command:

~~~
/# ping 10.0.0.3
~~~

Why is pinging one container from the other important?
- verify the other container node was added to the network correctly

You should receive bytes indicating your container on node 2 is able to connect with node 1 container.

What have just learned?
- We have taken two docker hosts on separate networks
- Created an overlay network spanning both of them
- Attached a couple of containers to that network: one container on each node
- We verified both got IP addresses from the overlay
- Jumped on one container and made sure we could ping the other
