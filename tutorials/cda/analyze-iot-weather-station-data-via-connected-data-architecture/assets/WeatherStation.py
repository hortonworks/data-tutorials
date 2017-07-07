#!/usr/bin/python

import json
import sys
import time
import datetime

# libraries
import sys
import urllib2
import json
from sense_hat import SenseHat

# Get Raspberry Pi Serial Number
def get_serial():
  # Extract serial from cpuinfo file
  cpuserial = "0000000000000000"
  try:
    f = open('/proc/cpuinfo','r')
    for line in f:
      if line[0:6]=='Serial':
        cpuserial = line[10:26]
    f.close()
  except:
    cpuserial = "ERROR000000000"

  return cpuserial

# Attempt to get Raspberry Pi Serial Number
serial = get_serial()

# Attempt to get Current Time preferred by OS
time = time.ctime()

# Initialize SenseHat
sense = SenseHat()
sense.clear()
print 'Weather Logs'

# Attempt to get sensor reading.
temp = sense.get_temperature()
temp = round(temp, 1)
humidity = sense.get_humidity()
humidity = round(humidity, 1)
pressure = sense.get_pressure()
pressure = round(pressure, 1)

# Attempt to get Public IP
public_ip = json.load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']


# 8x8 RGB
#sense.clear()
#info = 'Temperature (C): ' + str(temp) + 'Humidity: ' + str(humidity) + 'Pressure: ' + str(pressure)
#sense.show_message(info, text_colour=[255, 0, 0])

# Print
print "Serial =", serial
print "Time =", time
print "Temperature_C =", temp
print "Humidity =", humidity
print "Pressure =", pressure
print "Public_IP =", public_ip
