#!/bin/bash
echo "Creating Input Source Directory /tmp/nifi/input..."
docker exec -d sandbox-hdf mkdir -p /tmp/nifi/input
docker exec -d sandbox-hdf chmod -R 777 /tmp/nifi
echo "Downloading the Vehicle Location Data to Input Source..."
docker exec -d sandbox-hdf wget -O /tmp/nifi/input/trafficLocs_data_for_simulator.zip 'https://github.com/hortonworks/data-tutorials/raw/master/tutorials/hdf/analyze-traffic-pattern-with-apache-nifi/assets/transit_data_seed.zip'
