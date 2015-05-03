#! /usr/bin/env python
# -*- coding: utf-8 -*-

# If a mongoDB instance is not running on your machine then run it at
# localhost
# By default it will start on port 27017
# Also make sure that there is a 'github' database with collections
# 'repos' and 'users'

from pymongo import MongoClient

# get mongodb 'github' Database
def githubDb():
    # Create a MongoClient with running instance of mongo with default settings
    mongo = MongoClient()

    # Get the 'github' database
    db = mongo.github

    return db
