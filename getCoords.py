# If a mongoDB instance is not running on your machine then run it at
# localhost
# By default it will start on port 27017
# Also make sure that there is a 'github' database with collections
# 'repos' and 'users'

import geopy
import pymongo
from geopy.geocoders import Nominatim
from pymongo import MongoClient

# Create a MongoClient with running instance of mongo with
# default settings
mongo = MongoClient()

# Get the 'github' database
db = mongo.github

# Get the 'users' collection
db.users = db.users

geolocator = Nominatim()

# Iterate over all the documents in 'users' collection
for user in db.users.find({},{'location':1, 'latitude': 1}):	

	# Skip users already having coordinates
	if 'latitude' not in user:

		# Get the id and location of current user
		user_id = user.get('_id')
		user_loc = user.get('location')	

		# If user location is anything other than 'None' or ""
		if user_loc:

			try:
				# Get the user location
			    location = geolocator.geocode(user_loc, timeout = 10)

			    # If location coordinates are successfully retrieved
			    if location:
					print(user_loc)
					coords = {'latitude': location.latitude, 'longitude': location.longitude}		

			except GeocoderTimedOut as e:
				print("Error: geocode failed on input %s with message %s"%(user_loc, e.msg))		

		else:
			coords = {'latitude': float('nan'), 'longitude': float('nan')}

		# Finally add two new fields in current document
		# NaN values are added if location was mentioned in a document
		db.users.update({'_id': user_id}, {'$set': coords})
