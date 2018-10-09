---
title: Deploying the Topology
---

# Storm in Trucking IoT on HDF

## Deploying the Topology

## Introduction

Now that we know how to develop a Storm topology, let's go over how to package it up into a JAR file and deploy it onto a cluster.

## Outline

- [Packaging a JAR](#packaging-a-jar)
- [Deploying to Storm](#deploying-to-storm)
- [Summary](#summary)

## Packaging a JAR

In a terminal, navigate to the trucking-iot-demo-storm-on-scala directory and run:

```scala
scripts/rebuild-and-deploy-topology.sh
```

After installing some dependencies, this script runs the command `sbt assembly` under the hood in order to produce an **uber jar**, housing your topology and all of the dependencies.  The jar is saved to `target/scala-2.12/trucking-iot-demo-storm-on-scala-assembly-1.1.0.jar`.

## Deploying to Storm

If you ran the command in the previous section, then the topology was build **and then also deployed**.

```scala
scripts/rebuild-and-deploy-topology.sh
```

Feel free to open that script to see what it is doing.  Notice that under the hood, it runs a command that looks like the following.

```scala
storm jar trucking-iot-demo-storm-on-scala/target/scala-2.12/trucking-iot-demo-storm-on-scala-assembly-1.1.0.jar com.orendainx.trucking.storm.topologies.KafkaToKafka
```

`storm` will submit the jar to the cluster.  After uploading the jar, `storm` calls the main function of the class we specified (_com.orendainx.trucking.storm.topologies.KafkaToKafka_), which deploys the topology by way of the `StormSubmitter` class.

## Summary

Congratulations!  You now know about the role that Storm plays in a real-time data pipeline and how to create and deploy a topology from scratch.
