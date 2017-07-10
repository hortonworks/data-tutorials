#!/usr/bin/python

# libraries
import json
import sys
import time
import datetime
import urllib2
import subprocess
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

# Get Current Time Preferred by OS
def get_time():
  current_time = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
  return current_time

# Get Raspberry Pi Public IP via IPIFY Rest Call
def get_public_ip():
  ip = json.load(urllib2.urlopen('https://api.ipify.org/?format=json'))['ip']
  return ip

# Get Raspberry Pi CPU Core Temperature via "vcgencmd" shell command
def get_cpu_temp_c():
  cpu_temp = subprocess.check_output("vcgencmd measure_temp", shell=True)
  # Break up a String and add the data to string array using separator "="
  array = cpu_temp.split("=")
  array2 = array[1].split("'")
  # Grab temperature value from array2 element 0
  cpu_tempc = float(array2[0])
  cpu_tempc = float("{0:.2f}".format(cpu_tempc))
  return cpu_tempc

# Sense HAT Temperature Readings are off due to CPU's temperature heat
# Calibrate temperature reading by using scaling factor: 5.466
# The scaling factor is the amount of degrees the
# Sense HAT is off by from actual temperature
def calibrate_temp_c(cpu_tempc, temp_c):
  temp_c - ((cpu_tempc - temp_c)/5.466)
  return temp_c

# Convert Temperature Celsius to Fahrenheit
def convert_c_to_f(temp_c):
  temp_f = temp_c * 9.0 / 5.0 + 32.0
  return temp_f

# Convert Pressure Millibars to Inches
def convert_mb_to_in(pressure_mb):
  pressure_in = 0.0295301*(pressure_mb)
  return pressure_in

def main():
  # Initialize SenseHat
  sense = SenseHat()
  sense.clear()
  print 'Weather Logs'

  # Get Raspberry Pi Serial Number
  serial = get_serial()

  # Get Current Time Preferred by OS
  timestamp = get_time()

  # Get Weather Readings from Environmental Sensors
  temp_c = sense.get_temperature()
  humidity_prh = sense.get_humidity()
  humidity_prh = round(humidity_prh, 2)
  pressure_mb = sense.get_pressure()
  pressure_mb = round(pressure_mb, 2)

  # Get Raspberry Pi CPU Core Temperature
  cpu_temp_c = get_cpu_temp_c()

  # Calibrate Sense HAT Temperature Sensor Reading
  temp_c = calibrate_temp_c(cpu_temp_c, temp_c)
  temp_c = round(temp_c, 2)

  # Convert Temperature to Fahrenheit and Pressure to Inches
  temp_f = convert_c_to_f(temp_c)
  temp_f = round(temp_f, 2)
  pressure_in = convert_mb_to_in(pressure_mb)
  pressure_in = round(pressure_in, 2)

  # Get Public IP
  public_ip = get_public_ip()

  # 8x8 RGB
  #sense.clear()
  #info = 'Temperature (C): ' + str(temp) + 'Humidity: ' + str(humidity) + 'Pressure: ' + str(pressure)
  #sense.show_message(info, text_colour=[255, 0, 0])

  # Print Weather Data
  print "Serial = " + str(serial)
  print "Time = \"" + str(timestamp) + "\""
  print "Temperature_F = " + str(temp_f)
  print "Humidity_PRH = " + str(humidity_prh)
  print "Pressure_In = " + str(pressure_in)
  print "Public_IP = " + str(public_ip)

if __name__ == "__main__":
  main()
