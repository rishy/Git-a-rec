# Load all required R packages
library(dplyr)
library(ggplot2)
library(scales)
library(grid)
library(data.table)
library(leaflet)
library(fpc)

# read repos and users csv files
repos.dt <- fread('final_repos.csv', header = T,sep = ',', 
                 stringsAsFactors = FALSE)
users.dt <- fread('final_users.csv', header = T,sep = ',', 
                 stringsAsFactors = FALSE)

# meaningless values
vague.values <- c(""," ", "-","none", "none.", "n/a", "na")
companies.vague.values <- c(vague.values, "self","student", "home")
language.vague.values <- c(vague.values, "Done")

## Visualization 1 :- Programming languages trends in last few years
## Starts Here

# find the top 10 languages
languages <- repos.dt[, .N, by=language] %>% setorder(-N)

languages.top <- languages$language[1:10]

# find the repos data yearwise
repos.yearwise <- repos.dt[language %in% languages.top, .N,
  by = list(language, year)] %>%
  na.omit()

# line chart plot
v1 = ggplot(data = repos.yearwise, aes(x=year, y=N)) + 
  geom_line(aes(colour=language), size=1.2) +
  labs(title = "Yearwise Programming Languages Trends",
       x = "Year",
       y = "Number of Repos",
       colour = "Languages"
  ) + xlim(2011, 2014) + 
  scale_color_discrete(breaks = languages.top, labels = languages.top) +
  theme(plot.title = element_text(size = rel(1.5), face = "bold", vjust = 1),
        axis.text = element_text(size = rel(1), colour = "black"),
        axis.ticks = element_line(size = rel(3)),
        axis.ticks.length = unit(.3, "cm"),
        axis.title.y = element_text(size = rel(1.5), face = "bold", 
                                    vjust = 1 ,angle = 90),
        axis.title.x = element_text(size = rel(1.5), face = "bold", 
                                    vjust = -0.5, angle = 0),
        legend.position = c(0.1, 0.75),
        legend.justification = c(0.6, 0.6),
        legend.title = element_text(colour = "black", size = rel(1.5)),
        legend.text = element_text(colour="black", size = rel(1.2))
  )

# print graph
print(v1)

## Ends here

## Delete variables of visualization 1
rm(languages)
rm(languages.top)
rm(repos.yearwise)

## Visualization 2 :- Statistics of users from various Companies on Github
## Starts Here
companies <- na.omit(users.dt[,.N, by=company] %>% setorder(-N))
companies[company %in% c("Japan", "japan", "NA"),] <- NA
companies <- na.omit(companies)
companies.top <- companies[1:30,company]

users.companies <- users.dt[company %in% companies.top]

# barplot
v2 = ggplot(data = users.companies, aes(x=reorder(company,company,
                                                  function(x){-length(x)} ) )
) +
  geom_histogram(aes(fill=company)) +
  labs(title = "Histogram of Users in Top Companies",
       x = "Companies",
       y = "Number of Users"
  ) + 
  scale_fill_discrete(guide = FALSE) +
  theme(plot.title = element_text(size = rel(1.5), face = "bold", vjust = 1),
        axis.text = element_text(size = rel(1), colour = "black"),
        axis.text.x = element_text(face = "bold", angle = 60, hjust=1),
        axis.ticks = element_line(size = rel(3)),
        axis.ticks.length = unit(.3, "cm"),
        axis.title.y = element_text(size = rel(1.5), face = "bold", 
                                    vjust = 1 ,angle = 90),
        axis.title.x = element_text(size = rel(1.5), face = "bold", 
                                    vjust = 0, angle = 0)
  )

# print the plot
print(v2)

## Ends Here

## Delete variables of visualization 2
rm(companies)
rm(companies.top)
rm(users.companies)

## Visualization 3 :-  Plot of programming languages used by people from 
## top companies
## Starts Here

# subsetting repos.df
DT.repos <- na.omit(repos.dt[!(language %in% language.vague.values),
                     .(owner.id, owner.login, language)])

# Rename id and login columns
setnames(DT.repos, "owner.id", "id")
setnames(DT.repos, "owner.login", "login")

# change the class of id column to character
DT.repos$id <- as.character(DT.repos$id)

# subsetting users.df
DT.users <- na.omit(users.dt[!(company %in% companies.vague.values), 
                     .(id, login, company)])

# create dataset by merging
repos.users.merged <- merge(DT.repos, DT.users, by=c("id", "login"))

# find top companies
companies <- setorder(repos.users.merged[,.N, by=company], -N)

companies.top <- companies$company[1:12]

# find top languages
languages <- setorder(repos.users.merged[,.N, by=language], -N)

languages.top <- languages$language[1:9]

# fill others in non-top language
repos.users.merged[!(language %in% languages.top)]$language <- "Others"

# filter top 12 companies data from dataset
companies.languages = repos.users.merged[company %in% companies.top, ]

# add labels columns
companies.languages <- companies.languages[, .(reposCnt = .N), by = .(company,  language)]
companies.languages[, percentage := reposCnt/sum(reposCnt)*100, by = company ]
companies.languages[, pos := cumsum(percentage) - percentage*0.5, by = company]

blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    axis.text.y=element_blank(),
    plot.title=element_text(size=rel(2), face="bold")
  )

# pie chart without labels
ggplot(data = companies.languages)+
  geom_bar(aes(x = factor(1), y = percentage, fill=factor(language )),
           stat="identity", color='black') +
  guides(fill=guide_legend(override.aes=list(colour=NA))) + 
  geom_text(aes(x= factor(1), y=pos, label = sprintf("%1.f%%", percentage)), size=4) +
  coord_polar(theta="y", start=0) +
  facet_wrap(~company) +
  scale_fill_brewer(palette="Set1",breaks = c(languages.top, "Others"), 
                    labels = c(languages.top, "Others")) +
  blank_theme +
  theme(axis.text.x=element_blank()) + 
  labs( title = "Comaprison of Companies with Programming Languages",
        fill= "Languages")
## Ends Here

## Delete variables of visualization 3
rm(DT.users)
rm(companies)
rm(languages)
rm(companies.languages)

## Visualization 4 :- Spatial visualization of top languages users population
## Starts Here

# subsetting repos.df
DT.users <- na.omit(users.dt[!(company %in% companies.vague.values),
                     .(id, login, company, latitude, longitude, location)]) 

# Change the type of latitude and longitude columns
DT.users$latitude <- as.numeric(DT.users$latitude)
DT.users$longitude <- as.numeric(DT.users$longitude)

DT.users <- na.omit(DT.users)

# create dataset by merging
repos.users.merged <- merge(DT.repos, DT.users, by=c("id", "login"))

# Merge users and repos columns with languages and coordinates
users.spatial.pop <- repos.users.merged[, .(latitude, longitude, language)]

# DBSCAN Clustering
DBSCAN <- dbscan(users.spatial.pop[, .(latitude,longitude)], 
                 eps=0.7, MinPts = 3)

# Add a "cluster" column to users.spatial.pop
users.spatial.pop <- users.spatial.pop[, cluster:=DBSCAN$cluster]

# Group By users.spatial.pop by language and cluster
users.spatial.pop <- setorder(users.spatial.pop[, .(population= .N,
  latitude= mean(latitude), longitude= mean(longitude)),
  by = .(language, cluster)], -population)

rules.df = data.table(language = languages.top, 
                       colour = c("darkred", "red", "darkblue", 
                                  "lightseagreen", "green", 
                                  "lightblue", "purple", "orange","darkgreen"))

# add colour labels and radius labels


# plot world map using leaflet
m = leaflet() %>% addTiles() %>% 
  addCircles(users.spatial.pop$longitude, users.spatial.pop$latitude, 
             color = "blue", 
             radius = 100000 
  )

# print plot
print(m)

## Ends Here


## Delete variables of visualization 3
rm(rules.df)
rm(users.spatial.pop)
rm(DBSCAN)
rm(repos.users.merged)

## Visualization 5 :- Spatial visualization of github users
## Starts Here

users.spatial.pop <- DT.users[, .(population = .N), 
  by = .(longitude, latitude, location)] %>%
  setorder(-population) %>%
  na.omit()

# DBSCAN Clustering
DBSCAN <- dbscan(users.spatial.pop[, .(latitude, longitude)], 
                 eps=0.7, MinPts = 3)

# Add a new cluster column
users.spatial.pop <- users.spatial.pop[, cluster := DBSCAN$cluster]

# Find non-outliers by grouping by cluster
non.outliers <- users.spatial.pop[cluster != 0,
  .(population = sum(population), latitude = mean(latitude),
  longitude = mean(longitude)), by = cluster] %>%
  setorder(-population)

outliers <- users.spatial.pop[cluster == 0,
  .(cluster, population, latitude, longitude)] %>%
  setorder(-population)

# rbind two data.tables using faster rbindlist method
users.spatial.pop <- rbindlist(list(non.outliers, outliers))[, 
  .(longitude, latitude, population)]

# adding extra labels in dataset
maxSize = max(users.spatial.pop$population)
radius = (users.spatial.pop$population/maxSize)*100000

col.df = data.frame( breaks = c(10, 50, 100, 500, 1000, 10000, 40000, maxSize), 
                     color = c("darkblue", "lightseagreen", "green", 
                               "lightblue", "purple", "orange", "red","darkred"),
                     radius = c(50, 500, 1000, 5000, 15000, 50000, 150000, 300000)
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
