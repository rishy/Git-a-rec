# Load all required R packages
library(dplyr)
library(ggplot2)
library(grid)
library(data.table)
library(leaflet)
library(fpc)

# read repos and users csv files
repos.df <- fread('repos_dump_in_csv.csv', header = T,sep = ',', 
                 stringsAsFactors = FALSE, nrows=200000)
users.df <- fread('users_dump_in_csv.csv', header = T,sep = ',', 
                 stringsAsFactors = FALSE, nrows=200000)

# meaningless values
vague.values <- c(""," ", "-","none", "none.", "n/a", "na")
companies.vague.values <- c(vague.values, "self","student", "home")
language.vague.values <- c(vague.values, "Done")
freelancers <- c("freelance", "freelancer")

# replace freelance with freelancers as company in users.df
users.df <- mutate(users.df, 
                   company = ifelse(tolower(company) %in% freelancers, 
                                    "Freelancers", company))

## Visualization 1 :- Programming languages trends in last few years
## Starts Here

# add year column in repos.df
repos.df <- mutate(repos.df, 
                   year = as.integer(format(as.Date(created_at), "%Y"))
)

# find the top 10 languages
languages <- select(repos.df, language) %>%
  na.omit() %>%
  filter(!(language %in% vague.values )) %>%
  group_by(language) %>%
  summarise(val=n()) %>%
  ungroup() %>%
  arrange(desc(val))

languages.top <- languages$language[1:10]

# find the repos data yearwise
repos.yearwise <- group_by(repos.df, language, year) %>%
  summarise(val = n()) %>%
  na.omit() %>%
  filter(language %in% languages.top)

# line chart plot
v1 = ggplot(data = repos.yearwise, aes(x=year, y=val)) + 
  geom_line(aes(colour=language), size=1.2) +
  labs(title = "Yearwise Programming Languages Trends",
       x = "Year",
       y = "Number of Repos",
       colour = "Languages"
  ) + 
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

companies <- select(users.df, company) %>%
  na.omit() %>%
  filter(!(tolower(company) %in% companies.vague.values )) %>%
  group_by(company) %>%
  summarise(users = n()) %>%
  ungroup() %>%
  arrange(desc(users))
  
companies.top <- companies$company[1:25]

users.companies <- select(users.df, company) %>% 
  filter(company %in% companies.top )

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

## Visualization 3 :-  Comparison of Companies and Programming Languages
## Starts Here

# subsetting repos.df
DT.repos <- select(repos.df, owner.id, owner.login, language ) %>%
  filter( !(language %in% language.vague.values) ) %>%
  na.omit() %>%
  rename( id = owner.id, login = owner.login ) %>%
  mutate(id = as.character(id) )

# subsetting repos.df
DT.users <- select(users.df, id, login, company) %>%
  filter( !(company %in% companies.vague.values) ) %>%
  na.omit()

# create dataset by merging
repos.users.merged <- merge(DT.repos, DT.users, by=c("id", "login"))

# find top companies
companies <- group_by(repos.users.merged, company) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  arrange(desc(count))

companies.top <- companies$company[1:12]

# find top languages
languages <- group_by(repos.users.merged, language) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  arrange(desc(count))

languages.top <- languages$language[1:9]

## fill others in non-top language
repos.users.merged <- mutate(repos.users.merged, 
                             language = ifelse( language %in% languages.top,
                                                language, "Others"))

# filter top 12 companies data from dataset
companies.languages = filter(repos.users.merged,  company %in% companies.top )

# pie chart without labels
ggplot(data = companies.languages, aes(x = factor(1),fill=factor(language))) +
  facet_wrap(~company) +
  geom_bar(width = 1,position = "fill") +
  coord_polar(theta="y", start=0) +
  xlab("Companies") +
  ylab("No. of Repos")

## Ends Here

## Delete variables of visualization 3
rm(DT.repos)
rm(DT.users)
rm(companies)
rm(languages)
rm(companies.languages)

## Visualization 4 :- Spatial visualization of top languages users population
## Starts Here

# subsetting repos.df
DT.repos <- select(repos.df, owner.id, owner.login, language ) %>%
  filter( !(language %in% language.vague.values) ) %>%
  na.omit() %>%
  rename( id = owner.id, login = owner.login ) %>%
  mutate(id = as.character(id) )

# subsetting repos.df
DT.users <- select(users.df, id, login, company, latitude, longitude, location) %>%
  filter( !(company %in% companies.vague.values) ) %>%
  mutate( latitude = as.numeric(latitude),
          longitude = as.numeric(longitude)
  )  %>%
  na.omit()

# create dataset by merging
repos.users.merged <- merge(DT.repos, DT.users, by=c("id", "login"))

users.spatial.pop <- select(repos.users.merged, latitude, longitude, language)


# DBSCAN Clustering
DBSCAN <- dbscan(select(users.spatial.pop, latitude,longitude), 
                 eps=0.7, MinPts = 3)

users.spatial.pop <- mutate(users.spatial.pop, cluster = DBSCAN$cluster) %>%
  group_by(language, cluster) %>%
  summarise(population = n(),
            latitude = mean(latitude),
            longitude = mean(longitude)
  ) %>%
  ungroup() %>%
  arrange(desc(population))

rules.df = data.table( language = languages.top, 
                       colour = c("darkred", "red", "darkblue", 
                                  "lightseagreen", "green", 
                                  "lightblue", "purple", "orange","darkgreen" ) 
                      )

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
                 color = "users.spatial.pop$color", 
                 radius = users.spatial.pop$radius 
)

## Ends Here
