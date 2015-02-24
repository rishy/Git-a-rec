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

# Names of all the  available fields in a document of repos collection
repo_fields <- c("_id", "url", "fork", "private", "ssh_url", "owner", "created_at", "size",
                 "homepage", "source", "clone_url", "id", "has_issues", "forks", "has_downloads",
                 "organization", "full_name", "name", "watchers", "mirror_url", "html_url", 
                 "master_branch", "open_issues", "language", "description", "updated_at", "has_wiki", 
                 "git_url", "pushed_at", "parent", "svn_url")

# Useful Fields after trimming the repos collection from database
trimmed_repo_fields <- sort(c("_id", "fork", "private", "owner.id", "owner.login", "created_at", "id","forks", "organization.id", "organization.login", "full_name", "watchers", "language", "updated_at"))

# Names of all the available fields in a document of users collection
all_user_fields <- c("_id", "url", "avatar_url", "created_at", "login", "id", "followers", "gravatar_id",
                     "public_repos", "type", "html_url", "public_gists", "following", "email", "name",
                     "location", "company", "blog", "hireable", "bio")

# Useful Fields after trimming the users collection from database
trimmed_user_fields <- sort(c("_id", "login", "id", "followers", "public_repos", "type", "following",
                              "location", "company", "hireable"))

# Fetches data from mongo database
get_mongo_res <- function(json, ns, trimmed_fields){
  
  # Get the bson object
  bson <- mongo.bson.from.JSON(json)
  
  # Returned mongo cursor for repos collection
  res <- mongo.find.all(mongo, ns = ns, query = bson, limit = 5000L)
  
  # Imputes missing fields in documents
  res_list <- lapply(res, function(x) {
    
    # Get any missing fields in this document and add a null value at thier positions
    missing_fields <- !(trimmed_fields %in% names(unlist(x)))
    fields_to_add <- trimmed_fields[missing_fields]
    x[fields_to_add] <- NA
    x <- x[sort(names(x))]
    
    # Finally return the unlisted(un-nested) list
    unlist(x)    
  })
  
  # Create a data frame from nested list
  coll.df <- as.data.frame(do.call(rbind, res_list))
  
  str(coll.df)  
  return(coll.df)
}

# query condition for repos
json <- '{"language": "R"}'

# Get mongo response from repos collection
repos.df <- get_mongo_res(json, coll.repos, trimmed_repo_fields)

# Query condition for users
json <- '{"location": "California"}'

# Get mongo response from users collection
users.df <- get_mongo_res(json, coll.users, trimmed_user_fields)