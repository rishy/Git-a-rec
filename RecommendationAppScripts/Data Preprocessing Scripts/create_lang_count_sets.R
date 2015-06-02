# Load all required R packages
library(dplyr)
library(data.table)
library(fpc)

# read repos and users csv files
repos.dt <- fread('final_repos.csv', header = T,sep = ',',
                 stringsAsFactors = FALSE)
users.dt <- fread('final_users.csv', header = T,sep = ',',
                 stringsAsFactors = FALSE)

# Merge users and repos data tables and rank them
merged_df <- merge(repos.dt[!is.na(language), ], users.dt, by=c('login')) %>%
             as.data.table() %>%
             setorder(-watchers, -forks, -followers, -following)

user_lang_set <- merged_df[1:300000,]
user_lang_set <- user_lang_set[, .(login, language)]

user_lang_count <- setorder(user_lang_set[, .(count = .N), by = .(login, language) ], login)

# Create repos languages matrix
repo_lang_set <- merged_df[1:300000,]
langs <- unique(repo_lang_set$language)

# Create a data table with repo_names column
repos_lang_dt <- data.table(repo_lang_set$full_name)
setnames(repos_lang_dt, new = 'repo_names', old = 'V1')

# Create languages columns
repos_lang_dt <- repos_lang_dt[, as.vector(langs) := 0]
repos_lang_dt <- repos_lang_dt[, language := repo_lang_set$language]

write.csv(user_lang_count, 'user_lang_count_small.csv', row.names = F, quote = F)
write.csv(repos_lang_dt, 'repos_lang_dt_small.csv', row.names = F, quote = F)


# Find the rating of each repo
rating_dt <- user_lang_set[, .(login, followers, following,
                               full_name, watchers, forks, language)]

# Scaling function to scale values between [0,1]
normalize <- function(x){(x-min(x))/(max(x)-min(x))}

temp_df[, .(followers, following, watchers, forks)] <- lapply(temp_df[, .(followers,
                                            following, watchers, forks)], normalize)

