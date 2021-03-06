#! /usr/bin/env python
# -*- coding: utf-8 -*-

import json
import connect

# print message
def acknowledgeUser(message=" Bye Bye...Sky is falling down.Save the World"):
    print "\n\n"
    print "========================================================="
    print message
    print "========================================================="
    print "\n"


# import json to mongo db
def importJson():

    # get github mongodb object
    db = connect.githubDb()

    # open file and get the Json data
    with open("user_locations_import_coordinates.json", "r") as users_json:
        data = json.load(users_json)

    with open("user_locations_exported_coordinates.json", "r") as existing_users_json:
        existing_data = json.load(existing_users_json).keys()

    msg = " Total %d New Locations to be Imported" % (len(set(data).difference(existing_data)))
    acknowledgeUser( message = msg );

    cnt = 1
    users_updated = 0

    for location, coordinates in data.iteritems():

        # checks if location is blank or not
        if location and location not in existing_data:
            fields = {"location": True}
            query = {
                        "location": location,
                        "latitude" : {"$exists" : 0},
                        "longitude" : {"$exists" : 0}
                    }

            users = db.users.find(query, fields)

            print "\n %d) Found %d new user(s) having location : %s" % (cnt, users.count(), location)

            if(users.count()>0):
                users_updated += users.count()
                print "===> Updating Location : %s" % (location)

            # set latitude and longitude of all founded users
            db.users.update({"location": location }, { '$set':coordinates}, multi = True)

            cnt += 1

    msg = "    Total %d Users Updated." % (users_updated)
    acknowledgeUser(message = msg)

# export json from mongo db
def exportJson():

    print "\nExporting Data to Json File ........"

    # get github mongodb object
    db = connect.githubDb()

    fields = {"location":True, "_id": False}
    query = {"latitude":{ "$exists":1 }}

    # get all unique/distinct locations
    locations = db.users.find(query, fields).distinct("location")

    locations_dict = dict()

    fields = {"latitude":True, "longitude": True, "_id": False}

    # get the coordinates of all unique locations
    for location in locations:

        coordinate = db.users.find_one({"location":location}, fields)

        # extract latitude and longitude
        latitude = coordinate.get("latitude")
        longitude = coordinate.get("longitude")

        locations_dict[location] = {
                                        "latitude": latitude,
                                        "longitude" : longitude
                                    }

    with open("user_locations_exported_coordinates.json", "w") as fp:
        json.dump(locations_dict, fp)

    msg = "    Total %d Unique Locations Founded." % (len(locations))
    acknowledgeUser(message = msg)

# main function
def main():

    print "\n Note:- Enter 1 to Export and 2 to Import Json"
    user_input = int(raw_input("Enter your Choice: "))

    if(user_input == 1):
        exportJson()
        msg = "    Voila...!!! Data Smuggled OUT Successfully."
        acknowledgeUser(message = msg )

    elif(user_input == 2):
        importJson()
        msg = "    Voila...!!! Data Smuggled IN Successfully."
        acknowledgeUser(message = msg )

if __name__ == '__main__':
    main()
