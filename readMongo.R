### Reads the Repos and Users data from mongoDB database

# install and import 'rmongodb' package
#install.packages('rmongodb')
library(rmongodb)
library(plyr)

# Create a mongod instance with default settings
mongo <- mongo.create()

# Repos Collection in github db
coll.repos <- "github.repos"

# Users Collection in github db
coll.users <- "github.users"

mongo.is.connected(mongo)

# Names of all the available fields in a document of repos collection
all_repo_fields <- c("_id", "url", "fork", "private", "ssh_url", "owner", "created_at", "size",
                     "homepage", "source", "clone_url", "id", "has_issues", "forks", "has_downloads",
                     "organization", "full_name", "name", "watchers", "mirror_url", "html_url", 
                     "master_branch", "open_issues", "language", "description", "updated_at", "has_wiki", 
                     "git_url", "pushed_at", "parent", "svn_url")

# Useful Fields after trimming the repos collection from database
trimmed_repo_fields <- sort(c("fork", "private", "owner", "created_at", "id", "forks",
                         "organization", "full_name", "watchers", "language", "updated_at", "parent"))

# Names of all the available fields in a document of users collection
all_user_fields <- c("_id", "url", "avatar_url", "created_at", "login", "id", "followers", "gravatar_id",
                     "public_repos", "type", "html_url", "public_gists", "following", "email", "name",
                     "location", "company", "blog", "hireable", "bio")

# Useful Fields after trimming the users collection from database
trimmed_user_fields <- sort(c("login", "id", "followers", "public_repos", "type", "following",
                         "location", "company", "hireable"))

# Fetches data from mongo database
get_mongo_res <- function(json, ns){
  
  # Get the bson object
  bson <- mongo.bson.from.JSON(json)
  
  # Create an empty data frame to hold the contents of the collection
  coll.df <- data.frame()
  
  # Returned mongo cursor for repos collection
  cursor <- mongo.find(mongo, ns, bson)
  while(mongo.cursor.next(cursor)) {
    value <- mongo.cursor.value(cursor)
    list <- mongo.bson.to.list(value)  
    
    tmp.df <- as.data.frame(t(unlist(list)))
    coll.df <- rbind.fill(coll.df, tmp.df)
  }
  
  str(coll.df)  
  return(coll.df)
}

# query condition for repos
json <- '{"language": "R"}'

# Get mongo response from repos collection
repos.df <- get_mongo_res(json, coll.repos)

# Query condition for users
json <- '{"location": "California"}'

# Get mongo response from users collection
users.df <- get_mongo_res(json, coll.users)