Pending: Adding new piece to SAM tutorial with CDA Integration

## Appendix A: HDF and HDP Sandbox Communication

**Slow SINK Approach:** HDF to HDP SINK: For this section, it requires we have two separate laptops running, two separate virtual machines running or two separate Docker containers running with one having HDF and the other having HDP, then we configure each machine to be able to communicat and then we will be able to push data from SAM to Druid or HDFS. The following configuration tables hold the information you would add for Druid and HDFS sink components.

If you go with the Slow SINK Approach route, visit the Appendix to learn how to make the appropriate configurations so HDF Sandbox instance can communicate with an HDP Sandbox instance.

**Fast SINK Approach:** Kafka SINK: since HDF already comes with Kafka, we can use it to push data from one cluster to another Kafka cluster. We just need to create two extra Kafka topics.

**Slow SINK Approach:**

**HDF to HDP SINK**

6\. Add 4 sink components: DRUID, HDFS, HDFS and DRUID onto the canvas.

7\. Connect the AGGREGATE processor to the DRUID sink, then connect it to the HDFS sink. Enter the following configurations for each SINK component:

AGGREGATE connection to DRUID SINK, DRUID sink configuration

| DRUID SINK 1   | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDruidStore2       |
| NAME OF THE INDEXING SERVICE | druid/overlord |
| SERVICE DISCOVERY PATH | /druid/discovery |
| DATASOURCE NAME | average-speed-cube-01 |
| ZOOKEEPER CONNECT STRING | sandbox-hdp.hortonworks.com:2181 |
| DIMENSIONS | driverId, speed, rainy |
| DIMENSIONS | windy, foggy, routeId, speed_AVG |
| TIMESTAMP FIELD NAME | processingTime |
| WINDOW PERIOD | PT3M |
| INDEX RETRY PERIOD | PT3M |
| SEGMENT GRANULARITY| MINUTE |
| QUERY GRANULARITY | MINUTE |
| **Tab** | **OPTIONAL** |
| BATCH SIZE | 50 |
| LINGER MILLIS | 100 |
| **BOX** | **Aggregator Info** (Click the Add Symbol) |
| AGGREGATOR INFO | Count Aggregator |
| NAME | cnt |

AGGREGATE connection to HDFS SINK, HDFS sink configuration

| HDFS SINK 1   | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDataLake2      |
| HDFS URL | hdfs://sandbox-hdp.hortonworks.com:8020 |
| PATH | /apps/trucking/average-speed |
| FLUSH COUNT | 1000 |
| ROTATION POLICY | File Size Based Rotation |
| ROTATION SIZE MULTIPLIER | 500 |
| ROTATION SIZE UNIT | KB |
| OUTPUT FIELDS | driverId, routeId, speed |
| OUTPUT FIELDS | foggy, rainy, speed_AVG, windy |

8\. Connect the RULE processor to the second DRUID SINK, then connect it to the second HDFS SINK. A FilterEvents-DRUID/HDFS-1 will appear, click OK. Enter the following configurations for each SINK component:

RULE connection to DRUID SINK, DRUID sink configuration

| DRUID SINK 2   | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDruidStore1       |
| NAME OF THE INDEXING SERVICE | druid/overlord |
| SERVICE DISCOVERY PATH | /druid/discovery |
| DATASOURCE NAME | violation-events-cube-01 |
| ZOOKEEPER CONNECT STRING | sandbox-hdp.hortonworks.com:2181 |
| DIMENSIONS | eventTime, routeId, congestionLevel |
| DIMENSIONS | truckId, driverId, driverName |
| DIMENSIONS | routeName, latitude, longitude, speed |
| DIMENSIONS | eventType, foggy, rainy, windy |
| TIMESTAMP FIELD NAME | processingTime |
| WINDOW PERIOD | PT3M |
| INDEX RETRY PERIOD | PT3M |
| SEGMENT GRANULARITY| MINUTE |
| QUERY GRANULARITY | MINUTE |
| **Tab** | **OPTIONAL** |
| BATCH SIZE | 50 |
| LINGER MILLIS | 100 |
| **BOX** | **Aggregator Info** (Click the Add Symbol) |
| AGGREGATOR INFO | Count Aggregator |
| NAME | cnt |

RULE connection to HDFS SINK, HDFS sink configuration

| HDFS SINK 2   | Properties     |
| :------------- | :------------- |
| **Tab** | **REQUIRED** |
| Name       | ToDataLake1      |
| HDFS URL | hdfs://sandbox-hdp.hortonworks.com:8020 |
| PATH | /apps/trucking/violation-events |
| FLUSH COUNT | 1000 |
| ROTATION POLICY | File Size Based Rotation |
| ROTATION SIZE MULTIPLIER | 500 |
| ROTATION SIZE UNIT | KB |
| OUTPUT FIELDS | eventTime, routeId, congestionLevel |
| OUTPUT FIELDS | truckId, speed, eventType, windy |
| OUTPUT FIELDS | rainy, foggy, longitude, latitude |
| OUTPUT FIELDS | routeName, driverId, driverName |

Once all the components have been configured and connected, your topology will look similar as **Figure 2**:

![sam-topology](assets/images/sam-topology.jpg)