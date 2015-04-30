# Load all required R packages
library(data.table)

# read repos and users csv files
repos.dt <- fread('final_repos.csv', header = T,sep = ',', 
                  stringsAsFactors = FALSE)
users.dt <- fread('final_users.csv', header = T,sep = ',', 
                  stringsAsFactors = FALSE)

# meaningless values
vague.values <- c(""," ", "-","none", "none.", "n/a", "na")
companies.vague.values <- c(vague.values, "self","student", "home", "no", "personal")
language.vague.values <- c(vague.values, "Done")

## Clean Repos Dataset
## Starts Here

# replace vague values of language field
repos.dt[ tolower(language) %in% language.vague.values ]$language <- "NA"

# write data.table to csv files
write.csv(file = "final_repos.csv", x = repos.dt)

## Ends Here

## Clean Users Dataset
## Starts Here

# replace vague values of company field
users.dt[ tolower(company) %in% companies.vague.values ]$company <- "NA"

# manually replace all top companies name to correct one
users.dt[ grepl("freelance", users.dt$company, ignore.case = T) ]$company <- "Freelancers"
users.dt[ grepl("globo.com", users.dt$company, ignore.case = T) ]$company <- "Globo"
users.dt[ grepl("mozilla", users.dt$company, ignore.case = T) ]$company <- "Mozilla"
users.dt[ grepl("paperboy", users.dt$company, ignore.case = T) ]$company <- "paperboy&co. Inc."
users.dt[ grepl("google", users.dt$company, ignore.case = T) ]$company <- "Google"
users.dt[ grepl("red hat", users.dt$company, ignore.case = T) ]$company <- "Red Hat"
users.dt[ grepl("microsoft", users.dt$company, ignore.case = T) ]$company <- "Microsoft"
users.dt[ grepl("thoughtworks", users.dt$company, ignore.case = T) ]$company <- "ThoughtWorks"
users.dt[ grepl("IBM", users.dt$company) ]$company <- "IBM"
users.dt[ grepl("facebook", users.dt$company, ignore.case = T) ]$company <- "Facebook"
users.dt[ grepl("yandex", users.dt$company, ignore.case = T) ]$company <- "Yandex"
users.dt[ grepl("yahoo", users.dt$company, ignore.case = T) ]$company <- "Yahoo!"
users.dt[ grepl("twitter", users.dt$company, ignore.case = T) ]$company <- "Twitter"
users.dt[ grepl("rackspace", users.dt$company, ignore.case = T) ]$company <- "RackSpace"

# write data.table to csv file
write.csv(file = "final_users.csv", x = users.dt)

## Ends Here