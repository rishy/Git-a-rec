import pymongo
from pymongo import MongoClient

# If a mongoDB instance is not running on your machine then run it at localhost
# By default it will start on port 27017
# Also make sure that there is a 'github' database with collections 'repos' and 'users'

# Create a MongoClient with running instance of mongo with default settings
mongo = MongoClient()

# Get the 'github' database
db = mongo.github

# Get the 'repo' collection
db.repos = db.repos

# Get the 'user' collection
db.users = db.users

# Fields in untrimmed repo document
repo_fields = ["_id", "url", "fork", "private", "ssh_url", "owner", "created_at", "size",
             "homepage", "source", "clone_url", "id", "has_issues", "forks", "has_downloads",
             "organization", "full_name", "name", "watchers", "mirror_url", "html_url", 
             "master_branch", "open_issues", "language", "description", "updated_at", "has_wiki", 
             "git_url", "pushed_at", "parent", "svn_url"]

# Fields to be removed from each untrimmed repo document
unset_repo_fields = {"url" : "", "ssh_url" : "", "size" : "", "homepage" : "", "source" : "",
					"clone_url" : "", "has_issues" : "", "has_downloads" : "", "name" : "",
					"mirror_url" : "", "html_url" : "", "master_branch" : "", "open_issues" : "",
					"description" : "", "has_wiki" : "", "git_url": "", "svn_url" : "",
					"pushed_at" : "", 'owner.gravatar_id': "", 'owner.avatar_url': "",
					'owner.url': "", "organization.gravatar_id": "", "organization.avatar_url": "",
					"organization.url": "", "parent": "", "source": ""}

# Remove 'unset_repo_fields' from all the documents in 'repos' collection
db.repos.update({}, {'$unset': unset_repo_fields}, multi = True)

print db.repos.find_one()

# Fields in untrimmed user document
user_fields = ["_id", "url", "avatar_url", "created_at", "login", "id", "followers", "gravatar_id",
			  "public_repos", "type", "html_url", "public_gists", "following", "email", "name",
			  "location", "company", "blog", "hireable", "bio"]

# Fields to be removed from each untrimmed user document
unset_user_fields = {"url" : "", "avatar_url" : "", "created_at" : "", "gravatar_id" : "",
					"html_url" : "", "public_gists" : "", "email" : "", "name" : "",
					"blog" : "", "bio" : ""}

# Remove 'unset_user_fields' from all the documents in 'users' collection
db.users.update({}, {'$unset': unset_user_fields}, multi = True)

print db.users.find_one()

'''
###################################################################
RUN 'use github' and 'db.repairDatabase()' command from mongo shell
to free the unused space in mongoDB.
###################################################################
'''

