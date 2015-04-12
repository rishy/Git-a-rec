# Load all required R packages
library(dplyr)
library(ggplot2)
library(data.table)
library(leaflet)
library(fpc)

# read repos and users csv files
repos.df = fread('repos_dump_in_csv.csv', header = T,sep = ',', stringsAsFactors = FALSE)
users.df = fread('users_dump_in_csv.csv', header = T,sep = ',', stringsAsFactors = FALSE)

## Visualization 1 :- Programming languages trends in last few years
## Starts Here

repos.df$year <- as.integer(format(as.Date(repos.df$created_at), "%Y"))

languages <- group_by(repos.df, language)
languages_table <- summarise(languages, val=n())
languages_table <- na.omit(arrange(languages_table, desc(val)))
languages_table <- filter(languages_table, !(language %in% c("-", "None",
                                                            "", "none")))
top_languages <- as.character(languages_table[1:10,]$language)

yearly <- group_by(repos.df, language, year)
dataset_table <- na.omit(summarise(yearly, val = n()))
dataset_1 <- dataset_table[dataset_table$language %in% top_languages, ]

# line chart plot
ggplot(data = dataset_1, aes(x=year, y=val)) + geom_line(aes(colour=language))

## Ends here

## Delete variables of visualization 1
rm(dataset_1)
rm(dataset_table)
rm(languages)
rm(languages_table)
rm(yearly)
rm(top_languages)

## Visualization 2 :- Statistics of users from various Companies on Github
## Starts Here

companies <- group_by(users.df, company)
companies_table <- summarise(companies, users = n())
companies_table <- data.frame(arrange(companies_table, desc(users)))
companies_table <- filter(companies_table, !(company %in% c("-", "None",
                          "", "none","self","student","Student","n/a", "N/A")))

top_companies <- as.character(companies_table[1:25,]$company)

dataset_2 <- users.df[users.df$company %in% top_companies, ]

# barplot
qplot(dataset_2$company, xlab="Companies", ylab="No. of Users",
      main="Users Count Per Company Graph")

## Ends Here

## Delete variables of visualization 2
rm(companies)
rm(companies_table)
rm(dataset_2)
rm(top_companies)

## Visualization 3 :-  Comparison of Companies and Programming Languages
## Starts Here

# subsetting repos.df
DT.repos <- subset(repos.df, select=c("owner.id","language",
                                                 "owner.login"))

# rename data.table variables
setnames(DT.repos, c("id", "language", "login"))

# remove futile companies enteries from users.df
users.new = na.omit(users.df[ !( users.df$company %in% c("","-","none." ) ),])

# subsetting users.df
DT.users <- subset(users.new,select=c("id", "login", "company"))

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

## Delete variables of visualization 3
rm(DT.repos)
rm(DT.users)
rm(companies.count)
rm(dataset.3)
rm(users.new)
rm(top.10.companies)

## Visualization 4 :- Spatial visualization of github users
## Starts Here

DT.users <- select(users.df, id, login, location, latitude, longitude)
DT.users <- DT.users %>% 
  na.omit() %>%
  mutate( latitude = as.numeric(latitude),
          longitude = as.numeric(longitude)
  )

users.spatial.pop <- DT.users %>%
  group_by(longitude, latitude, location) %>%
  summarise(population = n()) %>%
  ungroup() %>%
  arrange(desc(population)) %>%
  na.omit()

# DBSCAN Clustering
DBSCAN <- dbscan(select(users.spatial.pop, latitude,longitude), 
                 eps=0.7, MinPts = 3)

users.spatial.pop <- mutate(users.spatial.pop, cluster = DBSCAN$cluster)

filter(users.spatial.pop, cluster==1)

non.outliners <- filter(users.spatial.pop, cluster != 0) %>% 
  group_by(cluster) %>%
  summarise( population = sum(population),
             latitude = mean(latitude),
             longitude = mean(longitude)
  ) %>%
  select(longitude, latitude, population, cluster) %>%
  arrange(desc(population))

outliners <- filter(users.spatial.pop, cluster == 0) %>%
  select(longitude, latitude, population, cluster) %>%
  arrange(desc(population))

users.spatial.pop <- rbind(non.outliners, outliners ) %>%
  select(longitude, latitude, population)

# adding extra labels in dataset
maxSize = max(users.spatial.pop$population)
radius = (users.spatial.pop$population/maxSize)*100000

col.df = data.frame( breaks = c(10, 50, 100,300,500,1000,10000, maxSize), 
                     color = c("darkblue", "lightseagreen", "green", "lightgray",
                               "lightblue", "purple", "orange", "red"),
                     radius = c(1, 50, 200, 1000, 10000, 25000, 60000, 150000)
)

users.spatial.pop$color = rep("red", length(users.spatial.pop$population))
users.spatial.pop$radius = rep(0, length(users.spatial.pop$population))

for(bk in rev(col.df$breaks)){
  
  users.spatial.pop[users.spatial.pop$population <= bk,]$color <- 
    col.df[match(c(bk), col.df$breaks), c('color')]
  
  users.spatial.pop[users.spatial.pop$population <= bk,]$radius <- 
    col.df[match(c(bk), col.df$breaks), c('radius')]
}

# plot world map using leaflet
m = leaflet() %>% addTiles()
m %>% addCircles(users.spatial.pop$longitude, users.spatial.pop$latitude, 
                 color = users.spatial.pop$color, 
                 radius = users.spatial.pop$radius 
)

## Ends Here
