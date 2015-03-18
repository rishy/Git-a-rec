#! /usr/bin/env python
# -*- coding: utf-8 -*-

# If a mongoDB instance is not running on your machine then run it at
# localhost
# By default it will start on port 27017
# Also make sure that there is a 'github' database with collections
# 'repos' and 'users'

import pymongo
from pymongo import MongoClient

# main funtion
def main():
    # Create a MongoClient with running instance of mongo with
    # default settings
    mongo = MongoClient()

    # Get the 'github' database
    db = mongo.github

    # Get the 'repo' collection
    db.repos = db.repos

    # Get the 'user' collection
    db.users = db.users

    # Fields in untrimmed repo document
    repo_fields = ["_id", "url", "fork", "private", "ssh_url", "owner",
                "created_at", "size","homepage", "source", "clone_url",
                "id", "has_issues", "forks", "has_downloads","organization",
                "full_name", "name", "watchers", "mirror_url", "html_url",
                "master_branch", "open_issues", "language", "description",
                "updated_at", "has_wiki","git_url", "pushed_at", "parent",
                "svn_url"]

    # Fields to be removed from each untrimmed repo document
    unset_repo_fields = {
                            "url" : "",
                            "ssh_url" : "",
                            "size" : "",
                            "homepage" : "",
                            "source" : "",
                            "clone_url" : "",
                            "has_issues" : "",
                            "has_downloads" : "",
                            "name" : "",
                            "mirror_url" : "",
                            "html_url" : "",
                            "master_branch" : "",
                            "open_issues" : "",
                            "description" : "",
                            "has_wiki" : "",
                            "git_url": "",
                            "svn_url" : "",
                            "pushed_at" : "",
                            "owner.gravatar_id": "",
                            "owner.avatar_url": "",
                            "owner.url": "",
                            "organization.gravatar_id": "",
                            "organization.avatar_url": "",
                            "organization.url": "",
                            "parent": "",
                            "source": "",
                            "archive_url": "",
                            "assignees_url": "",
                            "blobs_url": "",
                            "branches_url": "",
                            "collaborators_url": "",
                            "comments_url": "",
                            "commits_url": "",
                            "compare_url": "",
                            "contents_url": "",
                            "contributors_url": "",
                            "downloads_url": "",
                            "events_url": "",
                            "forks_count": "",
                            "forks_url": "",
                            "git_commits_url": "",
                            "git_refs_url": "",
                            "git_tags_url":"",
                            "hooks_url" : "",
                            "issue_comment_url": "",
                            "issue_events_url": "",
                            "issues_url": "",
                            "keys_url": "",
                            "labels_url": "",
                            "languages_url": "",
                            "merges_url": "",
                            "milestones_url": "",
                            "network_count": "",
                            "notifications_url": "",
                            "open_issues_count": "",
                            "organization.type": "",
                            "organization.starred_url" : "",
                            "organization.repos_url": "",
                            "organization.events_url": "",
                            "organization.organizations_url": "",
                            "organization.followers_url": "",
                            "organization.received_events_url": "",
                            "organization.gists_url": "",
                            "organization.following_url": "",
                            "organization.subscriptions_url": "",
                            "owner.starred_url": "",
                            "owner.repos_url" : "",
                            "owner.events_url": "",
                            "owner.organizations_url": "",
                            "owner.followers_url": "",
                            "owner.received_events_url": "",
                            "owner.gists_url": "",
                            "owner.following_url": "",
                            "owner.subscriptions_url": "",
                            "owner.type":"",
                            "permissions" : "",
                            "pulls_url": "",
                            "stargazers_url": "",
                            "statuses_url": "",
                            "subscribers_url": "",
                            "subscription_url": "",
                            "tags_url": "",
                            "teams_url": "",
                            "trees_url": "",
                            "watchers_count": "",
                            "default_branch":""
                        }

    print "Cleaning Repos ....."
    # Remove 'unset_repo_fields' from all the documents in 'repos' collection
    db.repos.update({}, {'$unset': unset_repo_fields}, multi = True)

    print db.repos.find_one()

    # Fields in untrimmed user document
    user_fields = ["_id", "url", "avatar_url", "created_at", "login", "id",
                "followers", "gravatar_id","public_repos", "type", "html_url",
                "public_gists", "following", "email", "name","location",
                "company", "blog", "hireable", "bio"]

    # Fields to be removed from each untrimmed user document
    unset_user_fields = {
                            "url" : "",
                            "avatar_url" : "",
                            "created_at" : "",
                            "gravatar_id" : "",
                            "html_url" : "",
                            "public_gists" : "",
                            "email" : "",
                            "name" : "",
                            "blog" : "",
                            "bio" : "",
                            "starred_url": "",
                            "repos_url" : "",
                            "events_url": "",
                            "organizations_url": "",
                            "followers_url": "",
                            "received_events_url": "",
                            "gists_url": "",
                            "following_url": "",
                            "subscriptions_url": "",
                            "public_members_url":"",
                            "public_repos":"",
                            "members_url":"",
                            "updated_at":"",
                            "site_admin":""
                        }

    print "Cleaning Users ....."
    # Remove 'unset_user_fields' from all the documents in 'users' collection
    db.users.update({}, {'$unset': unset_user_fields}, multi = True)

    print db.users.find_one()

    # Remove duplicate documents from users and repos collections
    db.repos.ensure_index([('full_name', pymongo.ASCENDING), ('unique', True), ('dropDups', True)])

    db.users.ensure_index([('login', pymongo.ASCENDING), ('unique', True), ('dropDups', True)])

if __name__ == '__main__':
    main()




'''
###################################################################
RUN 'use github' and 'db.repairDatabase()' command from mongo shell
to free the unused space in mongoDB.
###################################################################
'''

