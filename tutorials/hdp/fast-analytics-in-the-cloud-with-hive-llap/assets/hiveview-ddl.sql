set hive.exec.dynamic.partition.mode=nonstrict;
set hive.optimize.sort.dynamic.partition=true;

CREATE DATABASE IF NOT EXISTS hwxdemo;
USE hwxdemo;

drop table if exists flights purge;
drop table if exists airports purge;
drop table if exists airlines purge;
drop table if exists planes purge;

create table airports(
iata string,
airport string,
city string,
state string,
country string,
lat double,
lon double
)
STORED AS ORC
LOCATION 's3a://hw-sampledata/airline_orc/airline_ontime.db/airports'
;

create table airlines (
code string,
description string
)
STORED AS ORC
LOCATION 's3a://hw-sampledata/airline_orc/airline_ontime.db/airlines'
;


create table planes (
tailnum string,
owner_type string,
manufacturer string,
issue_date string,
model string,
status string,
aircraft_type string,
engine_type string,
year int
)
STORED AS ORC
LOCATION 's3a://hw-sampledata/airline_orc/airline_ontime.db/planes'
;



create table flights (
  DateOfFlight date,
  DepTime  int,
  CRSDepTime int,
  ArrTime int,
  CRSArrTime int,
  UniqueCarrier string,
  FlightNum int,
  TailNum string,
  ActualElapsedTime int,
  CRSElapsedTime int,
  AirTime int,
  ArrDelay int,
  DepDelay int,
  Origin string,
  Dest string,
  Distance int,
  TaxiIn int,
  TaxiOut int,
  Cancelled int,
  CancellationCode varchar(1),
  Diverted varchar(1),
  CarrierDelay int,
  WeatherDelay int,
  NASDelay int,
  SecurityDelay int,
  LateAircraftDelay int
) 
PARTITIONED BY (Year int)
STORED AS ORC
LOCATION 's3a://hw-sampledata/airline_orc/airline_ontime.db/flightsyear'
TBLPROPERTIES("orc.bloom.filter.columns"="*")
;