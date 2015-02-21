# Reads the Repos and Users data from mongoDB database

# install the 'rmongodb' package
install.packages('rmongodb')
library(rmongodb)

# Create a mongod instance with default settings
m <- mongo.create()

# Repos Collection in github db
coll.repos <- "github.repos"

# Users Collection in github db
coll.users <- "github.users"

mongo.is.connected(m)

# Names of all the  available fields in a document of repos collection
repo_fields <- c("_id", "url", "fork", "private", "ssh_url", "owner", "created_at", "size",
                 "homepage", "source", "clone_url", "id", "has_issues", "forks", "has_downloads",
                 "organization", "full_name", "name", "watchers", "mirror_url", "html_url", 
                 "master_branch", "open_issues", "language", "description", "updated_at", "has_wiki", 
                 "git_url", "pushed_at", "parent", "svn_url")

# Limit return fields 
return_repo_fields <- '{"name": "1", "created_at": "1", "language": "1", "updated_at": "1"}'

# query condition
json <- '{"language": "R"}'

# Specify fields to be returned
fields <- '{"language": "1", "name": "1"}'

# Get the bson object
bson <- mongo.bson.from.JSON(json)

# Response from mongo query
res <- mongo.find.all(m, coll.repos, fields = return_repo_fields)

# substituting NULL values with NA and removes nested lists
repo_list <- lapply(res, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

#cursor <- mongo.find(m, ns, bson)
#while(mongo.cursor.next(cursor)) {
#  value <- mongo.cursor.value(cursor)
#  list <- mongo.bson.to.list(value)
#  str(list)
#}