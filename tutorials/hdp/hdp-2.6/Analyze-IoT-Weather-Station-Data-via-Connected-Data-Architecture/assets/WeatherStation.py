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

	# 8x8 RGB
	#sense.clear()
	#info = 'Temperature (C): ' + str(temp) + 'Humidity: ' + str(humidity) + 'Pressure: ' + str(pressure)
	#sense.show_message(info, text_colour=[255, 0, 0])

	# Print
	print "Temperature_C = ", temp
	print "Humidity = ", humidity
	print "Pressure = ", pressure, "\n"
