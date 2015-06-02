## Converts similarity matrices from Apache Spark - Scala scripts to data frames
import numpy as np

import pandas as pd

import scipy.sparse
# Read Spark RDD output files

raw_df_1 = pd.read_csv('Dataset/rdd/part-00000.csv', names = ['user_a', 'user_b', 'similarity'])

raw_df_2 = pd.read_csv('Dataset/rdd/part-00001.csv', names = ['user_a', 'user_b', 'similarity'])
df = raw_df_1.copy()

df = df.append(raw_df_2)
df.shape
df.head()
df.sort(['user_a', 'user_b', 'similarity'], ascending = [1, 1, 1], inplace = True)
#### Let's see how accurate our similarity values are. We are using user with index = 0 to see how similar it is to user with index = 161
user_lang_prob = pd.read_csv('user_lang_prob_small.csv')
user_lang_prob.rename(columns = {'Unnamed: 0': 'user'}, inplace = True)
user_lang_prob.head()
np.array(user_lang_prob.iloc[[0, 161],:])
test_user = 161 # Username to predict for(CyanogenMod)

test_user
similar_users = df[df.user_a == test_user]
lower_limit = similar_users.similarity.quantile(0.99)
top_similar_users = similar_users[similar_users.similarity >= lower_limit]
top_similar_users.shape
#### Function for creating sparse matrices from dense matrices
def dfToCooMat(df):

    

    import scipy.sparse

    

    sparse_mat = scipy.sparse.csr_matrix(np.matrix(df))

    

    i = []

    j = []

    value = []

    

    idx = 0

    for x in sparse_mat:

        i.extend([idx] * len(x.indices))

        j.extend(x.indices)

        value.extend(x.data)

        idx = idx + 1

        

    df = pd.DataFrame({"i": i,"j": j,"value": value})

    return df
repo_lang_df = pd.read_csv('repo_lang_prob_small.csv')
repo_lang_df.drop(["Unnamed: 0", "repo_names"], axis = 1, inplace = True)
repo_lang_df.head()
sparse_repo_lang_df = dfToCooMat(repo_lang_df)
sparse_repo_lang_df.to_csv('repo_lang_prob_sparse.csv', index = False, header = False)
user_lang_df = pd.read_csv('user_lang_prob_medium.csv')

user_lang_df = user_lang_df.drop('Unnamed: 0', axis = 1)

user_lang_df.head()
sparse_user_lang_medium = dfToCooMat(user_lang_df)
sparse_user_lang_medium.to_csv('user_lang_prob_sparse_medium.csv', index = False, header = False)
repo_lang_df = pd.read_csv('repo_lang_prob_medium.csv')

repo_lang_df.drop(["Unnamed: 0", "repo_names"], axis = 1, inplace = True)

repo_lang_df.head()
sparse_repo_lang_medium = dfToCooMat(repo_lang_df)
sparse_repo_lang_medium.to_csv('repo_lang_prob_sparse_medium.csv', index = False, header = False)
