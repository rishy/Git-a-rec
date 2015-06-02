## Creates language probability matrices for users and repos against 
import numpy as np

import pandas as pd

import json

from sys import stdout

from time import sleep
### Reads output of map-reduce script and create a dataframe of users and language
user_lang_dict = {}



with open('map-reduce/user-lang-matrix/output/part-00000') as f:

    for line in f:

        user_lang_dict.update(json.loads(line))

        

with open('map-reduce/user-lang-matrix/output/part-00001') as f:

  for line in f:

      user_lang_dict.update(json.loads(line))
user_lang_dict.items()[1:10]
user_lang_df = pd.DataFrame.from_dict(user_lang_dict).transpose().fillna(0)
user_lang_df.head()
user_lang_df.to_csv('user_lang_prob_medium.csv')
### Creates matrix of repo and lanugage probability(there is only 1 non-zero value against each repo for now)
# Create repos_lang_count df

repos_lang = pd.read_csv('repos_lang_dt_medium.csv')
repos_lang.shape
repos_lang_df = repos_lang.copy()



for i in range(0, 300000):

    repos_lang_df.loc[i, repos_lang_df.loc[i, 'language']] = 1

    stdout.write("\r%d" % i)

    stdout.flush()

    sleep(0.0000000001)
repos_lang_df.shape
repos_lang_df.to_csv('repo_lang_prob_medium.csv')
