#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import requests
import json
import traceback

#================================================
# Set GITHUB_ACCESS_TOKEN in .bashrc file
#   NOTE: write the below line in the end of .bashrc file
#
#   export GITHUB_ACCESS_TOKEN="write-token-value"
#
# ===============================================

def getContent(url = None, payload = None):
    """
        Get Json data from github api
    """
    return requests.get(url, params = payload).json()

def main():
    data = []

    root_username = str(sys.argv[1])
    root_endpoint = "https://api.github.com"
    access_token = os.getenv('GITHUB_ACCESS_TOKEN', None)

    user_url = root_endpoint + "/users/"
    repo_url = root_endpoint + "/repos/"

    payload = { "access_token" : access_token}

    root_user_repos = []
    following_users = []
    following_users_repos = []

    try:
        print "Getting User Repos Data............"
        # get details of all repos of root user
        repos = getContent(user_url+root_username+"/repos", payload)
        for repo in repos:
            languages = getContent(repo_url+repo["full_name"]+"/languages",\
             payload)

            root_user_repos.append(
                {
                    "name" : repo["name"],
                    "full_name": repo["full_name"],
                    "owner_username" : repo["owner"]["login"],
                    "html_url": repo["html_url"],
                    "url" : repo["url"],
                    "languages":languages
                })

        users = getContent(user_url+root_username+"/following", payload)

        print "Getting User following user's................."
        # get all following user's username
        for user in users:
            following_users.append(user["login"])

        print "Getting Following User's Repos ................."
        # get repos details of all following user's
        for username in following_users:
            if len(following_users_repos)<30:
                repos = getContent(user_url+username+"/repos", payload)
                for repo in repos:
                    languages = getContent(repo_url+repo["full_name"]+"/languages",payload)

                    following_users_repos.append(
                        {
                            "name" : repo["name"],
                            "full_name": repo["full_name"],
                            "owner_username" : repo["owner"]["login"],
                            "html_url": repo["html_url"],
                            "url" : repo["url"],
                            "languages":languages
                        })
            else:
                break


        print "Done.................."
    except:
        print traceback.print_exc()
    finally:
        data.append(
            {
                "username" : root_username,
                "following_users" : following_users,
                "personal_repos" : root_user_repos,
                "following_users_repos" : following_users_repos
            })

        with open(root_username+".json", "w+") as f:
            json.dump(data, f)

if __name__ == '__main__':
    main()
