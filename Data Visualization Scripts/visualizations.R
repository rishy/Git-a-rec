# Load all required R packages
library(dplyr)
library(ggplot2)
library(colorspace)
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
companies <- na.omit(users.dt[,.(usersCnt = .N), by=company] %>% setorder(-usersCnt))
companies[company %in% c("Japan"),] <- NA
companies <- na.omit(companies)
companies.top <- companies[1:30,]

# barplot
v2 = ggplot(data = companies.top) +
  geom_bar(aes(x=company,y = usersCnt,fill=company), stat = "identity") +
  labs(title = "Histogram of Users in Top Companies",
       x = "Companies",
       y = "Number of Users"
  ) +
  scale_x_discrete(limits = companies.top$company) +
  geom_text(data=companies.top, aes(x = company, y = usersCnt, label=usersCnt), 
            size = 4, vjust=-1) +
  scale_fill_manual(values=rainbow_hcl(30, start = 30, end = 300), guide = FALSE)+
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

# subsetting users.df
DT.users <- na.omit(users.dt[!(company %in% companies.vague.values), 
                     .(id, login, company)])

# create dataset by merging
repos.users.merged <- merge(DT.repos, DT.users, by=c("id", "login"))

# find top companies
companies <- setorder(repos.users.merged[,.N, by=company], -N)

companies.top <- companies$company[1:12]

# find top languages
languages.top <- c("JavaScript", "Ruby", "Python", "PHP", "Java", "C", "Shell")

# fill others in non-top language
repos.users.merged[!(language %in% languages.top)]$language <- "Others"

# filter top 12 companies data from dataset
companies.languages = repos.users.merged[company %in% companies.top, ]

# add labels columns
companies.languages <- companies.languages[, .(reposCnt = .N), by = .(company,  language)]
companies.languages[, percentage := reposCnt/sum(reposCnt)*100, by = company ]
companies.languages[, pos := cumsum(percentage) - percentage*0.5, by = company]

colours = c("#DB9D85", "#86B875", "#4CB9CC", "#CD99D8","#1B9E77", 
            "#D95F02", "#66A61E","#666666")

# pie chart without labels
v3 = ggplot(data = companies.languages, aes(x=factor(1), y=percentage, 
                                            fill=factor(language ))) +
  geom_bar(stat="identity") +
  geom_bar(stat="identity", color='black', show_guide=FALSE) +
  geom_text(aes(x= factor(1), y=pos, label = sprintf("%1.f%%", percentage)), size=4) +
  coord_polar(theta="y", start=0) +
  facet_wrap(~company) +
  scale_fill_manual(values = colours,
                    name = "Languages",
                    breaks = c(languages.top, "Others"), 
                    labels = c(languages.top, "Others")) +
  theme(axis.text.x = element_blank(),
        plot.title = element_text(size=rel(2), face="bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        panel.grid = element_blank(),
        panel.border = element_blank(),
        strip.text.x = element_text(size=rel(1.5), face="bold"),
        legend.title = element_text(size=rel(1.5), face="bold"),
        legend.text = element_text(size=rel(1), face="bold"),
        legend.margin = unit(3,"cm"),
        legend.key.width = unit(1,"cm"),
        legend.key.height = unit(1,"cm"),
        legend.background = element_rect(fill="gray90", size=1, linetype="dotted")
  ) + 
  labs( title = "Comparison of Companies with Programming Languages")

# print plot
print(v3)

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

languages <- setorder(repos.users.merged[,.N, by=language], -N)

for(i in 1:5){
  # Merge users and repos columns with languages and coordinates
  users.spatial.pop <- repos.users.merged[language == languages[i]$language,
                                          .(latitude, longitude, language)]
  
  # Group By users.spatial.pop by language
  users.spatial.pop <- setorder(users.spatial.pop[, .(population = .N),
                                by = .(latitude, longitude)],
                                -population)
  
  # add colour labels and radius labels
  maxSize = max(users.spatial.pop$population)
  col.df = data.frame( breaks = rev(c(10, 50, maxSize/32, maxSize/16, maxSize/8,
                                      maxSize/4, maxSize/2, maxSize)),
                                color = c("darkred", "red", "orange", "purple",
                                          "green", "darkblue", "seagreen", "blue"))
  
  for(i in 1:8){    
    users.spatial.pop[population <= col.df$breaks[i], "color"] <- col.df$color[i]    
  }
  
  # plot world map using leaflet
  m = leaflet() %>% addTiles() %>% addCircles(users.spatial.pop$longitude,
                                              users.spatial.pop$latitude,
                                              color = users.spatial.pop$color,
                                              radius = 10000)  
  # print plot
  print(m)
}


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

# adding extra labels in dataset
maxSize = max(users.spatial.pop$population)

col.df = data.frame( breaks = rev(c(10, 50, maxSize/32, maxSize/16, maxSize/8,
                                maxSize/4, maxSize/2, maxSize)),
                                color = c("darkred", "red", "orange", "purple",
                               "green", "darkblue", "seagreen", "blue"))

for(i in 1:8){    
  users.spatial.pop[population <= col.df$breaks[i], "color"] <- col.df$color[i]    
}

# plot world map using leaflet
m = leaflet() %>% addTiles()
m %>% addCircles(users.spatial.pop$longitude, users.spatial.pop$latitude, 
                 color = users.spatial.pop$color, radius = 10000 
)

## Ends Here
