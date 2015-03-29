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

# Create a Nominatim Instance
geolocator = Nominatim()

# Get start and end index for mongo cursor
# Start index will be the deciding factor for the documents to be skipped
# Enter a '1' for 'start_idx' if you want to start from the first index
start_idx = int(raw_input('Start Index <-- '))
end_idx = int(raw_input('End Index <-- '))

# No. of documents to be fetched
lim = end_idx - start_idx

# A counter for no. of locations whose coordinates are fetched
counter = 0

#db.users.update({}, {'$unset' : {'latitude': "", "longitude": ""}}, multi = True)

# Iterate over all the documents in 'users' collection
for user in db.users.find({},{'location': True, 'latitude': True},
 skip = start_idx - 1, limit = lim + 1):	

	# Skip users already having coordinates
	if 'latitude' not in user:

		# Get the id and location of current user
		user_id = user.get('_id')
		user_loc = user.get('location')	
		coords = {}
		
		# If some other document has already got the coordinates of current location
		# then use these existing coords instead
		if user_loc:
			coords = db.users.find_one({'location': user_loc},{'latitude': True, 
				'longitude': True, '_id': False})
			if coords:
				print "Found a cached value! with location %s " % user_loc

		# If user location is anything other than 'None' or "" 
		# and coords is not defined yet
		if bool(user_loc and not coords):

			print "-------------New Entry------------"
			try:
				# Get the user location
			    location = geolocator.geocode(user_loc, timeout = 10)
			    
			    # If location coordinates are successfully retrieved
			    if location:
					print(user_loc)
					coords = {'latitude': location.latitude, 'longitude': location.longitude}
				
			except Exception as e:
				print("Error: geocode failed on input %s with message %s"%(user_loc, e.msg))	

			# Add 1 to the counter
			counter += 1
			print "Counter: %d" % counter	
			print "----------------End-----------------"

		# If there was no previous data for current _id or location value was missing
		if not coords:
			coords = {'latitude': float('nan'), 'longitude': float('nan')}

		# Finally add two new fields in current document
		# NaN values are added if location was mentioned in a document
		db.users.update({'_id': user_id}, {'$set': coords})