#! /usr/bin/env python
# -*- coding: utf-8 -*-

import json
import connect
import subprocess
import os
import sys
import logging
import fnmatch

def runCommand(command):
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    output = process.communicate()[0]

def convertUsersToCSV():
    bashCommand = "python json2csv.py users_dump_in_json.json \
                    users_outline.json -o users_dump_in_csv.csv"
    runCommand(bashCommand)
    print "Done...!!!"

def convertReposToCSV():
    repos_dump_files = fnmatch.filter(os.listdir(os.curdir), \
        'repos_dump_in_json_*.json' )
    repos_dump_files.sort()
    index = 1
    for json_file_name in repos_dump_files:
        csv_file_name = "repos_dump_in_csv_%d.csv"%(index)
        bashCommand = "python json2csv.py %s repos_outline.json -o %s"% \
                        (json_file_name, csv_file_name)
        # print bashCommand
        runCommand(bashCommand)
        print " %s file converted to %s successfully. "%(json_file_name, csv_file_name)
        index += 1
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

def filterRepo(repo):
    fields = ["fork", "private","created_at", "id","forks","full_name",
                "watchers", "language","updated_at"]
    owner_nested_fields = ["login", "id"]
    organization_nested_fields = ["login", "id"]

    cleaned_repo = dict()
    for k1, v1 in repo.iteritems():
        if isinstance(v1, dict) and k1=="owner":
            cleaned_repo["owner"] = {}
            for k2, v2 in v1.iteritems():
                if k2 in owner_nested_fields:
                    cleaned_repo["owner"][k2] = v2
        elif isinstance(v1, dict) and k1=="organization":
            cleaned_repo["organization"] = {}
            for k2, v2 in v1.iteritems():
                if k2 in organization_nested_fields:
                    cleaned_repo["organization"][k2] = v2
        elif k1 in fields:
            cleaned_repo[k1] = v1

    return cleaned_repo

def exportRepos():
    # get github mongodb object
    db = connect.githubDb()

    # Get the 'repos' collection
    db.repos = db.repos

    skips = [0, 1000000, 2000000, 3000000, 4000000]
    # skips = [0, 10, 20, 30, 40]
    limit = 1000000
    index = 1
    for skip in skips:
        file_data = []
        try:
            repos = db.repos.find({}, { '_id' : False }, skip = skip, limit= limit)
            for repo in repos:
                # print repo
                file_data.append(filterRepo(repo))
        except Exception as e:
            logging.exception("Something awful happened!")
            # will print this message followed by traceback
        finally:
            repos_count = len(file_data)
            file_name = "repos_dump_in_json_%d.json"%(index)

            print " %d repos recods are added in file %s "%(repos_count,file_name)
            with open(file_name, "w") as f:
                json.dump(file_data, f)
            index += 1

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

