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

repos.dt$V1 <- NULL

# write data.table to csv files
write.csv(file = "final_repos.csv", x = repos.dt, row.names = F)

## Ends Here

## Clean Users Dataset
## Starts Here

# replace vague values of company field
users.dt[ tolower(company) %in% companies.vague.values ]$company <- "NA"

# manually replace all top companies name to correct one
users.dt[ grepl("(freelance|^personal$|^private$)", users.dt$company, ignore.case = T) ]$company <- "Freelancers"
users.dt[ grepl("globo.com", users.dt$company, ignore.case = T) ]$company <- "Globo"
users.dt[ grepl("mozilla", users.dt$company, ignore.case = T) ]$company <- "Mozilla"
users.dt[ grepl("paperboy", users.dt$company, ignore.case = T) ]$company <- "paperboy&co. Inc."
users.dt[ grepl("google", users.dt$company, ignore.case = T) ]$company <- "Google"
users.dt[ grepl("(red hat|redhat)", users.dt$company, ignore.case = T) ]$company <- "Red Hat"
users.dt[ grepl("microsoft", users.dt$company, ignore.case = T) ]$company <- "Microsoft"
users.dt[ grepl("thoughtworks", users.dt$company, ignore.case = T) ]$company <- "ThoughtWorks"
users.dt[ grepl("IBM", users.dt$company) ]$company <- "IBM"
users.dt[ grepl("facebook", users.dt$company, ignore.case = T) ]$company <- "Facebook"
users.dt[ grepl("yandex", users.dt$company, ignore.case = T) ]$company <- "Yandex"
users.dt[ grepl("yahoo", users.dt$company, ignore.case = T) ]$company <- "Yahoo!"
users.dt[ grepl("twitter", users.dt$company, ignore.case = T) ]$company <- "Twitter"
users.dt[ grepl("rackspace", users.dt$company, ignore.case = T) ]$company <- "RackSpace"
users.dt[ grepl("IBM", users.dt$company, ignore.case = T) ]$company <- "IBM"
users.dt[ grepl("vmware", users.dt$company, ignore.case = T) ]$company <- "VMware"
users.dt[ grepl("stanford university", users.dt$company, ignore.case = T) ]$company <- "Stanford University"
users.dt[ grepl("(University of Massachusetts|.*\\bMIT\\b.*)", users.dt$company, ignore.case = T) ]$company <- "MIT"
users.dt[ grepl("(UC Berkeley|.*\\bUCB\\b.*)", users.dt$company, ignore.case = T) ]$company <- "UC Berkeley"
users.dt[ grepl("(Carnegie Mellon University|.*\\bCMU\\b.*)", users.dt$company, ignore.case = T) ]$company <- "Carnegie Mellon University"
users.dt[ grepl("tencent", users.dt$company, ignore.case = T) ]$company <- "Tencent"
users.dt[ grepl("University of Washington", users.dt$company, ignore.case = T) ]$company <- "University of Washington"
users.dt[ grepl(".*\\bintel\\b.*", users.dt$company, ignore.case = T) ]$company <- "Intel"
users.dt[ grepl("(^github$|.*github.*Inc.*)", users.dt$company, ignore.case = T) ]$company <- "Github"
users.dt[ grepl("oracle", users.dt$company, ignore.case = T) ]$company <- "Oracle Corporation"
users.dt[ grepl("adobe", users.dt$company, ignore.case = T) ]$company <- "Adobe Systems"
users.dt[ grepl("University of Michigan", users.dt$company, ignore.case = T) ]$company <- "University of Michigan"
users.dt[ grepl("Cornell University", users.dt$company, ignore.case = T) ]$company <- "Cornell University"
users.dt[ grepl("nokia", users.dt$company, ignore.case = T) ]$company <- "Nokia"
users.dt[ grepl("Pivotal Labs", users.dt$company, ignore.case = T) ]$company <- "Pivotal Labs"
users.dt[ grepl("Columbia University", users.dt$company, ignore.case = T) ]$company <- "Columbia University"
users.dt[ grepl("EPAM Systems", users.dt$company, ignore.case = T) ]$company <- "EPAM Systems"
users.dt[ grepl("(^linkedin$|.*linkedin.*Inc.*|.*linkedin.*Corp.*)", users.dt$company, ignore.case = T) ]$company <- "Linkedin"
users.dt[ grepl("baidu", users.dt$company, ignore.case = T) ]$company <- "Baidu"
users.dt[ grepl(".*\\bcisco\\b.*", users.dt$company, ignore.case = T) ]$company <- "Cisco"
users.dt[ grepl(".*\\bpaypal\\b.*", users.dt$company, ignore.case = T) ]$company <- "Paypal"
users.dt[ grepl(".*\\bHarvard University\\b.*", users.dt$company, ignore.case = T) ]$company <- "Harvard University"
users.dt[ grepl("(.*\\bHP\\b.*|.*\\Hewlett\\b.*)", users.dt$company, ignore.case = T) ]$company <- "HP"
users.dt[ grepl(".*\\bEricsson\\b.*", users.dt$company, ignore.case = T) ]$company <- "Ericsson"
users.dt[ grepl("(.*\\bUniversity of California\\b.*|.*\\bUCLA\\b.*)", users.dt$company, ignore.case = T) ]$company <- "University of California"
users.dt[ grepl(".*\\bSalesforce\\b.*", users.dt$company, ignore.case = T) ]$company <- "Salesforce"
users.dt[ grepl(".*\\bAmazon\\b.*", users.dt$company, ignore.case = T) ]$company <- "Amazon"
users.dt[ grepl(".*\\bAlibaba\\b.*", users.dt$company, ignore.case = T) ]$company <- "Alibaba"
users.dt[ grepl("(.*\\bTCS\\b.*|.*\\Tata Consultancy Services\\b.*)", users.dt$company, ignore.case = T) ]$company <- "TCS"
users.dt[ grepl(".*\\bebay\\b.*", users.dt$company, ignore.case = T) ]$company <- "eBay"
users.dt[ grepl(".*\\btaobao\\b.*", users.dt$company, ignore.case = T) ]$company <- "Taobao"
users.dt[ grepl(".*\\bsamsung\\b.*", users.dt$company, ignore.case = T) ]$company <- "Samsung"


# type coercion
users.dt$longitude <- as.numeric(users.dt$longitude)
users.dt$followers <- as.numeric(users.dt$followers)
users.dt$following <- as.numeric(users.dt$following)
users.dt$id <- as.numeric(users.dt$id)

# write data.table to csv file
write.csv(file = "final_users.csv", x = users.dt, row.names = F)

## Ends Here