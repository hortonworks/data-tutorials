#!/usr/bin/python
import urllib2
# Spotify has an API that can tell you the genre of a piece of music

# Query a simiple API to retrieve data about International Space Station (ISS)

# Using an API will save us time and effort over doing all the computation ourselves
# Program will ask for data, which is returned in JSON format

## API Requests

# 1. We make a request to a webserver, the server then replies with our data

# 2. Utilize requests library to do this

## Type of Requests

# GET request is used to retrieve data

# Ex: Use GET request to retrieve information from OpenNotify API

# OpenNotify has several API endpoints, which are routes to retrieve different data
# Ex: The /comments endpoint on Reddit API may retrieve info about comments
# Ex: The /users endpoint may retrieve data about users
# To use endpoints, add the endpoint to the base url of the API

## First Endpoint we look at is OpenNotify `iss-now.json`, which gets current latitude
## and longitude of the International Space Station

## NOTE: retrieving this data isn't a great fit for a dataset, because it requires calculation
## on the server and changes quickly

## Listing of all endpoints on OpenNotify: http://open-notify.org/Open-Notify-API/

## Base URL for OpenNotify API is: `https://api.open-notify.org`, we'll add this to beginning of all our endpoints

# Make request to get latest position of international space station from opennotify api
gh_url = 'http://api.open-notify.org'

req = urllib2.Request(gh_url)



response = requests.get("http://api.open-notify.org/iss-now.json")

# Print the status code of the response
print(response.status_code)
