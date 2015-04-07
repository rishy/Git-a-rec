## Reads the Repos and Users data from mongoDB database

# install and import 'rmongodb' package
# install.packages('rmongodb')
library(rmongodb)
library(plyr)
library(dplyr)
library(ggplot2)
library(data.table)
library(ggmap)
library(maps)
library(maptools)
library(rworldmap)

# Create a mongod instance with default settingsa
mongo <- mongo.create()

# Repos Collection in github db
coll.repos <- "github.repos"

# Users Collection in github db
coll.users <- "github.users"

# Return TRUE if mongo connection is established
mongo.is.connected(mongo)

# Names of all the available fields in a document of repos collection
repo_fields <- c("_id", "url", "fork", "private", "ssh_url", "owner",
                 "created_at", "size","homepage", "source", "clone_url",
                 "id", "has_issues", "forks", "has_downloads","organization",
                 "full_name", "name", "watchers", "mirror_url", "html_url",
                 "master_branch", "open_issues", "language", "description",
                 "updated_at", "has_wiki", "git_url", "pushed_at", "parent",
                 "svn_url")

# Useful Fields after trimming the repos collection from database
trimmed_repo_fields <- sort(c("_id", "fork", "private", "owner.id",
                              "owner.login", "created_at", "id","forks",
                              "organization.id", "organization.login",
                              "full_name", "watchers", "language",
                              "updated_at"))

# Names of all the available fields in a document of users collection
all_user_fields <- c("_id", "url", "avatar_url", "created_at", "login",
                     "id", "followers", "gravatar_id", "public_repos",
                     "type", "html_url", "public_gists", "following",
                     "email", "name", "location", "company", "blog",
                     "hireable", "bio")

# Useful Fields after trimming the users collection from database
trimmed_user_fields <- sort(c("_id", "login", "id", "followers","type",
                              "following","location", "company", "hireable", "latitude",
                              "longitude"))

# A function to fetch data from mongodb database
get_mongo_res <- function(json, ns, trimmed_fields){

  # Get the bson object
  bson <- mongo.bson.from.JSON(json)

  # Returned mongo cursor for repos collection
  res <- mongo.find.all(mongo, ns = ns, query = bson, limit = 60000)

  # Imputes missing fields in documents
  res_list <- lapply(res, function(x) {

    # Get any missing fields in this document and add a null value at
    # their positions
    missing_fields <- !(trimmed_fields %in% names(unlist(x)))
    fields_to_add <- trimmed_fields[missing_fields]
    x[fields_to_add] <- NA
    x <- x[sort(names(x))]

    # Finally return the unlisted(un-nested) list
    unlist(x)
  })

  # Create a data frame from nested list
  coll.df <- as.data.frame(do.call(rbind, res_list), stringsAsFactors = FALSE)

  str(coll.df)
  return(coll.df)
}

# query condition for repos
json <- '{}'

# Get mongo response from repos collection
repos.df <- get_mongo_res(json, coll.repos, trimmed_repo_fields)

# Query condition for users
json <- '{}'

# Get mongo response from users collection
users.df <- get_mongo_res(json, coll.users, trimmed_user_fields)

# Swap missing values of organization.login and organization.id in repos.df
faulty_org_logins <- suppressWarnings(!is.na(as.integer(repos.df$organization.login)))
repos <- repos.df[faulty_org_logins, c('organization.login', 'organization.id')]
temp <- repos$organization.login
repos$organization.login <- repos$organization.id
repos$organization.id <- temp
repos.df[faulty_org_logins, c('organization.login', 'organization.id')] <-
  repos[,  c('organization.login', 'organization.id')]

# Swap missing values of owner.login and owner.id in repos.df
faulty_owner_logins <- suppressWarnings(!is.na(as.integer(repos.df$owner.login)))
repos <- repos.df[faulty_owner_logins, c('owner.login', 'owner.id')]
temp <- repos$owner.login
repos$owner.login <- repos$owner.id
repos$owner.id <- temp
repos.df[faulty_owner_logins, c('owner.login', 'owner.id')] <-
  repos[,  c('owner.login', 'owner.id')]



## Visualization 1 :- Programming languages trends in last few years
## Starts Here

repos.df$year <- as.integer(format(as.Date(repos.df$created_at), "%Y"))


languages <- group_by(repos.df, language)
languages_table <- summarise(languages, val=n())
languages_table <- na.omit(arrange(languages_table, desc(val)))
top_languages <- as.character(languages_table[1:10,]$language)

yearly <- group_by(repos.df, language, year)
dataset_table <- na.omit(summarise(yearly, val = n()))
dataset_1 <- dataset_table[dataset_table$language %in% top_languages, ]

# line chart plot
ggplot(data = dataset_1, aes(x=year, y=val)) + geom_line(aes(colour=language))

## Ends here


## Visualization 2 :- Statistics of users from various Companies on Github
## Starts Here

companies <- group_by(users.df, company)
companies_table <- summarise(companies, users = n())
companies_table <- data.frame(arrange(companies_table, desc(users)))
companies_table <- filter(companies_table, !(company %in% c("-", "None",
                                                            "", "none")))

top_companies <- as.character(companies_table[2:25,]$company)

dataset_2 <- users.df[users.df$company %in% top_companies, ]

# barplot
qplot(dataset_2$company, xlab="Companies", ylab="No. of Users",
      main="Users Count Per Company Graph")

## Ends Here

## Visualization 3 :-  Comparison of Companies and Programming Languages
## Starts Here

# coerce repos.df data.frame to data.table
DT.repos <- data.table(subset(repos.df, select=c("owner.id","language",
                                                 "owner.login")))

# rename data.table variables
setnames(DT.repos, c("id", "language", "login"))

# remove futile companies enteries from users.df
users.new = na.omit(users.df[ !( users.df$company %in% c("","-","none." ) ),])

# coerce users.df data.frame to data.table
DT.users <- data.table(subset(users.new,select=c("id", "login", "company")))

# create dataset by merging
dataset.3 <- merge(DT.repos, DT.users, by=c("id", "login"))

# remove futile variable from dataset
dataset.3[, login:=NULL]
dataset.3[, id:=NULL]

# find top companies
companies.count <- arrange(summarise(group_by(dataset.3, company), count=n()),
                           desc(count))
top.10.companies <- as.character(companies.count[1:12,]$company)

# filter top 12 companies data from dataset
dataset.3 = dataset.3[dataset.3$company %in% top.10.companies, ]

# pie chart without labels
ggplot(data = dataset.3, aes(x = factor(1),fill=factor(language))) +
  facet_wrap(~company) +
  geom_bar(width = 1,position = "fill") +
  coord_polar(theta="y", start=0) +
  xlab("Companies") +
  ylab("No. of Repos")

## Ends Here

## Visualization 4 :- Spatial visualization of github users
## Starts Here

DT.users <- data.table(subset(users.df, select=c("id", "login", "location",
                                                 "latitude", "longitude")))
DT.users <- na.omit(DT.users)
DT.users <- subset(DT.users, latitude!="NaN")
DT.users$latitude <- as.numeric(DT.users$latitude)
DT.users$longitude <- as.numeric(DT.users$longitude)

users.spatial.pop <- summarise(group_by(DT.users, latitude, longitude),
                                 pop = n())
users.spatial.pop <- arrange(users.spatial.pop, desc(pop))

users.spatial.pop$latitude <- as.numeric(users.spatial.pop$latitude)
users.spatial.pop$longitude <- as.numeric(users.spatial.pop$longitude)


# Using ggplot and Base World Map
mp <- NULL

# create a layer of borders
mapWorld <- borders("world", colour="gray50", fill="gray50")

#Now Layer the cities on top
mp <- ggplot() + mapWorld
mp1 <- mp + geom_point(data = DT.users, aes(x=longitude, y=latitude) , colour="white",
                       fill="red", shape=21, size = 2, alpha = .6)
mp1 <- mp1 + theme_bw()
mp1 <- mp1 + labs(title = "Spatial Visualization of Github Users",
                  x = "Longitude", y = "Latitude")
mp1

mp2 <- mp + geom_point(data = users.spatial.pop,  aes(x=longitude, y=latitude, size = pop),
                        colour="blue", fill="darkblue", shape=21)
mp2 <- mp2 + scale_size_area(breaks=c(1, 50, 100, 200, 300, 500, 1000), "User Population")
mp2 <- mp2 + theme_bw()
mp2 <- mp2 + labs(title = "Spatial Visualization of Github Users",
                  x = "Longitude", y = "Latitude")
mp2

## Ends Here
