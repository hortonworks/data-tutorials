---
title: Running the Demo
---

# Storm in Trucking IoT on HDF

## Running the Demo

## Introduction

Let's walk through the demo and get an understanding for the data pipeline before we dive deeper into Storm internals.


## Outline

- [Environment Setup](#environment-setup)
- [Generate Sensor Data](#generate-sensor-data)
- [Deploy the Storm Topology](#deploy-the-storm-topology)
- [Verify the Processed Data](#verify-the-processed-data)
- [Next: Building a Storm Topology](#next-building-a-storm-topology)

## Environment Setup

SSH into your Hortonworks DataFlow (HDF) environment and download the corresponding demo project.

```bash
git clone https://github.com/orendain/trucking-iot-demo-storm-on-scala
cd trucking-iot-demo-storm-on-scala
```

## Generate Sensor Data

The demo application leverages a very robust data simulator, which generates data of two types and publishes them to Kafka topics as a CSV string.

`EnrichedTruckData`: Data simulated by sensors onboard each truck.  For the purposes of this demo, this data has been pre-enriched with data from a weather service.

```scala
1488767711734|26|1|Edgar Orendain|107|Springfield to Kansas City Via Columbia|38.95940879245423|-92.21923828125|65|Speeding|1|0|1|60
```

![EnrichedTruckData fields](assets/enriched-truck-data_fields.png)

`TrafficData`: Data simulated from an online traffic service, which reports on traffic congestion on any particular trucking route.

```scala
1488767711734|107|60
```

![TrafficData fields](assets/traffic-data_fields.png)

Start the data generator by executing the appropriate script:

```scala
scripts/run-simulator.sh
```

Let's wait for the simulator to finish generating data.  Once that's done, we can look at the data that was generated and stored in Kafka:

> Note: "Ctrl + c" to exit out from the Kafka command.

```bash
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --from-beginning --topic trucking_data_truck_enriched
```

and

```bash
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --from-beginning --topic trucking_data_traffic
```

## Deploy the Storm Topology

With simulated data now being pumped into Kafka topics, we power up Storm and process this data.  In a separate terminal window, run the following command:

```bash
scripts/deploy-prebuilt-topology.sh
```

> Note: We'll cover what exactly a "topology" is in the next section.

Here is a slightly more in-depth look at the steps Storm is taking in processing and transforming the two types of simulated data from above.

![General Storm Process](assets/storm-flow-overview.jpg)

## Verify the Processed Data

With the data now fully processed by Storm and published back into accessible Kafka topics, it's time to verify our handiwork.  Run the following command to list the joined set of data.

```bash
/usr/hdf/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server sandbox-hdf.hortonworks.com:6667 --from-beginning --topic trucking_data_joined
```

Nice!  Our topology joined data from two separate streams of data.

## Next: Building a Storm Topology

Now that we know how Storm fits into this data pipeline and what type of work it is performing, let's dive into the actual code and see exactly how it is built.
