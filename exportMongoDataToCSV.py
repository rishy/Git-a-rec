#! /usr/bin/env python
# -*- coding: utf-8 -*-

import json
import connect
import subprocess
import os
import sys
import logging


def runCommand(command):
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    output = process.communicate()[0]

def convertUsersToCSV():
    bashCommand = "python json2csv.py users_dump_in_json.json \
                    users_outline.json -o users_dump_in_csv.csv"
    runCommand(bashCommand)
    print "Done...!!!"

def convertReposToCSV():
    bashCommand = "python json2csv.py repos_dump_in_json.json \
                    repos_outline.json -o repos_dump_in_csv.csv"
    runCommand(bashCommand)
    print "Done...!!!"

def exportUsers():
    # get github mongodb object
    db = connect.githubDb()

    # Get the 'users' collection
    db.users = db.users

    try:
        users = db.users.find({}, { '_id' : False })

        users_data = []

        for user in users:
            # print user
            users_data.append(user)
    except Exception as e:
        logging.exception("Something awful happened!")
        # will print this message followed by traceback
    finally:
        with open("users_dump_in_json.json", "w") as f:
            json.dump(users_data, f)

        print "Done...!!!"

def exportRepos():
    # get github mongodb object
    db = connect.githubDb()

    # Get the 'repos' collection
    db.repos = db.repos

    try:
        repos = db.repos.find({}, { '_id' : False },  no_cursor_timeout=True)

        repos_data = []

        for repo in repos:
            # print repo
            repos_data.append(repo)
    except Exception as e:
        logging.exception("Something awful happened!")
        # will print this message followed by traceback
    finally:
        with open("repos_dump_in_json.json", "w") as f:
            json.dump(repos_data, f)

        print "Done...!!!"

if __name__ == '__main__':

    # convert and export
    if(sys.argv[1] == "export"):
        if(sys.argv[2] == "users"):
            exportUsers()
        elif(sys.argv[2] == "repos"):
            exportRepos()
        else:
            print "Error : Too few arguments"
    elif(sys.argv[1] == "convert"):
        if(sys.argv[2] == "users"):
            convertUsersToCSV()
        elif(sys.argv[2] == "repos"):
            convertReposToCSV()
        else:
            print "Error : Too few arguments"
    else:
        print "Error : No arguments matched"

